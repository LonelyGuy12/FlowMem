from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from firebase_db import init_firebase
from routes import ingest, data

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_firebase()
    yield

app = FastAPI(title="FlowMem API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ingest.router, prefix="/api", tags=["Ingest"])
app.include_router(data.router, prefix="/api", tags=["Data"])

@app.get("/")
def read_root():
    return {"message": "Welcome to FlowMem API"}
