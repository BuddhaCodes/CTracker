enum ActionTypeEnum { create, read, update, delete }

extension ActionTypeEnumExtension on ActionTypeEnum {
  String get name {
    switch (this) {
      case ActionTypeEnum.create:
        return 'Create';
      case ActionTypeEnum.read:
        return 'Read';
      case ActionTypeEnum.update:
        return 'Update';
      case ActionTypeEnum.delete:
        return 'Delete';
      default:
        return 'Alert';
    }
  }

  String get id {
    switch (this) {
      case ActionTypeEnum.create:
        return 'g33e60mcs3meps9';
      case ActionTypeEnum.read:
        return '5rz81e2ty1slsyz';
      case ActionTypeEnum.update:
        return 'dt68qug5dwhumsi';
      case ActionTypeEnum.delete:
        return 'yz4p4rqr9e0k943';
      default:
        return 'Alert';
    }
  }
}
