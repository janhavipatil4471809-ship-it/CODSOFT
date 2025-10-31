class Alarm {
  final String id;
  final DateTime time;
  final String tone;
  final bool isActive;
  final String label;

  Alarm({
    required this.id,
    required this.time,
    required this.tone,
    this.isActive = true,
    this.label = 'Alarm',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'tone': tone,
      'isActive': isActive,
      'label': label,
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'],
      time: DateTime.parse(json['time']),
      tone: json['tone'],
      isActive: json['isActive'] ?? true,
      label: json['label'] ?? 'Alarm',
    );
  }

  Alarm copyWith({
    String? id,
    DateTime? time,
    String? tone,
    bool? isActive,
    String? label,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      tone: tone ?? this.tone,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
    );
  }

  String getFormattedTime() {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}