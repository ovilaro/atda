# ATDA — Things-like ToDo App

## Overview

A basic clone of the iOS Things app built with Flutter. Two-tab layout: **Today** (tasks marked for today) and **Tasks** (full inbox with collapsible Completed/Trash groups).

## Project Structure

```
lib/
  main.dart                    — App entry point, UI widgets
  provider/
    todo_provider.dart         — State management (ChangeNotifier + Provider)
```

## Architecture

- **State management**: `provider` package with `ChangeNotifier`
- **Model**: `TodoModel` (equatable) with fields: `id`, `text`, `completed`, `isToday`, `deleted`, `deletedAt`
- **Provider**: `TodoProvider` exposes filtered lists and mutation methods

## Key Files

### `lib/provider/todo_provider.dart`

| Getter | Description |
|---|---|
| `tasks` | All tasks (unmodifiable) |
| `activeTasks` | Not completed, not deleted |
| `completedTasks` | Completed, not deleted |
| `deletedTasks` | Deleted, sorted by `deletedAt` descending |

| Method | Description |
|---|---|
| `addTask(text)` | Inserts at index 0, `isToday: false` |
| `toggleCompletion(id)` | Toggles `completed` |
| `deleteTask(id)` | Soft delete — sets `deleted: true`, `deletedAt: now` |
| `restoreTask(id)` | Sets `deleted: false`, `deletedAt: null` |
| `toggleToday(id)` | Toggles `isToday` |
| `updateTaskText(id, text)` | Edits task text |
| `reorderActiveTask(oldIndex, newIndex)` | Reorders within active tasks only |

### `lib/main.dart`

| Widget | Description |
|---|---|
| `AppFrame` | Root — `TabController` with 2 tabs, wraps `ChangeNotifierProvider` |
| `_TodayTab` | Shows date header + active tasks where `isToday == true` |
| `_TasksTab` | Input field + `ReorderableListView` (active tasks) + collapsible Completed/Trash |
| `_CollapsibleSection` | Reusable expand/collapse widget for Completed and Trash groups |

## Conventions

- All widget classes are private (`_` prefix)
- `TodoModel` is immutable — mutations create new instances via reconstruction
- `TodoProvider` always calls `notifyListeners()` after every mutation
- New tasks start with `isToday: false` — user must explicitly add to Today via the calendar icon
- Active tasks use `ReorderableListView` with drag handles (6-dot icon); Completed/Trash are not reorderable
- Delete is soft — tasks go to Trash where they can be restored
- No permanent delete UI yet

## Dependencies

- `flutter` (SDK)
- `cupertino_icons`
- `equatable` — value equality for `TodoModel`
- `provider` — state management

## Commands

```sh
flutter pub get          # Install dependencies
dart analyze             # Static analysis
flutter build apk --debug  # Build Android APK
flutter build ios --debug  # Build iOS (macOS only)
```
