# ci: pipeline test
import os
import json
import boto3
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
import psycopg2
import psycopg2.extras
import redis

app = FastAPI(title="AWS Cloud Forge API", version="1.0.0")

# ============================================================
# CONFIG — carga credenciales desde Secrets Manager o env vars
# ============================================================

def get_db_credentials():
    secret_arn = os.getenv("DB_SECRET_ARN")
    if secret_arn:
        client = boto3.client("secretsmanager", region_name=os.getenv("AWS_REGION", "us-east-1"))
        secret = client.get_secret_value(SecretId=secret_arn)
        creds = json.loads(secret["SecretString"])
        # host y port vienen de env vars — no están en el secret
        creds["host"] = os.getenv("DB_HOST", "localhost")
        creds["port"] = os.getenv("DB_PORT", "5432")
        return creds
    # fallback para desarrollo local
    return {
        "host":     os.getenv("DB_HOST", "localhost"),
        "port":     os.getenv("DB_PORT", "5432"),
        "dbname":   os.getenv("DB_NAME", "acfdb"),
        "username": os.getenv("DB_USER", "acfadmin"),
        "password": os.getenv("DB_PASSWORD", ""),
    }

def get_db_connection():
    creds = get_db_credentials()
    return psycopg2.connect(
        host=creds["host"],
        port=creds["port"],
        dbname=creds["dbname"],
        user=creds["username"],
        password=creds["password"],
    )

def get_redis():
    host = os.getenv("REDIS_HOST", "localhost")
    port = int(os.getenv("REDIS_PORT", "6379"))
    return redis.Redis(host=host, port=port, db=0, decode_responses=True)

# ============================================================
# STARTUP — crear tabla si no existe
# ============================================================

@app.on_event("startup")
def startup():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS items (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            description TEXT,
            created_at TIMESTAMP DEFAULT NOW()
        )
    """)
    conn.commit()
    cur.close()
    conn.close()

# ============================================================
# SCHEMAS
# ============================================================

class ItemCreate(BaseModel):
    name: str
    description: Optional[str] = None

class Item(BaseModel):
    id: int
    name: str
    description: Optional[str] = None

# ============================================================
# HEALTH CHECK
# ============================================================

@app.get("/health")
def health():
    status = {"status": "ok", "db": "ok", "redis": "ok"}

    try:
        conn = get_db_connection()
        conn.close()
    except Exception as e:
        status["db"] = str(e)
        status["status"] = "degraded"

    try:
        r = get_redis()
        r.ping()
    except Exception as e:
        status["redis"] = str(e)
        status["status"] = "degraded"

    return status

# ============================================================
# CRUD — /items
# ============================================================

@app.post("/items", response_model=Item, status_code=201)
def create_item(item: ItemCreate):
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute(
        "INSERT INTO items (name, description) VALUES (%s, %s) RETURNING id, name, description",
        (item.name, item.description)
    )
    row = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()

    # invalidar caché de lista
    r = get_redis()
    r.delete("items:all")

    return row


@app.get("/items")
def list_items():
    r = get_redis()
    cached = r.get("items:all")
    if cached:
        return {"source": "cache", "items": json.loads(cached)}

    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("SELECT id, name, description FROM items ORDER BY id")
    rows = cur.fetchall()
    cur.close()
    conn.close()

    items = [dict(r) for r in rows]
    r.setex("items:all", 60, json.dumps(items))  # TTL 60 seg

    return {"source": "db", "items": items}


@app.get("/items/{item_id}", response_model=Item)
def get_item(item_id: int):
    r = get_redis()
    cached = r.get(f"item:{item_id}")
    if cached:
        return json.loads(cached)

    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("SELECT id, name, description FROM items WHERE id = %s", (item_id,))
    row = cur.fetchone()
    cur.close()
    conn.close()

    if not row:
        raise HTTPException(status_code=404, detail="Item not found")

    item = dict(row)
    r.setex(f"item:{item_id}", 60, json.dumps(item))

    return item


@app.delete("/items/{item_id}", status_code=204)
def delete_item(item_id: int):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM items WHERE id = %s RETURNING id", (item_id,))
    deleted = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()

    if not deleted:
        raise HTTPException(status_code=404, detail="Item not found")

    r = get_redis()
    r.delete(f"item:{item_id}")
    r.delete("items:all")
