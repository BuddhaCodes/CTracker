enum TagsEnum {
  project,
  organization,
  culinary,
  relationship,
  home,
  career,
  social,
  entertainment,
  art,
  sustainability,
  technology,
  travel,
  finance,
  health,
  learning,
  inspiration
}

extension TagExtension on TagsEnum {
  String get name {
    switch (this) {
      case TagsEnum.project:
        return 'Project';
      case TagsEnum.organization:
        return 'Organization';
      case TagsEnum.culinary:
        return 'Culinary';
      case TagsEnum.relationship:
        return 'Relationship';
      case TagsEnum.home:
        return 'Home';
      case TagsEnum.career:
        return 'Career';
      case TagsEnum.social:
        return 'Social';
      case TagsEnum.entertainment:
        return 'Entertainment';
      case TagsEnum.art:
        return 'Art';
      case TagsEnum.sustainability:
        return 'Sustainability';
      case TagsEnum.technology:
        return 'Technology';
      case TagsEnum.travel:
        return 'Travel';
      case TagsEnum.finance:
        return 'Finance';
      case TagsEnum.health:
        return 'Health';
      case TagsEnum.learning:
        return 'Learning';
      case TagsEnum.inspiration:
        return 'Inspiration';

      default:
        return 'Alert';
    }
  }

  String get id {
    switch (this) {
      case TagsEnum.project:
        return '5n5j1m7z6chddfn';
      case TagsEnum.organization:
        return 'lt03a4rjo0i7ljm';
      case TagsEnum.culinary:
        return 'eu3ocj60qbyedv8';
      case TagsEnum.relationship:
        return '4r7nlbuvni6207a';
      case TagsEnum.home:
        return 'h8ke0v05cisbzzz';
      case TagsEnum.career:
        return 'igood2re0gr9k0f';
      case TagsEnum.social:
        return '9jf3vekj7fh86w9';
      case TagsEnum.entertainment:
        return '3vx4c4x2kffb0c2';
      case TagsEnum.art:
        return '0gpxvj150b95asy';
      case TagsEnum.sustainability:
        return 'kogj6crbw5segli';
      case TagsEnum.technology:
        return 'w94ar3vcm4p7wix';
      case TagsEnum.travel:
        return '0d00qs3mesowshf';
      case TagsEnum.finance:
        return 'ndj6okavq6ij6ph';
      case TagsEnum.health:
        return 'd2w6o0hbo0it209';
      case TagsEnum.learning:
        return 'ozhatr26kdyv05w';
      case TagsEnum.inspiration:
        return 'yehceidbmcqmvbu';
      default:
        return 'Alert';
    }
  }
}
