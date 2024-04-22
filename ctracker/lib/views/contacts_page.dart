import 'package:ctracker/components/contact_card.dart';
import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/constant/icons.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/repository/participant_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:ctracker/views/add_contact_page.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ContactsPage extends StatefulWidget {
  bool isInit = false;
  ContactsPage({
    super.key,
  });

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  late List<Participant> participants;
  MyLocalizations? localizations;
  int selectedTile = -1;
  late ParticipantRepositoryImplementation participantRepo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MyLocalizations.of(context);
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    participants = [];
    participantRepo = ParticipantRepositoryImplementation();

    participants = await participantRepo.getAllParticipants();

    setState(() {
      widget.isInit = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorP.background,
        foregroundColor: ColorP.textColor,
      ),
      backgroundColor: ColorP.background,
      body: !widget.isInit
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 140,
                              child: Image.asset(
                                IconlyC.contact,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            Text(
                              localizations?.translate('contact') ?? "",
                              style: const TextStyle(
                                fontSize: 50.0,
                                fontWeight: FontWeight.bold,
                                color: ColorP.textColor,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: ColorP.cardBackground,
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ContactAddPage(
                                        onContactAdded: handle,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(25),
                                child: const Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.98,
                      child: SizedBox(
                        height: 400,
                        child: ListView.builder(
                          itemCount: participants.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ContactCard(
                              participant: participants[index],
                              selectedTile: selectedTile,
                              index: index,
                              onExpanded: (int sel) {
                                setState(() {
                                  selectedTile = sel;
                                });
                              },
                              onDelete: () {
                                initializeData();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void handle(bool added) async {
    try {
      initializeData();
    } catch (e) {
      participants = [];
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.translate("error") ?? "",
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)))),
        );
      }
    }
  }
}
