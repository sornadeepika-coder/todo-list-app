import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

/// Simple Task Data Model
class Task {
  final String id;
  String title;
  bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Task Filter Options
enum TaskFilter { all, active, completed }

/// Root Application Widget with Modern Blue & White Theme
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color lightBg = Color(0xFFF5F8FC);
  static const Color slateDark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow - To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: lightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: darkBlue,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const TodoListScreen(),
    );
  }
}

/// Main Screen for the To-Do List App
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  TaskFilter _currentFilter = TaskFilter.all;
  String? _errorMessage;

  // Initial tasks showing functional preview
  final List<Task> _tasks = [
    Task(
      id: 'task_1',
      title: 'Review project requirements & specifications',
      isCompleted: true,
    ),
    Task(
      id: 'task_2',
      title: 'Complete Internship Project 03 - To-Do App',
      isCompleted: false,
    ),
    Task(
      id: 'task_3',
      title: 'Test swipe-to-delete and input validation',
      isCompleted: false,
    ),
  ];

  @override
  void dispose() {
    _taskController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Dynamic remaining tasks count
  int get _remainingCount =>
      _tasks.where((task) => !task.isCompleted).length;

  int get _completedCount =>
      _tasks.where((task) => task.isCompleted).length;

  // Filtered list based on selected filter tab
  List<Task> get _filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.active:
        return _tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.all:
        return _tasks;
    }
  }

  // Requirement 1 & 10: Add task with input validation
  void _addTask() {
    final text = _taskController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Task title cannot be empty.';
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task name before adding.'),
          backgroundColor: Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _tasks.insert(
        0,
        Task(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: text,
          isCompleted: false,
        ),
      );
      _taskController.clear();
      _errorMessage = null;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Task added successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF1E88E5),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Requirement 3 & 4: Toggle task completion
  void _toggleTask(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  }

  // Requirement 5: Delete task with Dismissible / button & Undo support
  void _deleteTask(Task task) {
    final taskIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (taskIndex == -1) return;

    final removedTask = _tasks[taskIndex];

    setState(() {
      _tasks.removeAt(taskIndex);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removedTask.title}"'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amberAccent,
          onPressed: () {
            setState(() {
              _tasks.insert(taskIndex, removedTask);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Clear all completed tasks
  void _clearCompleted() {
    final completedItems = _tasks.where((t) => t.isCompleted).toList();
    if (completedItems.isEmpty) return;

    setState(() {
      _tasks.removeWhere((t) => t.isCompleted);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cleared ${completedItems.length} completed task(s)'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.amberAccent,
          onPressed: () {
            setState(() {
              _tasks.addAll(completedItems);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double completionRatio =
        _tasks.isEmpty ? 0.0 : (_completedCount / _tasks.length);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, size: 26),
            SizedBox(width: 10),
            Text(
              'TaskFlow',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          if (_completedCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                key: const Key('clear_completed_button'),
                onPressed: _clearCompleted,
                icon: const Icon(
                  Icons.cleaning_services_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Clear Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // Requirement 6: Dynamic remaining tasks & progress overview
                _buildSummaryCard(completionRatio),

                // Requirement 1 & 10: Input text field and Add button with validation
                _buildInputSection(),

                // Category filter chips (All / Active / Completed)
                if (_tasks.isNotEmpty) _buildFilterSection(),

                // Requirement 2 & 7: Tasks ListView or Empty-State Message
                Expanded(
                  child: _filteredTasks.isEmpty
                      ? _buildEmptyState()
                      : _buildTaskList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern blue overview card showing dynamic remaining count and progress
  Widget _buildSummaryCard(double completionRatio) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WORKSPACE OVERVIEW',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _remainingCount == 0 && _tasks.isNotEmpty
                        ? 'All tasks completed! 🎉'
                        : '$_remainingCount ${_remainingCount == 1 ? "task" : "tasks"} remaining',
                    key: const Key('remaining_count_text'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${_tasks.isEmpty ? 0 : (_completedCount / _tasks.length * 100).toInt()}% Done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionRatio,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${_tasks.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Completed: $_completedCount',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Input field with validation and Add button
  Widget _buildInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('task_input_field'),
                    controller: _taskController,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _addTask(),
                    onChanged: (val) {
                      if (_errorMessage != null && val.trim().isNotEmpty) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'What needs to be done?',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        color: Color(0xFF1E88E5),
                        size: 26,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  key: const Key('add_task_button'),
                  onPressed: _addTask,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text(
                    'Add',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 14, bottom: 6, top: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFD32F2F),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _errorMessage!,
                      key: const Key('error_message_text'),
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

  /// Modern filter chips: All, Active, Completed
  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All (${_tasks.length})',
            filter: TaskFilter.all,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Active ($_remainingCount)',
            filter: TaskFilter.active,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Completed ($_completedCount)',
            filter: TaskFilter.completed,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required TaskFilter filter,
  }) {
    final bool isSelected = _currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _currentFilter = filter;
        });
      },
      selectedColor: const Color(0xFF1E88E5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFE2E8F0),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      showCheckmark: false,
    );
  }

  /// Requirement 2 & 5: ListView of tasks with Dismissible swipe-to-delete
  Widget _buildTaskList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      itemCount: _filteredTasks.length,
      itemBuilder: (context, index) {
        final task = _filteredTasks[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: ValueKey(task.id),
            direction: DismissDirection.horizontal,
            background: _buildSwipeActionBackground(
              alignment: Alignment.centerLeft,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
            ),
            secondaryBackground: _buildSwipeActionBackground(
              alignment: Alignment.centerRight,
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
            ),
            onDismissed: (_) {
              _deleteTask(task);
            },
            child: _buildTaskCard(task),
          ),
        );
      },
    );
  }

  /// Modern swipe background indicator
  Widget _buildSwipeActionBackground({
    required Alignment alignment,
    required IconData icon,
    required String label,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Requirement 3, 4 & 8: Clean task card with rounded corners, checkbox & strikethrough text
  Widget _buildTaskCard(Task task) {
    final bool isCompleted = task.isCompleted;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFE2E8F0).withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleTask(task),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Checkbox
                Transform.scale(
                  scale: 1.15,
                  child: Checkbox(
                    key: Key('checkbox_${task.id}'),
                    value: isCompleted,
                    activeColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: const BorderSide(
                      color: Color(0xFF94A3B8),
                      width: 1.8,
                    ),
                    onChanged: (_) => _toggleTask(task),
                  ),
                ),
                const SizedBox(width: 8),

                // Task title with strikethrough if completed
                Expanded(
                  child: Text(
                    task.title,
                    key: Key('title_${task.id}'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isCompleted ? FontWeight.w400 : FontWeight.w500,
                      color: isCompleted
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: const Color(0xFF94A3B8),
                      decorationThickness: 2.0,
                    ),
                  ),
                ),

                // Delete action button (convenient for desktop / mouse users)
                IconButton(
                  key: Key('delete_btn_${task.id}'),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFF94A3B8),
                    size: 22,
                  ),
                  tooltip: 'Delete task',
                  splashRadius: 20,
                  onPressed: () => _deleteTask(task),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Requirement 7: Friendly empty-state message
  Widget _buildEmptyState() {
    final bool hasFilter = _currentFilter != TaskFilter.all;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF90CAF9).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Icon(
                hasFilter ? Icons.filter_alt_off_rounded : Icons.task_alt_rounded,
                size: 64,
                color: const Color(0xFF1E88E5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilter ? 'No matching tasks' : 'All caught up!',
              key: const Key('empty_state_title'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'There are no ${_currentFilter.name} tasks to display.'
                  : 'You have no tasks in your list.\nAdd a task above to plan your day!',
              key: const Key('empty_state_subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
