from fastapi import APIRouter, UploadFile, File, HTTPException
from ..firebase_db import get_firestore
from ..groq_service import transcribe_audio, parse_transcript
from firebase_admin import firestore
import datetime

router = APIRouter()

@router.post("/process-audio")
async def process_audio(audio: UploadFile = File(...)):
    db = get_firestore()
    if not db:
        raise HTTPException(status_code=500, detail="Firestore not initialized.")
        
    try:
        audio_bytes = await audio.read()
        if not audio_bytes:
            raise HTTPException(status_code=400, detail="Empty audio file")
            
        transcript = await transcribe_audio(audio_bytes, audio.filename or "audio.m4a")
        parsed_payload = await parse_transcript(transcript)
        
        now = firestore.SERVER_TIMESTAMP
        
        batch = db.batch()
        
        journal_ref = db.collection('journal_entries').document()
        batch.set(journal_ref, {
            'transcript': transcript,
            'summary': parsed_payload.journal_summary,
            'timestamp': now
        })
        
        for exp in parsed_payload.expenses:
            exp_ref = db.collection('expenses').document()
            batch.set(exp_ref, {
                'amount': exp.amount,
                'category': exp.category,
                'currency': exp.currency,
                'timestamp': now
            })
            
        for tsk in parsed_payload.tasks:
            tsk_ref = db.collection('tasks').document()
            batch.set(tsk_ref, {
                'title': tsk.title,
                'due_time': tsk.due_time,
                'priority': tsk.priority,
                'completed': False,
                'timestamp': now
            })
            
        for hlth in parsed_payload.health_logs:
            hlth_ref = db.collection('health_logs').document()
            batch.set(hlth_ref, {
                'mood_or_state': hlth.mood_or_state,
                'context_note': hlth.context_note,
                'timestamp': now
            })
            
        batch.commit()
        
        return {
            "status": "success",
            "transcript": transcript,
            "parsed": parsed_payload.model_dump()
        }
        
    except Exception as e:
        print(f"Error in process_audio: {e}")
        raise HTTPException(status_code=500, detail=str(e))
