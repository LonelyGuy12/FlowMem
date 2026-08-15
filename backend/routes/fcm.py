from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from firebase_db import get_firestore
from firebase_admin import firestore

router = APIRouter()

class TokenPayload(BaseModel):
    token: str

@router.post("/register-token")
async def register_token(payload: TokenPayload):
    db = get_firestore()
    if not db:
        raise HTTPException(status_code=500, detail="Firestore not initialized")
        
    try:
        # We use the token itself as the document ID for deduplication
        doc_ref = db.collection('device_tokens').document(payload.token)
        doc_ref.set({
            'token': payload.token,
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        return {"status": "success", "message": "Token registered"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
