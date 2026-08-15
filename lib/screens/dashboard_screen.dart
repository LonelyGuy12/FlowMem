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
  // Vercel AMOLED Colors
  static const vercelBlack = Color(0xFF000000);
  static const vercelGray = Color(0xFF1A1A1A);
  static const vercelBorder = Color(0xFF2A2A2A);
  static const vercelAccent = Color(0xFF0070F3);
  static const vercelSuccess = Color(0xFF0DBC79);
  static const vercelError = Color(0xFFE00);
  static const vercelWarning = Color(0xFFF5A623);
  static const vercelTextPrimary = Color(0xFFFFFFFF);
  static const vercelTextSecondary = Color(0xFFA1A1A1);
  static const vercelTextTertiary = Color(0xFF666666);

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
      backgroundColor: vercelBlack,
      body: SafeArea(
        child: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(vercelAccent),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(color: vercelTextSecondary, fontSize: 14),
                    ),
                  ],
                ),
              );
            }
            
            final data = provider.data;
            if (data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: vercelError),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load data',
                      style: TextStyle(color: vercelTextPrimary, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => provider.loadDashboard(),
                      child: Text('Retry', style: TextStyle(color: vercelAccent)),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.loadDashboard(),
              color: vercelAccent,
              backgroundColor: vercelGray,
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FlowMem',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: vercelTextPrimary,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: vercelTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: vercelGray,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: vercelBorder),
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color: vercelTextSecondary,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildExpenseCard(data.expenses),
                        const SizedBox(height: 16),
                        _buildTaskCard(data.tasks),
                        const SizedBox(height: 16),
                        _buildHealthCard(data.healthLogs),
                        const SizedBox(height: 16),
                        _buildJournalCard(data.journalEntries),
                        const SizedBox(height: 120), // Space for FAB
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const RecorderWidget(),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
  String _formatDueTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
      int hour12 = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      String timeString = '$hour12:${twoDigits(dateTime.minute)} $amPm';
      
      if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
        return 'Today, $timeString';
      } else if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day + 1) {
        return 'Tomorrow, $timeString';
      } else {
        return '${dateTime.month}/${dateTime.day}/${dateTime.year}, $timeString';
      }
    } catch (e) {
      return isoString;
    }
  }



  Widget _buildCard({
    required String title,
    required Widget child,
    required IconData icon,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: vercelGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: vercelBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? vercelAccent).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? vercelAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: vercelTextPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(List<Expense> expenses) {
    double total = expenses.fold(0.0, (sum, item) => sum + item.amount);
    
    return _buildCard(
      title: 'Expenses',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: vercelSuccess,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: vercelTextPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: vercelSuccess.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: vercelSuccess,
                  ),
                ),
              ),
            ],
          ),
          if (expenses.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: vercelBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: vercelBorder),
              ),
              child: Column(
                children: expenses.asMap().entries.map((entry) {
                  final e = entry.value;
                  final isLast = entry.key == expenses.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: vercelSuccess,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                e.category,
                                style: TextStyle(
                                  color: vercelTextPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${e.currency} ${e.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: vercelTextSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(color: vercelBorder, height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No expenses recorded',
                style: TextStyle(color: vercelTextTertiary, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(List<TaskItem> tasks) {
    final completedCount = tasks.where((t) => t.completed).length;
    final totalCount = tasks.length;
    
    return _buildCard(
      title: 'Tasks',
      icon: Icons.check_circle_rounded,
      iconColor: vercelAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (totalCount > 0) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: vercelAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$completedCount / $totalCount completed',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: vercelAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (tasks.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: vercelBlack,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: vercelBorder),
              ),
              child: Column(
                children: tasks.asMap().entries.map((entry) {
                  final t = entry.value;
                  final isLast = entry.key == tasks.length - 1;
                  final priorityColor = t.priority == 'high' 
                      ? vercelError 
                      : t.priority == 'medium' 
                          ? vercelWarning 
                          : vercelTextTertiary;
                  
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              t.completed 
                                  ? Icons.check_circle_rounded 
                                  : Icons.radio_button_unchecked_rounded,
                              color: t.completed ? vercelSuccess : vercelTextTertiary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    style: TextStyle(
                                      color: t.completed ? vercelTextTertiary : vercelTextPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      decoration: t.completed ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (t.dueTime != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: vercelTextTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDueTime(t.dueTime!),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: vercelTextTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t.priority.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: priorityColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(color: vercelBorder, height: 1),
                    ],
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No tasks yet',
                style: TextStyle(color: vercelTextTertiary, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(List<HealthLog> healthLogs) {
    return _buildCard(
      title: 'Health & Mood',
      icon: Icons.favorite_rounded,
      iconColor: Color(0xFFFF006B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (healthLogs.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: healthLogs.map((h) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: vercelBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: vercelBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getMoodEmoji(h.moodOrState),
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        h.moodOrState,
                        style: TextStyle(
                          color: vercelTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No health logs yet',
                style: TextStyle(color: vercelTextTertiary, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    final moodLower = mood.toLowerCase();
    if (moodLower.contains('happy') || moodLower.contains('great') || moodLower.contains('excited')) {
      return '😊';
    } else if (moodLower.contains('sad') || moodLower.contains('down')) {
      return '😔';
    } else if (moodLower.contains('stress') || moodLower.contains('anxious')) {
      return '😰';
    } else if (moodLower.contains('calm') || moodLower.contains('peaceful')) {
      return '😌';
    } else if (moodLower.contains('tired') || moodLower.contains('exhausted')) {
      return '😴';
    } else if (moodLower.contains('angry') || moodLower.contains('frustrated')) {
      return '😠';
    }
    return '😊';
  }

  Widget _buildJournalCard(List<JournalEntry> journalEntries) {
    return _buildCard(
      title: 'Journal',
      icon: Icons.menu_book_rounded,
      iconColor: vercelWarning,
      child: Column(
        children: [
          if (journalEntries.isNotEmpty)
            ...journalEntries.asMap().entries.map((entry) {
              final j = entry.value;
              final isLast = entry.key == journalEntries.length - 1;
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: vercelBlack,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: vercelBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: vercelWarning,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                j.summary,
                                style: TextStyle(
                                  color: vercelTextPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (j.transcript.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: vercelGray,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: vercelBorder),
                            ),
                            child: Text(
                              j.transcript,
                              style: TextStyle(
                                color: vercelTextSecondary,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }).toList()
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No journal entries yet',
                style: TextStyle(color: vercelTextTertiary, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
