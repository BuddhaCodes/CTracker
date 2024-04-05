enum DifficultyEnum { easy, mid, hard }

extension DifficultyExtension on DifficultyEnum {
  String get name {
    switch (this) {
      case DifficultyEnum.easy:
        return 'Easy';
      case DifficultyEnum.mid:
        return 'Mid';
      case DifficultyEnum.hard:
        return 'Hard';
      default:
        return 'Alert';
    }
  }

  String get id {
    switch (this) {
      case DifficultyEnum.easy:
        return '7nqe51vgqcucdgp';
      case DifficultyEnum.mid:
        return '88iezi6jl895puy';
      case DifficultyEnum.hard:
        return 'oul7h3sg2i2xois';
      default:
        return 'Alert';
    }
  }
}
