import firebase_admin
from firebase_admin import credentials, firestore
import json

def main():
    cred = credentials.Certificate('/Users/lonely/hackathons/FlowMem/backend/firebase_credentials.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    
    tokens = list(db.collection('device_tokens').stream())
    print(f"Registered tokens: {len(tokens)}")
    for t in tokens:
        print(t.to_dict())
        
    tasks = list(db.collection('tasks').stream())
    print(f"\nTasks: {len(tasks)}")
    for t in tasks:
        print(t.to_dict())

if __name__ == '__main__':
    main()
