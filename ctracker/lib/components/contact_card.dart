import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/repository/participant_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/utils/utils.dart';
import 'package:ctracker/views/add_contact_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ContactCard extends StatefulWidget {
  final Participant participant;
  int index;
  int selectedTile;
  Function(int) onExpanded;
  VoidCallback onDelete;
  ContactCard(
      {super.key,
      required this.participant,
      required this.index,
      required this.selectedTile,
      required this.onExpanded,
      required this.onDelete});

  @override
  ContactCardState createState() => ContactCardState();
}

class ContactCardState extends State<ContactCard> {
  late ParticipantRepositoryImplementation participantRepo;
  MyLocalizations? localizations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MyLocalizations.of(context);
  }

  @override
  void initState() {
    participantRepo = ParticipantRepositoryImplementation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorP.cardBackground,
      child: ExpansionTile(
        key: UniqueKey(),
        initiallyExpanded: widget.index == widget.selectedTile,
        collapsedIconColor: ColorP.textColor,
        iconColor: ColorP.textColor,
        backgroundColor: ColorP.cardBackground,
        title: Row(
          children: [
            SvgPicture.asset(IconlyC.person,
                width: 18,
                height: 18,
                colorFilter:
                    const ColorFilter.mode(ColorP.reminder, BlendMode.srcIn)),
            const SizedBox(
              width: 20,
            ),
            Text(
              widget.participant.name,
              style: const TextStyle(
                  color: ColorP.textColor, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Utils.updateIcon(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactAddPage(
                    onContactAdded: () => {},
                    uParticipant: widget.participant,
                  ),
                ),
              ).then((value) => widget.onDelete());
            }),
            Utils.deleteIcon(onPressed: () async {
              await participantRepo
                  .deleteParticipant(widget.participant.id ?? "")
                  .whenComplete(() => widget.onDelete());
            }),
          ],
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[800], // Darker background color
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _launchEmail(widget.participant.email ?? "");
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.email, color: Colors.blue),
                            const SizedBox(width: 10),
                            Text(
                              "${localizations?.translate('email') ?? ""}: ${widget.participant.email ?? ""}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          _launchSMS(widget.participant.number ?? "");
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.green),
                            const SizedBox(width: 10),
                            Text(
                              "${localizations?.translate('number') ?? ""}: ${widget.participant.number ?? ""}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              widget.onExpanded(widget.index);
            } else {
              widget.onExpanded(-1);
            }
          });
        },
      ),
    );
  }

  _launchSMS(String phoneNumber) async {
    final Uri smsLaunchUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{
        'body': Uri.encodeComponent('...'),
      },
    );
    if (!kIsWeb) {
      launchUrl(smsLaunchUri);
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'Hello',
      }),
    );
    // if (!kIsWeb) {
    launchUrl(emailLaunchUri);
    // }
  }
}
