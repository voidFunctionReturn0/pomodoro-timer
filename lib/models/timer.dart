class Timer {
  final int? id;
  final int minutes;

  const Timer({
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
