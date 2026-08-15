from fastapi import APIRouter, HTTPException
from firebase_db import get_firestore
from firebase_admin import firestore

router = APIRouter()

@router.get("/dashboard")
async def get_dashboard():
    db = get_firestore()
    if not db:
        raise HTTPException(status_code=500, detail="Firestore not initialized.")
        
    try:
        expenses_docs = db.collection('expenses').order_by('timestamp', direction=firestore.Query.DESCENDING).limit(10).stream()
        expenses = [doc.to_dict() for doc in expenses_docs]
        
        tasks_docs = db.collection('tasks').where('completed', '==', False).order_by('timestamp', direction=firestore.Query.DESCENDING).limit(20).stream()
        tasks = [doc.to_dict() for doc in tasks_docs]
        
        health_docs = db.collection('health_logs').order_by('timestamp', direction=firestore.Query.DESCENDING).limit(5).stream()
        health_logs = [doc.to_dict() for doc in health_docs]
        
        journal_docs = db.collection('journal_entries').order_by('timestamp', direction=firestore.Query.DESCENDING).limit(5).stream()
        journal_entries = [doc.to_dict() for doc in journal_docs]
        
        return {
            "expenses": expenses,
            "tasks": tasks,
            "health_logs": health_logs,
            "journal_entries": journal_entries
        }
    except Exception as e:
        print(f"Error fetching dashboard: {e}")
        raise HTTPException(status_code=500, detail=str(e))
