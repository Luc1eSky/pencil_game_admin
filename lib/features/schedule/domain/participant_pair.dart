class ParticipantPair {
  ParticipantPair(this.participant1, this.participant2) : assert(participant1 != participant2);
  final int participant1;
  final int participant2;

  @override
  bool operator ==(Object other) =>
      other is ParticipantPair &&
      other.runtimeType == runtimeType &&
      ((other.participant1 == participant1 && other.participant2 == participant2) ||
          (other.participant2 == participant1 && other.participant1 == participant2));

  @override
  int get hashCode => participant1.hashCode * participant2.hashCode;

  @override
  String toString() {
    return '$participant1-$participant2';
  }

  bool participantIsInPair(int participant) {
    return participant == participant1 || participant == participant2;
  }

  Set<int> toSet() {
    return {participant1, participant2};
  }
}
