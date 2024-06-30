class Note {
  final int? id;
  final bool pin;
  final bool isArchieve;
  final String title;
  final String uniqueID;
  final String content;
  final DateTime createdTime;


  Note({
    this.id,
    required this.pin,
    required this.isArchieve,
    required this.title,
    required this.uniqueID,
    required this.content,
    required this.createdTime,
  });

  Note copy({
    int? id,
    bool? pin,
    bool? isArchieve,
    String? title,
    String? uniqueID,
    String? content,
    DateTime? createdTime,
  }) {
    return Note(
      id: id ?? this.id,
      pin: pin ?? this.pin,
      isArchieve: isArchieve ?? this.isArchieve,
      title: title ?? this.title,
      content: content ?? this.content,
      uniqueID: uniqueID ?? this.uniqueID,
      createdTime: createdTime ?? this.createdTime,
    );
  }

  static Note fromJson(Map<String, Object?> json) {
    return Note(
      id: json[NoteFields.id] as int?,
      pin: json[NoteFields.pin] == 1,
      isArchieve: json[NoteFields.isArchieve] == 1,
      title: json[NoteFields.title] as String,
      content: json[NoteFields.content] as String,
      uniqueID: json[NoteFields.uniqueID] as String,
      createdTime: DateTime.parse(json[NoteFields.createdTime] as String),
    );
  }

  Map<String, Object?> toJson() {
    return {
      NoteFields.id: id,
      NoteFields.pin: pin ? 1 : 0,
      NoteFields.isArchieve: isArchieve ? 1 : 0,
      NoteFields.title: title,
      NoteFields.content: content,
      NoteFields.uniqueID:uniqueID,
      NoteFields.createdTime: createdTime.toIso8601String(),
    };
  }
}

class NoteFields {
  static final List<String> values = [
    id,
    pin,
    isArchieve,
    title,
    uniqueID,
    content,
    createdTime
  ];

  static const String id = '_id';
  static const String uniqueID = 'uniqueID';
  static const String pin = 'pin';
  static const String isArchieve = 'isArchieve';
  static const String title = 'title';
  static const String content = 'content';
  static const String createdTime = 'createdTime';
}