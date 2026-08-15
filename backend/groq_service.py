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
    import datetime
    current_time_utc = datetime.datetime.now(datetime.timezone.utc).isoformat()
    
    prompt = f"""
    You are an AI assistant that extracts structured data from a user's spoken journal.
    Extract expenses, tasks, health logs, and write a brief journal summary.
    Current time (UTC): {current_time_utc}
    IMPORTANT: For tasks, if a due time is mentioned or implied, convert it to a strict absolute ISO-8601 timestamp string (e.g. 'YYYY-MM-DDTHH:MM:SSZ'). Assume the user's timezone is local but convert it to UTC for the output. If no time is specified, leave it null.
    Provide the output in JSON matching this schema exactly:
    {{
      "expenses": [{{"amount": float, "category": string, "currency": string}}],
      "tasks": [{{"title": string, "due_time": string (ISO-8601 UTC or null), "priority": string ("low"|"medium"|"high")}}],
      "health_logs": [{{"mood_or_state": string, "context_note": string (optional)}}],
      "journal_summary": string
    }}
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
