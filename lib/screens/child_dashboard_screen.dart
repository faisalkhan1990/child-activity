import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../models/child.dart';
import '../models/task.dart';
import 'child_login_screen.dart';
import 'activity_logs_screen.dart';

class ChildDashboardScreen extends StatefulWidget {
  final Child child;

  const ChildDashboardScreen({
    super.key,
    required this.child,
  });

  @override
  State<ChildDashboardScreen> createState() => _ChildDashboardScreenState();
}

class _ChildDashboardScreenState extends State<ChildDashboardScreen> {
  int _selectedView = 0; // 0: All Tasks, 1: Pending, 2: Completed, 3: Upcoming
  int _currentTab = 0; // 0: Tasks, 1: Profile, 2: Settings

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.child.name[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child.name,
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  _currentTab == 0
                      ? 'My Tasks'
                      : _currentTab == 1
                          ? 'My Profile'
                          : 'Settings',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const ChildLoginScreen(),
                ),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _currentTab == 0
          ? _buildTasksTab()
          : _currentTab == 1
              ? _buildProfileTab()
              : _buildSettingsTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return Consumer<AuthService>(
        builder: (context, authService, child) {
          final allTasks = authService.getTasksForChild(widget.child.id);
          final currentDay = DateFormat('EEEE').format(DateTime.now());

          // Filter tasks based on selected view
          List<Task> displayTasks;
          switch (_selectedView) {
            case 1: // Pending
              displayTasks = allTasks.where((t) => !t.isCompleted).toList();
              break;
            case 2: // Completed
              displayTasks = allTasks.where((t) => t.isCompleted).toList();
              break;
            case 3: // Upcoming (today's tasks)
              displayTasks = allTasks
                  .where((t) => t.days.contains(currentDay) && !t.isCompleted)
                  .toList();
              break;
            default: // All
              displayTasks = allTasks;
          }

          return Column(
            children: [
              // Stats Cards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total',
                        allTasks.length.toString(),
                        Icons.assignment,
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pending',
                        allTasks.where((t) => !t.isCompleted).length.toString(),
                        Icons.pending_actions,
                        Colors.orange.shade100,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Done',
                        allTasks.where((t) => t.isCompleted).length.toString(),
                        Icons.check_circle,
                        Colors.green.shade100,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.grey.shade100,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Tasks', 0),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', 1),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed', 2),
                      const SizedBox(width: 8),
                      _buildFilterChip('Today', 3),
                    ],
                  ),
                ),
              ),

              // Tasks List
              Expanded(
                child: displayTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedView == 3
                                  ? 'No tasks for today! 🎉'
                                  : _selectedView == 2
                                      ? 'No completed tasks yet'
                                      : _selectedView == 1
                                          ? 'All tasks completed! 🌟'
                                          : 'No tasks assigned yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayTasks.length,
                        itemBuilder: (context, index) {
                          final task = displayTasks[index];
                          return _buildTaskCard(task, authService, currentDay);
                        },
                      ),
              ),
            ],
          );
        },
      );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.child.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.child.name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.child.age} years old',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // Profile Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileCard(
                  icon: Icons.cake,
                  title: 'Age',
                  value: '${widget.child.age} years',
                  color: Colors.pink,
                ),
                const SizedBox(height: 12),
                _buildProfileCard(
                  icon: Icons.calendar_today,
                  title: 'Joined',
                  value: DateFormat('MMMM dd, yyyy').format(widget.child.dateAdded),
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
                Consumer<AuthService>(
                  builder: (context, authService, child) {
                    final tasks = authService.getTasksForChild(widget.child.id);
                    final completedTasks = tasks.where((t) => t.isCompleted).length;
                    final completionRate = tasks.isEmpty
                        ? 0
                        : ((completedTasks / tasks.length) * 100).toInt();

                    final stats = authService.getChildStats(widget.child.id);
                    final totalPoints = stats['totalPoints'] as int;
                    final monthlyPoints = stats['monthlyPoints'] as int;

                    return Column(
                      children: [
                        _buildProfileCard(
                          icon: Icons.stars,
                          title: 'Total Points',
                          value: '$totalPoints',
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 12),
                        _buildProfileCard(
                          icon: Icons.emoji_events,
                          title: 'This Month Points',
                          value: '$monthlyPoints',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildProfileCard(
                          icon: Icons.task_alt,
                          title: 'Total Tasks',
                          value: '${tasks.length}',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildProfileCard(
                          icon: Icons.check_circle,
                          title: 'Completed Tasks',
                          value: '$completedTasks',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildProfileCard(
                          icon: Icons.bar_chart,
                          title: 'Completion Rate',
                          value: '$completionRate%',
                          color: Colors.purple,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        _buildSettingsSection('Preferences'),
        _buildSettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          subtitle: 'Manage task reminders',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications - Coming Soon')),
            );
          },
        ),
        _buildSettingsTile(
          icon: Icons.dark_mode_outlined,
          title: 'Theme',
          subtitle: 'Light mode',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Theme Settings - Coming Soon')),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildSettingsSection('Activity'),
        _buildSettingsTile(
          icon: Icons.history,
          title: 'My Activity',
          subtitle: 'View your task history',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ActivityLogsScreen(childId: widget.child.id),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildSettingsSection('About'),
        _buildSettingsTile(
          icon: Icons.help_outline,
          title: 'Help',
          subtitle: 'Get help and support',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Help - Coming Soon')),
            );
          },
        ),
        _buildSettingsTile(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and info',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Child Activity App',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.child_care, size: 48),
              children: const [
                Text('A fun way to track and manage daily activities!'),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _buildSettingsSection('Account'),
        _buildSettingsTile(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Return to profile selection',
          color: Colors.red,
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const ChildLoginScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final tileColor = color ?? Colors.black87;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: tileColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: tileColor,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedView == index;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedView = index;
        });
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.white,
      elevation: isSelected ? 4 : 0,
    );
  }

  Widget _buildTaskCard(Task task, AuthService authService, String currentDay) {
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

    final categoryIcons = {
      'Study': Icons.school,
      'Exercise': Icons.fitness_center,
      'Vocabulary': Icons.library_books,
      'New Learning': Icons.lightbulb,
      'Reading': Icons.menu_book,
      'Homework': Icons.assignment,
      'Creative Activity': Icons.palette,
      'Life Skills': Icons.handyman,
    };

    final color = categoryColors[task.category] ?? Colors.grey;
    final icon = categoryIcons[task.category] ?? Icons.task;
    final isToday = task.days.contains(currentDay);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isToday
            ? BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          _showTaskDetails(task, authService, color, icon, currentDay);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  value: task.isCompletedForDay(currentDay),
                  onChanged: (value) {
                    authService.toggleTaskCompletion(task.id, 'child', specificDay: currentDay);
                  },
                  activeColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Category Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),

              // Task Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'TODAY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (isToday) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          task.category,
                          style: TextStyle(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '${task.points}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.days.join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(
    Task task,
    AuthService authService,
    Color color,
    IconData icon,
    String currentDay,
  ) {
    final isToday = task.days.contains(currentDay);
    
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 36),
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
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: task.isCompletedForDay(currentDay)
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    task.isCompletedForDay(currentDay) ? Icons.check_circle : Icons.pending,
                    size: 20,
                    color: task.isCompletedForDay(currentDay) ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.isCompletedForDay(currentDay) ? 'Completed' : 'Pending',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: task.isCompletedForDay(currentDay) ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Today Badge
            if (isToday) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.today, color: Colors.orange),
                    const SizedBox(width: 12),
                    const Text(
                      'This task is scheduled for today!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Scheduled Days
            Row(
              children: [
                const Text(
                  'Scheduled Days:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (task.days.length > 1) ...[
                  const SizedBox(width: 8),
                  Text(
                    '${task.completedDaysCount}/${task.days.length} completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.days.map((day) {
                final isDayToday = day == currentDay;
                final isDayCompleted = task.isCompletedForDay(day);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDayCompleted
                        ? Colors.green
                        : isDayToday 
                            ? Colors.orange 
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: isDayToday && !isDayCompleted
                        ? Border.all(color: Colors.orange.shade700, width: 2)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDayCompleted)
                        const Icon(Icons.check, color: Colors.white, size: 16),
                      if (isDayCompleted) const SizedBox(width: 4),
                      Text(
                        day,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: (isDayToday || isDayCompleted) ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  authService.toggleTaskCompletion(task.id, 'child', specificDay: currentDay);
                  Navigator.pop(context);
                },
                icon: Icon(
                  task.isCompletedForDay(currentDay) ? Icons.undo : Icons.check_circle,
                ),
                label: Text(
                  task.isCompletedForDay(currentDay) ? 'Mark as Pending' : 'Mark as Complete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
