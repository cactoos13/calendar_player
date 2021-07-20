enum EventType {
  work,
  study,
  chore,
  fun,
}

//final eventTypeValues = EnumValues({
//  'Level1': UserLevel.HamSafar,
//  'Level3': UserLevel.PorSafar,
//  'Level2': UserLevel.KhoshSafar
//});


extension ParseToString on EventType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
