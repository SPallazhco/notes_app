import 'package:flutter/material.dart';
import '../models/note.dart';

class NotesColumn extends StatelessWidget {
  final String title;
  final List<Note> notes;
  final Color color;
  final VoidCallback? onAdd;
  final Function(Note)? onNoteDropped;

  const NotesColumn({
    super.key,
    required this.title,
    required this.notes,
    required this.color,
    this.onAdd,
    this.onNoteDropped,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Se usa Expanded para evitar desbordamiento
      child: DragTarget<Note>(
        onAccept: (note) => onNoteDropped?.call(note),
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
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
                      child: const Icon(Icons.add),
                      mini: true, // Hace el botón más pequeño
                      backgroundColor: color,
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
    return Draggable<Note>(
      data: note,
      feedback: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(12),
        child: _noteCard(note, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _noteCard(note),
      ),
      child: _noteCard(note),
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
