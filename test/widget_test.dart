import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/notes_screen.dart';
import 'package:notes_app/services/api_service.dart';
import 'package:notes_app/widgets/notes_column.dart';

class FakeApiService extends ApiService {
  FakeApiService(this.notes);

  final List<Note> notes;
  final List<Completer<dynamic>> pendingUpdates = [];
  int updateCalls = 0;

  @override
  Future<dynamic> get(String endpoint) async {
    return notes
        .map((note) => {
              'id': note.id,
              'userId': note.userId,
              'createdAt': note.createdAt,
              'title': note.title,
              'description': note.description,
              'status': note.status,
            })
        .toList();
  }

  @override
  Future<dynamic> put(
    String url,
    Map<String, dynamic> data, {
    Map<String, dynamic>? queryParameters,
  }) {
    updateCalls++;
    final completer = Completer<dynamic>();
    pendingUpdates.add(completer);
    return completer.future;
  }
}

void main() {
  final note = Note(
    id: 1,
    userId: 10,
    createdAt: '2026-09-14T12:00:00Z',
    title: 'english class',
    description: 'Repasar los verbos en ingles',
    status: 'NEW',
  );

  DragTarget<Note> dragTargetAt(WidgetTester tester, int index) {
    return tester
        .widgetList<DragTarget<Note>>(find.byType(DragTarget<Note>))
        .elementAt(index);
  }

  List<Note> notesInColumn(WidgetTester tester, int index) {
    return tester
        .widgetList<NotesColumn>(find.byType(NotesColumn))
        .elementAt(index)
        .notes;
  }

  testWidgets('a note cannot be duplicated while its status is updating',
      (tester) async {
    final apiService = FakeApiService([note]);

    await tester.pumpWidget(
      MaterialApp(home: NotesScreen(apiService: apiService)),
    );
    await tester.pumpAndSettle();

    dragTargetAt(tester, 1).onAcceptWithDetails!(
      DragTargetDetails(data: note, offset: Offset.zero),
    );
    await tester.pump();

    expect(apiService.updateCalls, 1);
    expect(notesInColumn(tester, 0), isEmpty);
    expect(notesInColumn(tester, 1).map((note) => note.id), [1]);
    expect(find.text('english class'), findsOneWidget);

    dragTargetAt(tester, 2).onAcceptWithDetails!(
      DragTargetDetails(data: note, offset: Offset.zero),
    );
    await tester.pump();

    expect(apiService.updateCalls, 1);
    expect(find.text('english class'), findsOneWidget);

    apiService.pendingUpdates.single.complete({});
    await tester.pumpAndSettle();
  });

  testWidgets('moving repeatedly keeps one note in exactly one column',
      (tester) async {
    final apiService = FakeApiService([note]);

    await tester.pumpWidget(
      MaterialApp(home: NotesScreen(apiService: apiService)),
    );
    await tester.pumpAndSettle();

    dragTargetAt(tester, 1).onAcceptWithDetails!(
      DragTargetDetails(data: note, offset: Offset.zero),
    );
    await tester.pump();
    apiService.pendingUpdates[0].complete({});
    await tester.pumpAndSettle();

    final processingNote = notesInColumn(tester, 1).single;
    dragTargetAt(tester, 2).onAcceptWithDetails!(
      DragTargetDetails(data: processingNote, offset: Offset.zero),
    );
    await tester.pump();
    apiService.pendingUpdates[1].complete({});
    await tester.pumpAndSettle();

    expect(notesInColumn(tester, 0), isEmpty);
    expect(notesInColumn(tester, 1), isEmpty);
    expect(notesInColumn(tester, 2).map((note) => note.id), [1]);
    expect(find.text('english class'), findsOneWidget);
  });

  testWidgets('a failed update restores the note to its original column',
      (tester) async {
    final apiService = FakeApiService([note]);

    await tester.pumpWidget(
      MaterialApp(home: NotesScreen(apiService: apiService)),
    );
    await tester.pumpAndSettle();

    dragTargetAt(tester, 1).onAcceptWithDetails!(
      DragTargetDetails(data: note, offset: Offset.zero),
    );
    await tester.pump();
    apiService.pendingUpdates.single.completeError('network error');
    await tester.pumpAndSettle();

    expect(notesInColumn(tester, 0).map((note) => note.id), [1]);
    expect(notesInColumn(tester, 1), isEmpty);
    expect(notesInColumn(tester, 2), isEmpty);
    expect(find.text('english class'), findsOneWidget);
  });
}
