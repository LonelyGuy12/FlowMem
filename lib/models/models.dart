class Expense {
  final double amount;
  final String category;
  final String currency;

  Expense({required this.amount, required this.category, required this.currency});

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      amount: json['amount'].toDouble(),
      category: json['category'],
      currency: json['currency'] ?? 'INR',
    );
  }
}

class TaskItem {
  final String title;
  final String? dueTime;
  final String priority;
  final bool completed;

  TaskItem({required this.title, this.dueTime, required this.priority, this.completed = false});

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      title: json['title'],
      dueTime: json['due_time'],
      priority: json['priority'] ?? 'medium',
      completed: json['completed'] ?? false,
    );
  }
}

class HealthLog {
  final String moodOrState;
  final String? contextNote;

  HealthLog({required this.moodOrState, this.contextNote});

  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      moodOrState: json['mood_or_state'] ?? json['moodOrState'] ?? '',
      contextNote: json['context_note'] ?? json['contextNote'],
    );
  }
}

class JournalEntry {
  final String transcript;
  final String summary;

  JournalEntry({required this.transcript, required this.summary});

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      transcript: json['transcript'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}

class DashboardData {
  final List<Expense> expenses;
  final List<TaskItem> tasks;
  final List<HealthLog> healthLogs;
  final List<JournalEntry> journalEntries;

  DashboardData({
    required this.expenses,
    required this.tasks,
    required this.healthLogs,
    required this.journalEntries,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      expenses: (json['expenses'] as List?)?.map((e) => Expense.fromJson(e)).toList() ?? [],
      tasks: (json['tasks'] as List?)?.map((e) => TaskItem.fromJson(e)).toList() ?? [],
      healthLogs: (json['health_logs'] as List?)?.map((e) => HealthLog.fromJson(e)).toList() ?? [],
      journalEntries: (json['journal_entries'] as List?)?.map((e) => JournalEntry.fromJson(e)).toList() ?? [],
    );
  }
}
