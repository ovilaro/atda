import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/todo_provider.dart';

class AppFrame extends StatefulWidget {
  const AppFrame({super.key});

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> with SingleTickerProviderStateMixin {
  late final TabController tab;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: tab,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Tasks'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: tab,
            children: const [
              _TodayTab(),
              _TasksTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        final todayTasks = provider.tasks.where((t) => t.isToday && !t.completed && !t.deleted).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                children: [
                  Text(
                    days[now.weekday - 1],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${months[now.month - 1]} ${now.day}, ${now.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: todayTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: Colors.blue[300]),
                          const SizedBox(height: 16),
                          Text(
                            'Nothing to do today',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add tasks and mark them for today in the Tasks tab',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: todayTasks.length,
                      itemBuilder: (context, index) {
                        final task = todayTasks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                task.completed ? Icons.check_circle : Icons.circle_outlined,
                                color: task.completed ? Colors.green : Colors.grey[400],
                              ),
                              onPressed: () => provider.toggleCompletion(task.id),
                            ),
                            title: Text(
                              task.text,
                              style: TextStyle(
                                decoration: task.completed ? TextDecoration.lineThrough : null,
                                color: task.completed ? Colors.grey : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                              onPressed: () => provider.deleteTask(task.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _TasksTab extends StatefulWidget {
  const _TasksTab();

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_controller.text.trim().isEmpty) return;
    context.read<TodoProvider>().addTask(_controller.text.trim());
    _controller.clear();
  }

  Widget _activeTaskTile(TodoModel task, TodoProvider provider, int index) {
    return Card(
      key: ValueKey(task.id),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.drag_handle, color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  task.completed ? Icons.check_circle : Icons.circle_outlined,
                  color: task.completed ? Colors.green : Colors.grey[400],
                ),
                onPressed: () => provider.toggleCompletion(task.id),
              ),
              title: Text(task.text),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      task.isToday ? Icons.today : Icons.today_outlined,
                      color: task.isToday ? Colors.blue : Colors.grey[400],
                    ),
                    tooltip: task.isToday ? 'Remove from Today' : 'Add to Today',
                    onPressed: () => provider.toggleToday(task.id),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                    onPressed: () => provider.deleteTask(task.id),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completedTaskTile(TodoModel task, TodoProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => provider.toggleCompletion(task.id),
        ),
        title: Text(
          task.text,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                task.isToday ? Icons.today : Icons.today_outlined,
                color: task.isToday ? Colors.blue : Colors.grey[400],
              ),
              tooltip: task.isToday ? 'Remove from Today' : 'Add to Today',
              onPressed: () => provider.toggleToday(task.id),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              onPressed: () => provider.deleteTask(task.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deletedTaskTile(TodoModel task, TodoProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(
          task.text,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore_from_trash_outlined),
              tooltip: 'Restore',
              onPressed: () => provider.restoreTask(task.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'New task...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addTask,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<TodoProvider>(
            builder: (context, provider, _) {
              final active = provider.activeTasks;
              final completed = provider.completedTasks;
              final deleted = provider.deletedTasks;

              if (active.isEmpty && completed.isEmpty && deleted.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks yet',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a task above to get started',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  if (active.isNotEmpty)
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      buildDefaultDragHandles: false,
                      itemCount: active.length,
                      onReorderItem: (oldIndex, newIndex) => provider.reorderActiveTask(oldIndex, newIndex),
                      itemBuilder: (context, index) => _activeTaskTile(active[index], provider, index),
                    ),
                  if (completed.isNotEmpty)
                    _CollapsibleSection(
                      title: 'Completed (${completed.length})',
                      children: completed.map((t) => _completedTaskTile(t, provider)).toList(),
                    ),
                  if (deleted.isNotEmpty)
                    _CollapsibleSection(
                      title: 'Trash (${deleted.length})',
                      children: deleted.map((t) => _deletedTaskTile(t, provider)).toList(),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CollapsibleSection extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const _CollapsibleSection({required this.title, required this.children});

  @override
  State<_CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<_CollapsibleSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...widget.children,
      ],
    );
  }
}

void main() => runApp(const AppFrame());