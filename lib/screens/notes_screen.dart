import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notes_app/config/app_routes.dart';
import 'package:notes_app/services/auth_service.dart';
import '../services/api_service.dart';
import '../models/note.dart';
import '../widgets/add_note_modal.dart';
import '../widgets/notes_column.dart';

class NotesScreen extends StatefulWidget {
  final ApiService? apiService;

  const NotesScreen({super.key, this.apiService});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final ApiService _apiService;
  final AuthService _authService = AuthService();
  late Future<List<Note>> _notesFuture;
  final Set<int> _updatingNoteIds = {};

  List<Note> newNotes = [];
  List<Note> processingNotes = [];
  List<Note> archivedNotes = [];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _notesFuture = fetchNotes();
  }

  Future<List<Note>> fetchNotes() async {
    try {
      final List<dynamic> response = await _apiService.get('/notes');
      final notes = response.map((json) => Note.fromJson(json)).toList();
      final uniqueNotes = <int, Note>{
        for (final note in notes) note.id: note,
      }.values.toList();

      if (!mounted) {
        return uniqueNotes;
      }

      setState(() {
        newNotes = uniqueNotes.where((note) => note.status == 'NEW').toList();
        processingNotes =
            uniqueNotes.where((note) => note.status == 'PROCESSING').toList();
        archivedNotes =
            uniqueNotes.where((note) => note.status == 'ARCHIVED').toList();
      });

      return uniqueNotes;
    } catch (e) {
      if (!mounted) {
        return [];
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al obtener notas ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }

  void _removeNoteById(int id) {
    newNotes.removeWhere((note) => note.id == id);
    processingNotes.removeWhere((note) => note.id == id);
    archivedNotes.removeWhere((note) => note.id == id);
  }

  void _addNoteToItsColumn(Note note) {
    if (note.status == 'NEW') {
      newNotes.add(note);
    } else if (note.status == 'PROCESSING') {
      processingNotes.add(note);
    } else if (note.status == 'ARCHIVED') {
      archivedNotes.add(note);
    }
  }

  Future<void> _updateNoteStatus(Note note, String newStatus) async {
    if (_updatingNoteIds.contains(note.id) || note.status == newStatus) {
      return;
    }

    final previousNote = note;
    final updatedNote = note.copyWith(status: newStatus);

    setState(() {
      _updatingNoteIds.add(note.id);
      _removeNoteById(note.id);
      _addNoteToItsColumn(updatedNote);
    });

    try {
      await _apiService.put('/notes/${note.id}/status', {},
          queryParameters: {'status': newStatus});
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _removeNoteById(note.id);
        _addNoteToItsColumn(previousNote);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al actualizar nota ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingNoteIds.remove(note.id);
        });
      } else {
        _updatingNoteIds.remove(note.id);
      }
    }
  }

  Future<void> _addNote(String title, String description) async {
    try {
      final response = await _apiService.post('/notes', {}, queryParameters: {
        'title': title,
        'description': description,
      });

      if (!mounted) {
        return;
      }

      if (response != null) {
        final note = Note.fromJson(response);
        setState(() {
          _removeNoteById(note.id);
          _addNoteToItsColumn(note);
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

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
              // const PopupMenuItem(
              //   value: 'profile',
              //   child: Text('Editar perfil'),
              // ),
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
                  status: 'NEW',
                  color: Colors.blue,
                  onAdd: _showAddNoteModal,
                  isNoteUpdating: (note) => _updatingNoteIds.contains(note.id),
                  onNoteDropped: (note) =>
                      unawaited(_updateNoteStatus(note, 'NEW')),
                ),
                NotesColumn(
                  title: 'En proceso',
                  notes: processingNotes,
                  status: 'PROCESSING',
                  color: Colors.orange,
                  isNoteUpdating: (note) => _updatingNoteIds.contains(note.id),
                  onNoteDropped: (note) =>
                      unawaited(_updateNoteStatus(note, 'PROCESSING')),
                ),
                NotesColumn(
                  title: 'Archivadas',
                  notes: archivedNotes,
                  status: 'ARCHIVED',
                  color: Colors.green,
                  isNoteUpdating: (note) => _updatingNoteIds.contains(note.id),
                  onNoteDropped: (note) =>
                      unawaited(_updateNoteStatus(note, 'ARCHIVED')),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
