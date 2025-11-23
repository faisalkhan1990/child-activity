import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/task.dart';
import '../models/child.dart';
import '../widgets/animated_hero_header.dart';

class ViewAssignedTasksScreen extends StatefulWidget {
  const ViewAssignedTasksScreen({super.key});

  @override
  State<ViewAssignedTasksScreen> createState() => _ViewAssignedTasksScreenState();
}

class _ViewAssignedTasksScreenState extends State<ViewAssignedTasksScreen> {
  String? _selectedChildFilter;
  String _selectedStatusFilter = 'all'; // all, completed, pending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Tasks'),
        centerTitle: true,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final children = authService.children;
          final allTasks = authService.tasks;

          if (children.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.child_care,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Children Added',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add children to start assigning tasks',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Filter tasks
          List<Task> filteredTasks = allTasks;
          if (_selectedChildFilter != null) {
            filteredTasks = filteredTasks
                .where((task) => task.childId == _selectedChildFilter)
                .toList();
          }
          if (_selectedStatusFilter == 'completed') {
            filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
          } else if (_selectedStatusFilter == 'pending') {
            filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
          }

          return Column(
            children: [
              // Animated Hero Header
              AnimatedHeroHeader(
                title: 'Assigned Tasks',
                subtitle: '${allTasks.length} total tasks',
                icon: Icons.assignment,
                primaryColor: Colors.purple,
                secondaryColor: Colors.purple.withOpacity(0.6),
              ),

              // Filters
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Child Filter
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String?>(
                            value: _selectedChildFilter,
                            decoration: InputDecoration(
                              labelText: 'Child',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Children'),
                              ),
                              ...children.map((child) {
                                return DropdownMenuItem(
                                  value: child.id,
                                  child: Text(child.name),
                                );
                              }).toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedChildFilter = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Status Filter
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatusFilter,
                            decoration: InputDecoration(
                              labelText: 'Status',
                              prefixIcon: const Icon(Icons.check_circle_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All Tasks'),
                              ),
                              DropdownMenuItem(
                                value: 'completed',
                                child: Text('Completed'),
                              ),
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatusFilter = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Task List
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Tasks Found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your filters or assign new tasks',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          final child = children.firstWhere(
                            (c) => c.id == task.childId,
                          );
                          
                          return _buildTaskCard(
                            context,
                            task,
                            child,
                            authService,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    Child child,
    AuthService authService,
  ) {
    // Determine category color
    final categoryColors = {
      'Study': Colors.blue,
      'Exercise': Colors.green,
      'Vocabulary': Colors.orange,
      'New Learning': Colors.purple,
      'Reading': Colors.teal,
      'Homework': Colors.red,
      'Creative Activity': Colors.pink,
      'Life Skills': Colors.brown,
    };
    
    final categoryColor = categoryColors[task.category] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showTaskDetails(context, task, child, authService);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(task.category),
                      color: categoryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Task Title and Child
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              child.name,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Checkbox
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (value) {
                      authService.toggleTaskCompletion(task.id, 'parent');
                    },
                    activeColor: categoryColor,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Category Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: categoryColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  task.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Days
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: task.days.map((day) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      day.substring(0, 3), // Show first 3 letters
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Study':
        return Icons.school;
      case 'Exercise':
        return Icons.fitness_center;
      case 'Vocabulary':
        return Icons.library_books;
      case 'New Learning':
        return Icons.lightbulb;
      case 'Reading':
        return Icons.menu_book;
      case 'Homework':
        return Icons.assignment;
      case 'Creative Activity':
        return Icons.palette;
      case 'Life Skills':
        return Icons.handyman;
      default:
        return Icons.task;
    }
  }

  void _showTaskDetails(
    BuildContext context,
    Task task,
    Child child,
    AuthService authService,
  ) {
    final categoryColors = {
      'Study': Colors.blue,
      'Exercise': Colors.green,
      'Vocabulary': Colors.orange,
      'New Learning': Colors.purple,
      'Reading': Colors.teal,
      'Homework': Colors.red,
      'Creative Activity': Colors.pink,
      'Life Skills': Colors.brown,
    };
    
    final categoryColor = categoryColors[task.category] ?? Colors.grey;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(task.category),
                    color: categoryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        task.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Child Info
            _buildDetailRow(
              icon: Icons.person,
              label: 'Assigned to',
              value: child.name,
            ),
            const SizedBox(height: 16),
            
            // Days
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Scheduled Days',
              value: task.days.join(', '),
            ),
            const SizedBox(height: 16),
            
            // Status
            _buildDetailRow(
              icon: task.isCompleted ? Icons.check_circle : Icons.pending,
              label: 'Status',
              value: task.isCompleted ? 'Completed' : 'Pending',
              valueColor: task.isCompleted ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            
            // Created Date
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Created',
              value: '${task.createdDate.day}/${task.createdDate.month}/${task.createdDate.year}',
            ),
            const SizedBox(height: 24),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmDelete(context, task, authService);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      authService.toggleTaskCompletion(task.id, 'parent');
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      task.isCompleted ? Icons.undo : Icons.check,
                    ),
                    label: Text(
                      task.isCompleted ? 'Mark Pending' : 'Mark Done',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: categoryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    Task task,
    AuthService authService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              authService.deleteTask(task.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
