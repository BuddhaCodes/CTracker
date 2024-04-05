import 'package:ctracker/models/participants.dart';
import 'package:ctracker/repository/participant_repository.dart';
import 'package:pocketbase/pocketbase.dart';

class ParticipantRepositoryImplementation extends ParticipantRepository {
  final PocketBase _pocketBase = PocketBase('http://127.0.0.1:8090');
  @override
  Future<List<Participant>> getAllParticipants() async {
    final records = await _pocketBase.collection('participants').getFullList(
          sort: '-created',
        );

    return records
        .map((e) => Participant(id: e.id, name: e.data["name"]))
        .toList();
  }
}
