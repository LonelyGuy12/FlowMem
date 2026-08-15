import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/recorder_widget.dart';
import '../models/models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('FlowMem', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final data = provider.data;
          if (data == null) {
            return const Center(child: Text('Failed to load data', style: TextStyle(color: Colors.white)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildExpenseCard(data.expenses),
                const SizedBox(height: 16),
                _buildTaskCard(data.tasks),
                const SizedBox(height: 16),
                _buildHealthCard(data.healthLogs),
                const SizedBox(height: 16),
                _buildJournalCard(data.journalEntries),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const RecorderWidget(),
    );
  }

  Widget _buildCard({required String title, required Widget child, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurpleAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildExpenseCard(List<Expense> expenses) {
    double total = expenses.fold(0.0, (sum, item) => sum + item.amount);
    return _buildCard(
      title: 'Expenses',
      icon: Icons.attach_money,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total: \$$total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          const SizedBox(height: 8),
          ...expenses.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.category, style: const TextStyle(color: Colors.white70)),
                Text('${e.currency} ${e.amount}', style: const TextStyle(color: Colors.white)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskCard(List<TaskItem> tasks) {
    return _buildCard(
      title: 'Tasks',
      icon: Icons.check_circle_outline,
      child: Column(
        children: tasks.map((t) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            t.completed ? Icons.check_circle : Icons.circle_outlined,
            color: t.completed ? Colors.green : Colors.grey,
          ),
          title: Text(t.title, style: TextStyle(
            color: Colors.white,
            decoration: t.completed ? TextDecoration.lineThrough : null,
          )),
          subtitle: t.dueTime != null ? Text(t.dueTime!, style: const TextStyle(color: Colors.white54)) : null,
          trailing: Text(t.priority, style: TextStyle(
            color: t.priority == 'high' ? Colors.redAccent : Colors.orangeAccent,
          )),
        )).toList(),
      ),
    );
  }

  Widget _buildHealthCard(List<HealthLog> healthLogs) {
    return _buildCard(
      title: 'Health & Mood',
      icon: Icons.favorite_border,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: healthLogs.map((h) => Chip(
          backgroundColor: Colors.pinkAccent.withOpacity(0.2),
          label: Text(h.moodOrState, style: const TextStyle(color: Colors.pinkAccent)),
        )).toList(),
      ),
    );
  }

  Widget _buildJournalCard(List<JournalEntry> journalEntries) {
    return _buildCard(
      title: 'Journal',
      icon: Icons.book_outlined,
      child: Column(
        children: journalEntries.map((j) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(j.summary, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(j.transcript, style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
              const Divider(color: Colors.white24),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
