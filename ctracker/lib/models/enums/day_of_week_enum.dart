enum DayOfWeekEnum {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}

extension DayOfWeekEnumExtension on DayOfWeekEnum {
  String get name {
    switch (this) {
      case DayOfWeekEnum.monday:
        return 'Monday';
      case DayOfWeekEnum.tuesday:
        return 'Tuesday';
      case DayOfWeekEnum.wednesday:
        return 'Wednesday';
      case DayOfWeekEnum.thursday:
        return 'Thursday';
      case DayOfWeekEnum.friday:
        return 'Friday';
      case DayOfWeekEnum.saturday:
        return 'Saturday';
      case DayOfWeekEnum.sunday:
        return 'Sunday';
      default:
        return 'Alert';
    }
  }

  String get id {
    switch (this) {
      case DayOfWeekEnum.monday:
        return '8vcq8ssyziz9pki';
      case DayOfWeekEnum.tuesday:
        return 'zty0fkvzkesoqlz';
      case DayOfWeekEnum.wednesday:
        return '9r0vaa3u6ul329i';
      case DayOfWeekEnum.thursday:
        return 'efs8zg9txapk05o';
      case DayOfWeekEnum.friday:
        return 'ojctm5piztt3mbr';
      case DayOfWeekEnum.saturday:
        return '6bq73a2nh8n0cxm';
      case DayOfWeekEnum.sunday:
        return '5g3d9pf7sq3l4hy';
      default:
        return 'Alert';
    }
  }
}
