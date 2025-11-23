import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../models/activity_log.dart';
import '../widgets/animated_hero_header.dart';

class ActivityLogsScreen extends StatefulWidget {
  final String? childId; // Optional: filter by child if provided

  const ActivityLogsScreen({super.key, this.childId});

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen> {
  String _selectedChildFilter = 'all';
  String _selectedActionFilter = 'all';
  String _selectedPerformerFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final children = authService.children;
    
    // Filter logs
    List<ActivityLog> filteredLogs = widget.childId != null
        ? authService.getActivityLogsForChild(widget.childId!)
        : authService.activityLogs;

    if (_selectedChildFilter != 'all') {
      filteredLogs = filteredLogs
          .where((log) => log.childId == _selectedChildFilter)
          .toList();
    }

    if (_selectedActionFilter != 'all') {
      filteredLogs = filteredLogs
          .where((log) => log.action == _selectedActionFilter)
          .toList();
    }

    if (_selectedPerformerFilter != 'all') {
      filteredLogs = filteredLogs
          .where((log) => log.performedBy == _selectedPerformerFilter)
          .toList();
    }

    // Group logs by date
    Map<String, List<ActivityLog>> groupedLogs = {};
    for (var log in filteredLogs) {
      final dateKey = _getDateKey(log.timestamp);
      if (!groupedLogs.containsKey(dateKey)) {
        groupedLogs[dateKey] = [];
      }
      groupedLogs[dateKey]!.add(log);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Animated Hero Header
          AnimatedHeroHeader(
            title: widget.childId != null ? 'My Activity' : 'Activity Logs',
            subtitle: widget.childId != null
                ? 'View your task activity history'
                : 'Track all task activities',
            primaryColor: Colors.deepPurple.shade400,
            secondaryColor: Colors.purple.shade300,
            icon: Icons.history,
          ),

          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Child Filter
                      if (widget.childId == null) ...[
                        _buildFilterChip(
                          label: 'All Children',
                          value: 'all',
                          isSelected: _selectedChildFilter == 'all',
                          onSelected: () {
                            setState(() {
                              _selectedChildFilter = 'all';
                            });
                          },
                        ),
                        ...children.map((child) => _buildFilterChip(
                              label: child.name,
                              value: child.id,
                              isSelected: _selectedChildFilter == child.id,
                              onSelected: () {
                                setState(() {
                                  _selectedChildFilter = child.id;
                                });
                              },
                            )),
                        const SizedBox(width: 16),
                      ],

                      // Action Filter
                      _buildFilterChip(
                        label: 'All Actions',
                        value: 'all',
                        isSelected: _selectedActionFilter == 'all',
                        onSelected: () {
                          setState(() {
                            _selectedActionFilter = 'all';
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Completed',
                        value: 'completed',
                        isSelected: _selectedActionFilter == 'completed',
                        onSelected: () {
                          setState(() {
                            _selectedActionFilter = 'completed';
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Uncompleted',
                        value: 'uncompleted',
                        isSelected: _selectedActionFilter == 'uncompleted',
                        onSelected: () {
                          setState(() {
                            _selectedActionFilter = 'uncompleted';
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Created',
                        value: 'created',
                        isSelected: _selectedActionFilter == 'created',
                        onSelected: () {
                          setState(() {
                            _selectedActionFilter = 'created';
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Deleted',
                        value: 'deleted',
                        isSelected: _selectedActionFilter == 'deleted',
                        onSelected: () {
                          setState(() {
                            _selectedActionFilter = 'deleted';
                          });
                        },
                      ),
                      const SizedBox(width: 16),

                      // Performer Filter
                      _buildFilterChip(
                        label: 'All',
                        value: 'all',
                        isSelected: _selectedPerformerFilter == 'all',
                        onSelected: () {
                          setState(() {
                            _selectedPerformerFilter = 'all';
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Parent',
                        value: 'parent',
                        isSelected: _selectedPerformerFilter == 'parent',
                        onSelected: () {
                          setState(() {
                            _selectedPerformerFilter = 'parent';
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Child',
                        value: 'child',
                        isSelected: _selectedPerformerFilter == 'child',
                        onSelected: () {
                          setState(() {
                            _selectedPerformerFilter = 'child';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No activity logs yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Task activities will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedLogs.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedLogs.keys.elementAt(index);
                      final logsForDate = groupedLogs[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 4,
                            ),
                            child: Text(
                              dateKey,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),

                          // Logs for this date
                          ...logsForDate.map((log) => _buildLogCard(log)),

                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: Colors.deepPurple.shade100,
        checkmarkColor: Colors.deepPurple,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLogCard(ActivityLog log) {
    final actionData = _getActionData(log.action);
    final performerData = _getPerformerData(log.performedBy);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: actionData['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                actionData['icon'],
                color: actionData['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Log Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Child Name
                  Text(
                    log.childName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Action Description
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      children: [
                        TextSpan(text: '${actionData['label']} '),
                        TextSpan(
                          text: '"${log.taskTitle}"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Performer and Time
                  Row(
                    children: [
                      // Performer Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: performerData['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              performerData['icon'],
                              size: 14,
                              color: performerData['color'],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              log.performedBy,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: performerData['color'],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Time
                      Text(
                        DateFormat('h:mm a').format(log.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getActionData(String action) {
    switch (action) {
      case 'completed':
        return {
          'icon': Icons.check_circle,
          'color': Colors.green,
          'label': 'Completed',
        };
      case 'uncompleted':
        return {
          'icon': Icons.undo,
          'color': Colors.orange,
          'label': 'Marked as pending',
        };
      case 'created':
        return {
          'icon': Icons.add_circle,
          'color': Colors.blue,
          'label': 'Created task',
        };
      case 'deleted':
        return {
          'icon': Icons.delete,
          'color': Colors.red,
          'label': 'Deleted task',
        };
      default:
        return {
          'icon': Icons.info,
          'color': Colors.grey,
          'label': action,
        };
    }
  }

  Map<String, dynamic> _getPerformerData(String performer) {
    switch (performer) {
      case 'parent':
        return {
          'icon': Icons.person,
          'color': Colors.deepPurple,
        };
      case 'child':
        return {
          'icon': Icons.child_care,
          'color': Colors.blue,
        };
      default:
        return {
          'icon': Icons.person_outline,
          'color': Colors.grey,
        };
    }
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}
