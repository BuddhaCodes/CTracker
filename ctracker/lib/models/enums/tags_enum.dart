enum TagsEnum { innovative, house, project }

extension TagExtension on TagsEnum {
  String get name {
    switch (this) {
      case TagsEnum.innovative:
        return 'Innovative';
      case TagsEnum.house:
        return 'House';
      case TagsEnum.project:
        return 'Project';
      default:
        return 'Alert';
    }
  }

  String get id {
    switch (this) {
      case TagsEnum.innovative:
        return 'ozhatr26kdyv05w';
      case TagsEnum.house:
        return 'yehceidbmcqmvbu';
      case TagsEnum.project:
        return '5n5j1m7z6chddfn';
      default:
        return 'Alert';
    }
  }
}
