import firebase_admin
from firebase_admin import credentials, firestore
from config import settings
import os

db = None

def init_firebase():
    global db
    if not firebase_admin._apps:
        if os.path.exists(settings.firebase_credentials_path):
            cred = credentials.Certificate(settings.firebase_credentials_path)
            firebase_admin.initialize_app(cred)
            db = firestore.client()
            print("Firebase initialized successfully.")
        else:
            print(f"Warning: Firebase credentials not found at {settings.firebase_credentials_path}. Firestore will not work.")
    else:
        db = firestore.client()

def get_firestore():
    return db
