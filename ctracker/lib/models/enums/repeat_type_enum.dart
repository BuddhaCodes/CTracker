enum RepeatTypeEnum { never, hourly, daily, weekly, monthly }

extension RepeatTypeExtension on RepeatTypeEnum {
  String get name {
    switch (this) {
      case RepeatTypeEnum.never:
        return 'Never';
      case RepeatTypeEnum.hourly:
        return 'Hourly';
      case RepeatTypeEnum.daily:
        return 'Daily';
      case RepeatTypeEnum.weekly:
        return 'Weekly';
      case RepeatTypeEnum.monthly:
        return 'Monthly';
      default:
        return 'Alert';
    }
  }

  String get id {
    switch (this) {
      case RepeatTypeEnum.never:
        return 'o7tm6fhkjgxhih9';
      case RepeatTypeEnum.hourly:
        return 'uwsi9rq58i4tpqj';
      case RepeatTypeEnum.daily:
        return 'kkumekz8zs4t5rm';
      case RepeatTypeEnum.weekly:
        return 'vlr62tkfpvp6o3z';
      case RepeatTypeEnum.monthly:
        return 'fzgrgzetxgbp9rp';
      default:
        return 'Alert';
    }
  }
}
