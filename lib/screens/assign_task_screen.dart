import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/child.dart';

class AssignTaskScreen extends StatefulWidget {
  final String category;
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  const AssignTaskScreen({
    super.key,
    required this.category,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  Child? _selectedChild;
  final Set<String> _selectedChildren = {}; // For multiple children
  final Set<String> _selectedDays = {};
  String _selectedPriority = 'medium';
  bool _assignToMultiple = false;

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void dispose() {
    _taskController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _assignTask() async {
    // Check if using multiple or single selection
    final hasSelection = _assignToMultiple 
        ? _selectedChildren.isNotEmpty 
        : _selectedChild != null;
    
    if (_formKey.currentState!.validate() && 
        hasSelection && 
        _selectedDays.isNotEmpty) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final points = int.tryParse(_pointsController.text) ?? 10;
      
      if (_assignToMultiple) {
        // Assign to multiple children
        for (var childId in _selectedChildren) {
          await authService.addTask(
            _taskController.text.trim(),
            widget.category,
            childId,
            _selectedDays.toList(),
            priority: _selectedPriority,
            points: points,
          );
        }
        
        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task assigned to ${_selectedChildren.length} children!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Assign to single child
        await authService.addTask(
          _taskController.text.trim(),
          widget.category,
          _selectedChild!.id,
          _selectedDays.toList(),
          priority: _selectedPriority,
          points: points,
        );

        if (!mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task assigned to ${_selectedChild!.name}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (!hasSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_assignToMultiple 
              ? 'Please select at least one child' 
              : 'Please select a child'),
          backgroundColor: Colors.orange,
        ),
      );
    } else if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign ${widget.categoryTitle}'),
        centerTitle: true,
      ),
      body: Consumer<AuthService>(
        builder: (context, authService, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.categoryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.categoryIcon,
                          color: widget.categoryColor,
                          size: 40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.categoryTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: widget.categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Task Description
                  Text(
                    'Task Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Task Description',
                      hintText: 'e.g., Complete math homework',
                      prefixIcon: const Icon(Icons.edit),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter task details';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Select Child
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Child',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Multiple',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          Switch(
                            value: _assignToMultiple,
                            onChanged: (value) {
                              setState(() {
                                _assignToMultiple = value;
                                if (!value) {
                                  _selectedChildren.clear();
                                } else {
                                  _selectedChild = null;
                                }
                              });
                            },
                            activeColor: widget.categoryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...authService.children.map((child) {
                    final isSelected = _assignToMultiple 
                        ? _selectedChildren.contains(child.id)
                        : _selectedChild?.id == child.id;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected
                          ? widget.categoryColor.withOpacity(0.1)
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? widget.categoryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: widget.categoryColor.withOpacity(0.2),
                          child: Text(
                            child.name[0].toUpperCase(),
                            style: TextStyle(
                              color: widget.categoryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(child.name),
                        subtitle: Text('Age: ${child.age}'),
                        trailing: isSelected
                            ? Icon(
                                _assignToMultiple ? Icons.check_box : Icons.check_circle, 
                                color: widget.categoryColor,
                              )
                            : Icon(_assignToMultiple ? Icons.check_box_outline_blank : Icons.circle_outlined),
                        onTap: () {
                          setState(() {
                            if (_assignToMultiple) {
                              // Toggle selection for multiple
                              if (_selectedChildren.contains(child.id)) {
                                _selectedChildren.remove(child.id);
                              } else {
                                _selectedChildren.add(child.id);
                              }
                            } else {
                              // Single selection
                              _selectedChild = child;
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                  
                  // Selection summary
                  if (_assignToMultiple && _selectedChildren.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${_selectedChildren.length} ${_selectedChildren.length == 1 ? "child" : "children"} selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: widget.categoryColor,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),

                  // Priority Selection
                  Text(
                    'Task Priority',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriorityChip('Low', Colors.green),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPriorityChip('Medium', Colors.orange),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPriorityChip('High', Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Points Input
                  Text(
                    'Points',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter points (e.g., 10, 20, 50)',
                      prefixIcon: Icon(Icons.stars, color: widget.categoryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: widget.categoryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter points';
                      }
                      final points = int.tryParse(value);
                      if (points == null || points < 1) {
                        return 'Please enter a valid number (minimum 1)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Select Days
                  Text(
                    'Select Days',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _weekDays.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                        selectedColor: widget.categoryColor.withOpacity(0.3),
                        checkmarkColor: widget.categoryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? widget.categoryColor : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Assign Button
                  ElevatedButton(
                    onPressed: _assignTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.categoryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Assign Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityChip(String label, Color color) {
    final isSelected = _selectedPriority == label.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = label.toLowerCase();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              label == 'Low' ? Icons.arrow_downward :
              label == 'Medium' ? Icons.remove :
              Icons.arrow_upward,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
