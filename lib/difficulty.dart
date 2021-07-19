enum Difficulty {
  easy,
  normal,
  hard,
}

extension ParseToString on Difficulty {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
