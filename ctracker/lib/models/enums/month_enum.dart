enum MonthEnum {
  january,
  february,
  march,
  april,
  may,
  june,
  july,
  august,
  september,
  october,
  november,
  december
}

extension MonthExtension on MonthEnum {
  String get name {
    switch (this) {
      case MonthEnum.january:
        return 'Jan.';
      case MonthEnum.february:
        return 'Feb.';
      case MonthEnum.march:
        return 'Mar.';
      case MonthEnum.april:
        return 'Apr.';
      case MonthEnum.may:
        return 'May.';
      case MonthEnum.june:
        return 'Jun.';
      case MonthEnum.july:
        return 'Jul.';
      case MonthEnum.august:
        return 'Aug.';
      case MonthEnum.september:
        return 'Sep.';
      case MonthEnum.october:
        return 'Oct.';
      case MonthEnum.november:
        return 'Nov.';
      case MonthEnum.december:
        return 'Dec.';

      default:
        return 'Alert';
    }
  }

  int get value {
    switch (this) {
      case MonthEnum.january:
        return 1;
      case MonthEnum.february:
        return 2;
      case MonthEnum.march:
        return 3;
      case MonthEnum.april:
        return 4;
      case MonthEnum.may:
        return 5;
      case MonthEnum.june:
        return 6;
      case MonthEnum.july:
        return 7;
      case MonthEnum.august:
        return 8;
      case MonthEnum.september:
        return 9;
      case MonthEnum.october:
        return 10;
      case MonthEnum.november:
        return 11;
      case MonthEnum.december:
        return 12;

      default:
        return 1;
    }
  }
}
