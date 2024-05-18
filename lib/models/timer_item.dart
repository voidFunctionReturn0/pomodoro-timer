class TimerItem {
  final int? id;
  final int minutes;

  const TimerItem({
    this.id,
    required this.minutes,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'minutes': minutes,
    };
  }
}
