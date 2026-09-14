import 'package:flutter/material.dart';
import '../models/note.dart';

class NotesColumn extends StatelessWidget {
  final String title;
  final List<Note> notes;
  final String status;
  final Color color;
  final VoidCallback? onAdd;
  final ValueChanged<Note>? onNoteDropped;
  final bool Function(Note)? isNoteUpdating;

  const NotesColumn({
    super.key,
    required this.title,
    required this.notes,
    required this.status,
    required this.color,
    this.onAdd,
    this.onNoteDropped,
    this.isNoteUpdating,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Se usa Expanded para evitar desbordamiento
      child: DragTarget<Note>(
        onWillAcceptWithDetails: (details) {
          final note = details.data;
          return note.status != status &&
              !(isNoteUpdating?.call(note) ?? false);
        },
        onAcceptWithDetails: (details) => onNoteDropped?.call(details.data),
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título de la columna
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Lista de notas
                Expanded(
                  child: ListView(
                    children:
                        notes.map((note) => _buildDraggableCard(note)).toList(),
                  ),
                ),

                // Botón de agregar nota (Solo si `onAdd` no es nulo)
                if (onAdd != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: FloatingActionButton(
                      onPressed: onAdd,
                      mini: true, // Hace el botón más pequeño
                      backgroundColor: color,
                      child: const Icon(Icons.add),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDraggableCard(Note note) {
    final isUpdating = isNoteUpdating?.call(note) ?? false;

    return Draggable<Note>(
      key: ValueKey(note.id),
      data: note,
      maxSimultaneousDrags: isUpdating ? 0 : 1,
      feedback: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: _noteCard(note, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _noteCard(note),
      ),
      child: Opacity(
        opacity: isUpdating ? 0.6 : 1,
        child: _noteCard(note),
      ),
    );
  }

  Widget _noteCard(Note note, {bool isDragging = false}) {
    return Card(
      elevation: isDragging ? 6 : 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(note.description),
          ],
        ),
      ),
    );
  }
}
