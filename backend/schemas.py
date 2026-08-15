from pydantic import BaseModel
from typing import List, Optional

class ExpenseItem(BaseModel):
    amount: float
    category: str
    currency: str = "INR"

class TaskItem(BaseModel):
    title: str
    due_time: Optional[str] = None
    priority: str = "medium"

class HealthLogItem(BaseModel):
    mood_or_state: str
    context_note: Optional[str] = None

class FlowMemParsedPayload(BaseModel):
    expenses: List[ExpenseItem] = []
    tasks: List[TaskItem] = []
    health_logs: List[HealthLogItem] = []
    journal_summary: str
