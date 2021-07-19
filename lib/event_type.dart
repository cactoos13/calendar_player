enum EventType {
  work,
  study,
  chore,
  fun,
}

extension ParseToString on EventType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
