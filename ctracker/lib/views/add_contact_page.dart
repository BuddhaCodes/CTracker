import 'package:ctracker/constant/color_palette.dart';
import 'package:ctracker/models/participants.dart';
import 'package:ctracker/repository/participant_repository_implementation.dart';
import 'package:ctracker/utils/localization.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

// ignore: must_be_immutable
class ContactAddPage extends StatefulWidget {
  final Function onContactAdded;
  Participant? uParticipant;
  ContactAddPage({super.key, this.uParticipant, required this.onContactAdded});
  @override
  State<ContactAddPage> createState() => ContactAddPageState();
}

class ContactAddPageState extends State<ContactAddPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  late ParticipantRepositoryImplementation participantRepo;
  bool isInit = false;
  MyLocalizations? localizations;

  final formKey = GlobalKey<FormState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MyLocalizations.of(context);
  }

  @override
  void initState() {
    super.initState();
    isInit = false;
    initializeData();
  }

  void initializeData() async {
    nameController = TextEditingController();
    emailController = TextEditingController();
    numberController = TextEditingController();
    participantRepo = ParticipantRepositoryImplementation();
    setState(() {
      if (widget.uParticipant != null) {
        nameController.text = widget.uParticipant!.name;
        emailController.text = widget.uParticipant!.email ?? "";
        numberController.text = widget.uParticipant!.number ?? "";
      }
    });
    setState(() {
      isInit = true;
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
      body: SafeArea(
        child: !isInit
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        localizations?.translate('name') ?? "",
                                        style: const TextStyle(
                                            color: ColorP.textColorSubtitle,
                                            fontSize: 14),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25.0)),
                                        ),
                                        filled: true,
                                        fillColor: ColorP.cardBackground,
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(25.0)),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return localizations?.translate(
                                                  'nameValidation') ??
                                              "";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              localizations
                                                      ?.translate('pnumber') ??
                                                  "",
                                              style: const TextStyle(
                                                  color:
                                                      ColorP.textColorSubtitle,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          TextFormField(
                                            controller: numberController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                              ),
                                              filled: true,
                                              fillColor: ColorP.cardBackground,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return localizations?.translate(
                                                        'pnumberValidation') ??
                                                    "";
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 30),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              localizations
                                                      ?.translate('email') ??
                                                  "",
                                              style: const TextStyle(
                                                  color:
                                                      ColorP.textColorSubtitle,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          TextFormField(
                                            controller: emailController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                              ),
                                              filled: true,
                                              fillColor: ColorP.cardBackground,
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return localizations?.translate(
                                                        'emailValidator') ??
                                                    "";
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          const MaterialStatePropertyAll(
                                              ColorP.ColorB),
                                      overlayColor: MaterialStatePropertyAll(
                                          ColorP.ColorB.withOpacity(0.8)),
                                      elevation:
                                          const MaterialStatePropertyAll(10),
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(150, 50)),
                                    ),
                                    child: Text(
                                        localizations?.translate("submit") ??
                                            "",
                                        style: const TextStyle(
                                            color: ColorP.textColor)),
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        _addParticipant();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _addParticipant() async {
    if (formKey.currentState!.validate()) {
      String name = nameController.text;
      String email = emailController.text;
      String number = numberController.text;

      if (widget.uParticipant == null) {
        Participant newContact =
            Participant(name: name, email: email, number: number);
        await participantRepo.addParticipant(newContact).whenComplete(() {
          widget.onContactAdded(true);
          Navigator.pop(context);
        });
      } else {
        widget.uParticipant?.name = name;
        widget.uParticipant?.email = email;
        widget.uParticipant?.number = number;

        await participantRepo
            .updateParticipant(
                widget.uParticipant?.id ?? "", widget.uParticipant!)
            .whenComplete(() {
          Navigator.pop(context);
        });
      }
    }
  }
}
