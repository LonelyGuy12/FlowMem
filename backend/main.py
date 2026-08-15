import asyncio
import datetime
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from firebase_db import init_firebase, get_firestore
from firebase_admin import messaging
from routes import ingest, data, fcm

async def check_due_tasks():
    while True:
        try:
            db = get_firestore()
            if db:
                tasks_ref = db.collection('tasks').where('completed', '==', False).stream()
                
                for task_doc in tasks_ref:
                    task = task_doc.to_dict()
                    due_time_str = task.get('due_time')
                    notified = task.get('notified', False)
                    
                    if due_time_str and not notified:
                        try:
                            due_time = datetime.datetime.fromisoformat(due_time_str.replace('Z', '+00:00'))
                            now = datetime.datetime.now(datetime.timezone.utc)
                            
                            if due_time <= now:
                                tokens_ref = db.collection('device_tokens').stream()
                                tokens = [t.to_dict().get('token') for t in tokens_ref]
                                
                                if tokens:
                                    message = messaging.MulticastMessage(
                                        data={
                                            'title': 'Task Due!',
                                            'body': task.get('title', 'You have a task due now.')
                                        },
                                        tokens=tokens
                                    )
                                    messaging.send_each_for_multicast(message)
                                    
                                db.collection('tasks').document(task_doc.id).update({'notified': True})
                        except Exception as parse_err:
                            print(f"Error parsing date {due_time_str}: {parse_err}")
                            
        except Exception as e:
            print(f"Error in background task: {e}")
            
        await asyncio.sleep(60)

@asynccontextmanager
async def lifespan(app: FastAPI):
    init_firebase()
    bg_task = asyncio.create_task(check_due_tasks())
    yield
    bg_task.cancel()

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
app.include_router(fcm.router, prefix="/api", tags=["FCM"])

@app.get("/")
def read_root():
    return {"message": "Welcome to FlowMem API"}
