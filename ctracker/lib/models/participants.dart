// ignore_for_file: non_constant_identifier_names

class Participant {
  String? id;
  String name;
  String? email;
  String? number;
  String? created_by;
  String? updated_by;

  Participant(
      {this.id,
      required this.name,
      this.email,
      this.number,
      this.created_by,
      this.updated_by});
}
