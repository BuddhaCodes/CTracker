import 'package:ctracker/models/participants.dart';

abstract class ParticipantRepository {
  Future<List<Participant>> getAllParticipants();
}
