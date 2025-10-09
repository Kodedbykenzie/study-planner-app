import 'dart:math';

class Task {
  final String id;
  String title;
  String description;
  DateTime dueDate;
  DateTime? reminderTime;
  bool isDone;
  bool notifyDayBefore;
  bool notifyHourBefore;

  Task({
    String? id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.reminderTime,
    this.isDone = false,
    this.notifyDayBefore = false,
    this.notifyHourBefore = false,
  }) : id = id ?? Task._generateId();

  static String _generateId() {
    final int timestamp = DateTime.now().microsecondsSinceEpoch;
    final int randomPart = Random().nextInt(1000000);
    return 't_${timestamp}_${randomPart.toString().padLeft(6, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'reminderTime': reminderTime?.toIso8601String(),
    'isDone': isDone,
    'notifyDayBefore': notifyDayBefore,
    'notifyHourBefore': notifyHourBefore,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    dueDate: DateTime.parse(json['dueDate']),
    reminderTime: json['reminderTime'] != null
        ? DateTime.parse(json['reminderTime'])
        : null,
    isDone: json['isDone'] ?? false,
    notifyDayBefore: json['notifyDayBefore'] ?? false,
    notifyHourBefore: json['notifyHourBefore'] ?? false,
  );

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool? isDone,
    bool? notifyDayBefore,
    bool? notifyHourBefore,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      isDone: isDone ?? this.isDone,
      notifyDayBefore: notifyDayBefore ?? this.notifyDayBefore,
      notifyHourBefore: notifyHourBefore ?? this.notifyHourBefore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
