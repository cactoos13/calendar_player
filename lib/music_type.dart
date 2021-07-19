enum MusicType {
  happy,
  sad,
  energetic,
  relax,
}

extension ParseToString on MusicType {
  String toShortString() {
    return this.toString().split('.').last;
  }
}
