import 'package:ctracker/models/sticky_notes.dart';

abstract class StickyNoteRepository {
  Future<List<StickyNotes>> getAllStickyNotes();
  Future<StickyNotes> addStickyNote(StickyNotes note);
  Future<void> deleteStickyNote(String id);
  Future<void> updateStickyNote(String id, StickyNotes note);
}
