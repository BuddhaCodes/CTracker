import 'package:flutter/material.dart';

class MyLocalizations {
  static MyLocalizations of(BuildContext context) {
    return Localizations.of<MyLocalizations>(context, MyLocalizations)!;
  }

  final Map<String, String> _localizedStrings;

  MyLocalizations(this._localizedStrings);

  String translate(String key) {
    return _localizedStrings[key] ?? '';
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) async {
    if (locale.languageCode == 'es') {
      return MyLocalizations(_localizedStringsSpanish);
    } else {
      return MyLocalizations(_localizedStringsEnglish);
    }
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;

  static const Map<String, String> _localizedStringsEnglish = {
    'appName': 'CNotes',
    'journal': "Journal",
    'saveS': 'Saved succesfully',
    "actionItems": "Number of Action Items",
    'drawerTracker': 'Tasks',
    'drawerPomodoro': 'Pomodoro',
    'drawerSettings': 'Settings',
    'title': 'Title',
    'duedate': 'Due Date',
    'description': 'Description',
    'category': 'Category',
    'actions': 'Actions',
    'difficulty': 'Difficulty',
    'priority': 'Priority',
    'effort': 'Effort',
    'project': 'Project',
    'projects': 'Projects',
    'tags': 'Tags',
    'add': 'Add',
    'ideaHintTitle': 'Idea Title',
    'ideaLabeltTitle': 'Title *',
    'ideaValidationtTitle': 'Enter the title',
    'ideaHintDescription': 'Idea Description',
    'ideaLabelDescription': 'Description *',
    'ideaValidationDescription': 'Enter the description',
    'ideaHintNote': 'Extra Note',
    'ideaLabelNote': 'Note *',
    'ideaValidationNote': 'Enter the note',
    'reminderHintTitle': 'Reminder Title',
    'reminderLabeltTitle': 'Title *',
    'reminderValidationtTitle': 'Enter the title',
    'reminderHintDescription': 'Reminder Description',
    'reminderLabelDescription': 'Description *',
    'reminderValidationDescription': 'Enter the description',
    'reminderHintNote': 'Extra Note',
    'reminderLabelNote': 'Note *',
    'reminderValidationNote': 'Enter the note',
    'taskHintTitle': 'Task Title',
    'taskLabeltTitle': 'Title *',
    'taskValidationtTitle': 'Enter the title',
    'taskHintDescription': 'Task Description',
    'taskLabelDescription': 'Description *',
    'taskValidationDescription': 'Enter the description',
    'taskHintPriority': 'Task Priority',
    'taskLabelPriority': 'Priority *',
    'taskValidationPriority': 'Enter a number',
    'taskHintNote': 'Extra Note',
    'taskLabelNote': 'Note *',
    'taskValidationNote': 'Enter the note',
    'addImage': 'Add Image',
    'processingEntry': 'Processing',
    'work': 'Work',
    'shortRest': 'Short Rest',
    'longRest': 'Long Rest',
    'ended': 'End',
    'start': 'Start',
    'stop': 'Stop',
    'reset': 'Reset',
    'itemValidationDescription': 'You need to enter action tasks',
    'note': 'Note',
    'addNote': 'Enter note',
    'timeDedicated': 'Time dedicated to the task is:',
    'newItem': 'New',
    'noTask': 'No task to work with',
    'noData': 'No data found',
    'settings': 'Settings',
    'workTimeMessage': 'Work Time (minutes)',
    'sRestTimeMessage': 'Short Rest Time (minutes)',
    'lRestTimeMessage': 'Long Rest Time (minutes)',
    'seconds': 'Seconds',
    'ideaDetails': 'Idea Details',
    'close': 'Close',
    'participants': 'Participants',
    'meetings': 'Meetings',
    'content': "Content",
    'status': 'Status',
    'amountactions': 'Amount of actions',
    'idea': "Idea",
    'submit': 'Submit',
    'save': 'Save',
    'reminders': 'Reminder'
  };
  static const Map<String, String> _localizedStringsSpanish = {
    'appName': 'CNotes',
    'journal': 'Diario',
    'reminders': 'Recordatorio',
    'drawerTracker': 'Tareas',
    'saveS': 'Guardado con exito',
    'drawerPomodoro': 'Pomodoro',
    'drawerSettings': 'Opciones',
    'title': 'Título',
    'amountactions': 'Cantidad de acciones',
    'content': 'Contenido',
    'participants': 'Participantes',
    'duedate': 'Fecha',
    'description': 'Descripción',
    'category': 'Categoría',
    'actions': 'Acciones',
    'difficulty': 'Dificultad',
    'priority': 'Prioridad',
    'effort': 'Esfuerzo',
    'project': 'Projecto',
    'projects': 'Projectos',
    'tags': 'Tags',
    'add': 'Añadir',
    'noTask': 'No hay tareas para trabajar',
    'idea': "Idea",
    'ideaHintTitle': 'Título de la idea',
    'ideaLabeltTitle': 'Título *',
    'ideaValidationtTitle': 'Entre el título',
    'ideaHintDescription': 'Descripción de la idea',
    'ideaLabelDescription': 'Descripción *',
    'ideaValidationDescription': 'Entre la Descripción',
    'ideaHintNote': 'Nota extra',
    'ideaLabelNote': 'Nota *',
    'ideaValidationNote': 'Entre la nota',
    'reminderHintTitle': 'Título del recordatorio',
    'reminderLabeltTitle': 'Título *',
    'reminderValidationtTitle': 'Entre el título',
    'reminderHintDescription': 'Descripción del recordatorio',
    'reminderLabelDescription': 'Descripción *',
    'reminderValidationDescription': 'Entre la Descripción',
    'reminderHintNote': 'Nota extra',
    'reminderLabelNote': 'Nota *',
    'reminderValidationNote': 'Entre la nota',
    'taskHintTitle': 'Título de la tarea',
    'taskLabeltTitle': 'Título *',
    'taskValidationtTitle': 'Entre el título',
    'taskHintDescription': 'Descripción de la tarea',
    'taskLabelDescription': 'Descripción *',
    'taskValidationDescription': 'Entre la Descripción',
    'taskHintPriority': 'Prioridad de la tarea',
    'taskLabelPriority': 'Prioridad *',
    'taskValidationPriority': 'Entre una número',
    'taskHintNote': 'Nota extra',
    'taskLabelNote': 'Nota *',
    'taskValidationNote': 'Entre la nota',
    'addImage': 'Añadir imagen',
    'processingEntry': 'Procesando',
    'work': 'Trabajo',
    'shortRest': 'Descanso corto',
    'longRest': 'Descanso largo',
    'start': 'Iniciar',
    'stop': 'Parar',
    'reset': 'Reiniciar',
    'itemValidationDescription': 'Necesita entrar tareas de acción',
    'note': 'Nota',
    'ended': 'Finalizada',
    'addNote': 'Entrar nota',
    'timeDedicated': 'El tiempo dedicado a la tarea es:',
    'newItem': 'Nuevo',
    'noData': 'No se encotró datos',
    'settings': 'Opciones',
    'workTimeMessage': 'Tiempo de trabajo (minutos)',
    'sRestTimeMessage': 'Tiempo de descanso corto (minutos)',
    'lRestTimeMessage': 'Tiempo de descanso largo (minutos)',
    'seconds': 'Segundos',
    'ideaDetails': 'Detalles de la idea',
    'close': 'Cerrar',
    'meetings': 'Reuiniones',
    'status': 'Estado',
    'submit': 'Entrar',
    'save': 'Guardar',
  };
}
