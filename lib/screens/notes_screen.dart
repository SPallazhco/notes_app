import 'package:flutter/material.dart';
import 'package:notes_app/config/app_routes.dart';
import 'package:notes_app/services/auth_service.dart';
import '../services/api_service.dart';
import '../models/note.dart';
import '../widgets/add_note_modal.dart';
import '../widgets/notes_column.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  late Future<List<Note>> _notesFuture;

  List<Note> newNotes = [];
  List<Note> processingNotes = [];
  List<Note> archivedNotes = [];

  @override
  void initState() {
    super.initState();
    _notesFuture = fetchNotes();
  }

  Future<List<Note>> fetchNotes() async {
    try {
      final List<dynamic> response = await _apiService.get('/notes');
      List<Note> notes = response.map((json) => Note.fromJson(json)).toList();

      setState(() {
        newNotes = notes.where((note) => note.status == 'NEW').toList();
        processingNotes =
            notes.where((note) => note.status == 'PROCESSING').toList();
        archivedNotes =
            notes.where((note) => note.status == 'ARCHIVED').toList();
      });

      return notes;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al obtener notas ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }

  Future<void> _updateNoteStatus(Note note, String newStatus) async {
    try {
      await _apiService.put('/notes/${note.id}/status', {},
          queryParameters: {'status': newStatus});

      setState(() {
        newNotes.remove(note);
        processingNotes.remove(note);
        archivedNotes.remove(note);

        note = note.copyWith(status: newStatus);

        if (newStatus == 'NEW') {
          newNotes.add(note);
        } else if (newStatus == 'PROCESSING') {
          processingNotes.add(note);
        } else if (newStatus == 'ARCHIVED') {
          archivedNotes.add(note);
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al actualizar nota ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addNote(String title, String description) async {
    try {
      final response = await _apiService.post('/notes', {}, queryParameters: {
        'title': title,
        'description': description,
      });

      if (response != null) {
        setState(() {
          newNotes.add(Note.fromJson(response));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al agregar nota: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddNoteModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AddNoteModal(
          onNoteAdded: (title, description) => _addNote(title, description),
        );
      },
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    // Navegar a la pantalla de inicio de sesión
    if (mounted) {
      Navigator.popAndPushNamed(context, AppRoutes.login);
    }
  }

  void _navigateToProfile() {
    // Navigator.pushNamed(
    //   context,
    //   AppRoutes.editProfile,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'profile') {
                _navigateToProfile();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Editar perfil'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar notas"));
          } else {
            return Row(
              children: [
                NotesColumn(
                  title: 'Nuevas',
                  notes: newNotes,
                  color: Colors.blue,
                  onAdd: _showAddNoteModal,
                  onNoteDropped: (note) => _updateNoteStatus(note, 'NEW'),
                ),
                NotesColumn(
                  title: 'En proceso',
                  notes: processingNotes,
                  color: Colors.orange,
                  onNoteDropped: (note) =>
                      _updateNoteStatus(note, 'PROCESSING'),
                ),
                NotesColumn(
                  title: 'Archivadas',
                  notes: archivedNotes,
                  color: Colors.green,
                  onNoteDropped: (note) => _updateNoteStatus(note, 'ARCHIVED'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
