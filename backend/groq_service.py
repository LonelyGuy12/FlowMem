import json
from groq import AsyncGroq
from config import settings
from schemas import FlowMemParsedPayload

client = AsyncGroq(api_key=settings.groq_api_key)

async def transcribe_audio(file_bytes: bytes, filename: str = "audio.m4a") -> str:
    try:
        transcription = await client.audio.transcriptions.create(
            file=(filename, file_bytes),
            model="whisper-large-v3",
            prompt="Spoken journal entry, ledger entry, tasks, health state.",
            response_format="text"
        )
        return transcription
    except Exception as e:
        print(f"Error in transcribe_audio: {e}")
        raise

async def parse_transcript(text: str) -> FlowMemParsedPayload:
    prompt = """
    You are an AI assistant that extracts structured data from a user's spoken journal.
    Extract expenses, tasks, health logs, and write a brief journal summary.
    Provide the output in JSON matching this schema exactly:
    {
      "expenses": [{"amount": float, "category": string, "currency": string}],
      "tasks": [{"title": string, "due_time": string (optional), "priority": string ("low"|"medium"|"high")}],
      "health_logs": [{"mood_or_state": string, "context_note": string (optional)}],
      "journal_summary": string
    }
    """
    
    try:
        completion = await client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[
                {"role": "system", "content": prompt},
                {"role": "user", "content": text}
            ],
            response_format={"type": "json_object"},
            temperature=0.0
        )
        
        response_text = completion.choices[0].message.content
        data = json.loads(response_text)
        return FlowMemParsedPayload(**data)
    except Exception as e:
        print(f"Error in parse_transcript: {e}")
        return FlowMemParsedPayload(journal_summary="Failed to parse transcript")
