import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list_app/main.dart';

void main() {
  testWidgets('Renders To-Do app with initial tasks and remaining count',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Verify app title
    expect(find.text('TaskFlow'), findsOneWidget);

    // Verify initial remaining count
    expect(find.byKey(const Key('remaining_count_text')), findsOneWidget);
    expect(find.text('2 tasks remaining'), findsOneWidget);

    // Verify initial tasks exist in the list
    expect(
        find.text('Review project requirements & specifications'), findsOneWidget);
    expect(find.text('Complete Internship Project 03 - To-Do App'),
        findsOneWidget);
  });

  testWidgets('Input validation prevents adding empty or whitespace tasks',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Tap Add button with empty input field
    await tester.tap(find.byKey(const Key('add_task_button')));
    await tester.pumpAndSettle();

    // Verify error message is shown
    expect(find.byKey(const Key('error_message_text')), findsOneWidget);
    expect(find.text('Task title cannot be empty.'), findsOneWidget);

    // Enter only whitespace
    await tester.enterText(find.byKey(const Key('task_input_field')), '   ');
    await tester.tap(find.byKey(const Key('add_task_button')));
    await tester.pumpAndSettle();

    // Still should show validation error
    expect(find.text('Task title cannot be empty.'), findsOneWidget);
  });

  testWidgets('Adds a new task successfully using text field and Add button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Initial remaining count is 2
    expect(find.text('2 tasks remaining'), findsOneWidget);

    // Enter a valid task
    await tester.enterText(
        find.byKey(const Key('task_input_field')), 'Submit final internship report');
    await tester.tap(find.byKey(const Key('add_task_button')));
    await tester.pumpAndSettle();

    // Verify task is added to the list
    expect(find.text('Submit final internship report'), findsOneWidget);

    // Verify remaining count increments dynamically from 2 to 3
    expect(find.text('3 tasks remaining'), findsOneWidget);

    // Verify input field is cleared
    final textFinder = find.byKey(const Key('task_input_field'));
    final TextField textField = tester.widget<TextField>(textFinder);
    expect(textField.controller?.text, isEmpty);
  });

  testWidgets('Toggles task completion with checkbox and updates strikethrough & count',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // 'task_2' is initially active ('Complete Internship Project 03 - To-Do App')
    expect(find.text('2 tasks remaining'), findsOneWidget);

    // Verify text widget before check
    Text taskText =
        tester.widget<Text>(find.byKey(const Key('title_task_2')));
    expect(taskText.style?.decoration, TextDecoration.none);

    // Tap checkbox for task_2
    await tester.tap(find.byKey(const Key('checkbox_task_2')));
    await tester.pumpAndSettle();

    // Verify strikethrough is applied
    taskText = tester.widget<Text>(find.byKey(const Key('title_task_2')));
    expect(taskText.style?.decoration, TextDecoration.lineThrough);

    // Dynamic remaining count decrements to 1
    expect(find.text('1 task remaining'), findsOneWidget);

    // Untoggle it back
    await tester.tap(find.byKey(const Key('checkbox_task_2')));
    await tester.pumpAndSettle();

    taskText = tester.widget<Text>(find.byKey(const Key('title_task_2')));
    expect(taskText.style?.decoration, TextDecoration.none);
    expect(find.text('2 tasks remaining'), findsOneWidget);
  });

  testWidgets('Deletes a task using Dismissible swipe left or right',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    expect(find.text('Complete Internship Project 03 - To-Do App'),
        findsOneWidget);

    // Swipe left on the dismissible widget
    await tester.drag(
      find.byKey(const ValueKey('task_2')),
      const Offset(-500.0, 0.0),
    );
    await tester.pumpAndSettle();

    // Task is removed from the list
    expect(find.text('Complete Internship Project 03 - To-Do App'),
        findsNothing);

    // Dynamic remaining count is reduced to 1
    expect(find.text('1 task remaining'), findsOneWidget);

    // SnackBar with UNDO is shown
    expect(find.text('UNDO'), findsOneWidget);
  });

  testWidgets('Shows friendly empty state when all tasks are deleted',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Delete all 3 initial tasks using their delete buttons
    while (find.byIcon(Icons.delete_outline_rounded).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pumpAndSettle();
    }

    // Verify empty state is displayed
    expect(find.byKey(const Key('empty_state_title')), findsOneWidget);
    expect(find.text('All caught up!'), findsOneWidget);
    expect(find.text('0 tasks remaining'), findsOneWidget);
  });
}
