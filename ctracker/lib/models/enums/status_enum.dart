enum StatusEnum { done, notDone }

extension StatusExtension on StatusEnum {
  String get name {
    switch (this) {
      case StatusEnum.done:
        return 'Done';
      case StatusEnum.notDone:
        return 'Not done';
      default:
        return 'Alert';
    }
  }

  String get id {
    switch (this) {
      case StatusEnum.done:
        return 'aikmg7op9pomd6z';
      case StatusEnum.notDone:
        return 'euh6ipektf0qed1';
      default:
        return 'aikmg7op9pomd6z';
    }
  }
}
