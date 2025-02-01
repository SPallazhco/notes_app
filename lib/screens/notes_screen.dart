import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<String> newNotes = ['Nota 1', 'Nota 2', 'Nota 3'];
  List<String> processingNotes = [];
  List<String> archivedNotes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          _buildNotesColumn('Nuevas', newNotes, Colors.blue, Icons.add, (note) {
            setState(() {
              newNotes.add(note);
            });
          }),
          _buildNotesColumn(
              'En proceso', processingNotes, Colors.orange, null, null),
          _buildNotesColumn(
              'Archivadas', archivedNotes, Colors.green, null, null),
        ],
      ),
    );
  }

  Widget _buildNotesColumn(
    String title,
    List<String> notes,
    Color color,
    IconData? icon,
    void Function(String)? onAdd, // Ahora la función recibe un String
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                if (icon != null)
                  IconButton(
                    icon: Icon(icon, color: Colors.white),
                    onPressed: () {
                      if (onAdd != null) {
                        onAdd(
                            "Nueva Nota"); // Se llama correctamente a la función
                      }
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(notes[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
