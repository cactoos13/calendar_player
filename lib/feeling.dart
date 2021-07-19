enum Feeling {
  like,
  neutral,
  hate,
}

extension ParseToString on Feeling {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
