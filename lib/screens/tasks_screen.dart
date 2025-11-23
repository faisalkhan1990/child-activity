import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/task.dart';
import '../widgets/animated_hero_header.dart';
import 'assign_task_screen.dart';
import 'view_assigned_tasks_screen.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _selectedView = 0; // 0 = Categories, 1 = Weekly Schedule
  final List<Map<String, dynamic>> _taskCategories = [
    {
      'title': 'Study Time',
      'icon': Icons.menu_book,
      'color': Colors.blue,
      'description': 'Complete daily study sessions',
      'examples': ['Math homework', 'Reading assignment', 'Science project'],
    },
    {
      'title': 'Exercise',
      'icon': Icons.fitness_center,
      'color': Colors.green,
      'description': 'Physical activities and sports',
      'examples': ['Morning exercise', 'Yoga', 'Outdoor play'],
    },
    {
      'title': 'Vocabulary',
      'icon': Icons.spellcheck,
      'color': Colors.purple,
      'description': 'Learn new words every day',
      'examples': ['5 new words', 'Word meanings', 'Use in sentences'],
    },
    {
      'title': 'New Learning',
      'icon': Icons.lightbulb_outline,
      'color': Colors.orange,
      'description': 'Discover something new today',
      'examples': ['Fun fact', 'New skill', 'Science concept'],
    },
    {
      'title': 'Reading',
      'icon': Icons.auto_stories,
      'color': Colors.pink,
      'description': 'Daily reading practice',
      'examples': ['Story book', 'Educational article', 'News'],
    },
    {
      'title': 'Homework',
      'icon': Icons.assignment,
      'color': Colors.teal,
      'description': 'Complete school assignments',
      'examples': ['Math problems', 'Writing essay', 'Art project'],
    },
    {
      'title': 'Creative Activity',
      'icon': Icons.palette,
      'color': Colors.deepPurple,
      'description': 'Art, music, or creative projects',
      'examples': ['Drawing', 'Music practice', 'Crafts'],
    },
    {
      'title': 'Life Skills',
      'icon': Icons.home_repair_service,
      'color': Colors.brown,
      'description': 'Learn practical daily skills',
      'examples': ['Clean room', 'Help with cooking', 'Organize toys'],
    },
  ];

  String _getCurrentDay() {
    return DateFormat('EEEE').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View All Assigned Tasks',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ViewAssignedTasksScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(_selectedView == 0 ? Icons.calendar_today : Icons.grid_view),
            onPressed: () {
              setState(() {
                _selectedView = _selectedView == 0 ? 1 : 0;
              });
            },
            tooltip: _selectedView == 0 ? 'Weekly View' : 'Category View',
          ),
        ],
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          final childrenCount = authService.children.length;

          if (childrenCount == 0) {
            return Column(
              children: [
                // Animated Hero Header
                AnimatedHeroHeader(
                  title: 'Daily Tasks',
                  subtitle: 'Track children\'s activities',
                  icon: Icons.task_alt,
                  primaryColor: Colors.deepOrange,
                  secondaryColor: Colors.deepOrange.withOpacity(0.6),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No children added yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add children to assign tasks',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              // Animated Hero Header
              AnimatedHeroHeader(
                title: _selectedView == 0 ? 'Daily Tasks' : 'Weekly Schedule',
                subtitle: _selectedView == 0 
                    ? 'Track children\'s activities'
                    : 'View tasks by day',
                icon: _selectedView == 0 ? Icons.task_alt : Icons.calendar_month,
                primaryColor: Colors.deepOrange,
                secondaryColor: Colors.deepOrange.withOpacity(0.6),
              ),
              Expanded(
                child: _selectedView == 0
                    ? _buildCategoryView(authService)
                    : _buildWeeklyView(authService),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks_fab',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Custom Task - Coming Soon')),
          );
        },
        icon: const Icon(Icons.add_task),
        label: const Text('New Task'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  Widget _buildCategoryView(AuthService authService) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
                    // Select Child Section
                    Text(
                      'Select a Child',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: authService.children.length,
                        itemBuilder: (context, index) {
                          final childItem = authService.children[index];
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Selected: ${childItem.name}'),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.2),
                                      child: Text(
                                        childItem.name[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      childItem.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Task Categories
                    Text(
                      'Task Categories',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(_taskCategories.length, (index) {
                      final category = _taskCategories[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            _showTaskDetails(context, category);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (category['color'] as Color).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    category['icon'] as IconData,
                                    color: category['color'] as Color,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        category['description'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWeeklyView(AuthService authService) {
    final children = authService.children;
    final currentDay = _getCurrentDay();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // Show message if no children added yet
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
                'Add children from the dashboard to start assigning tasks',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isToday = day == currentDay;
        
        // Get all tasks for this day across all children
        List<Task> dayTasks = [];
        for (var child in children) {
          final childTasks = authService.getTasksForDay(child.id, day);
          dayTasks.addAll(childTasks);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: isToday ? 4 : 2,
          color: isToday ? Colors.deepOrange.shade50 : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isToday 
                ? BorderSide(color: Colors.deepOrange, width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isToday) const SizedBox(width: 8),
                    Text(
                      day,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.deepOrange : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: dayTasks.isEmpty 
                            ? Colors.grey.shade200 
                            : Colors.deepOrange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dayTasks.length} ${dayTasks.length == 1 ? 'task' : 'tasks'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: dayTasks.isEmpty ? Colors.grey.shade600 : Colors.deepOrange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (dayTasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        'No tasks scheduled',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ...dayTasks.map((task) {
                    final child = children.firstWhere((c) => c.id == task.childId);
                    final category = _taskCategories.firstWhere(
                      (cat) => cat['title'] == task.category,
                      orElse: () => _taskCategories[0],
                    );
                    
                    return Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: task.isCompletedForDay(day),
                            onChanged: (value) {
                              authService.toggleTaskCompletion(task.id, 'parent', specificDay: day);
                            },
                            activeColor: category['color'] as Color,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (category['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category['icon'] as IconData,
                              color: category['color'] as Color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompletedForDay(day)
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
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.category,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      task.category,
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
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTaskDetails(BuildContext context, Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['title'] as String,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category['description'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Example Tasks:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(category['examples'] as List<String>).map((example) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: category['color'] as Color,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      example,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AssignTaskScreen(
                        category: category['title'] as String,
                        categoryTitle: category['title'] as String,
                        categoryColor: category['color'] as Color,
                        categoryIcon: category['icon'] as IconData,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: category['color'] as Color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Assign Task',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
