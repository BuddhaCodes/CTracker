import 'package:ctracker/models/participants.dart';

abstract class ParticipantRepository {
  Future<List<Participant>> getAllParticipants();
  Future<void> deleteParticipant(String id);
  Future<void> addParticipant(Participant participant);
  Future<void> updateParticipant(String id, Participant participant);
}
