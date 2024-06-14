class NotesImpNames {
  static final String id = "id";
  static final String pin = "pin";
  static final String title = "title";
  static final String content = "content";
  static final String createdTime = "createdTime";
  static final String tableName = "tableName";

  static final List<String> values = [
    id,
    pin,
    title,
    content,
    createdTime,
    tableName
  ];
}

class Note {
  final int? id;
  final bool pin;
  final String title;
  final String content;
  final DateTime createdTime;

  const Note(
      {this.id,
      required this.pin,
      required this.title,
      required this.content,
      required this.createdTime});
  Note copy({
    int? id,
    bool? pin,
    String? title,
    String? content,
    DateTime? createdTime,
  }) {
    return Note(
        id: id ?? this.id,
        pin: pin ?? this.pin,
        title: title ?? this.title,
        content: content ?? this.content,
        createdTime: createdTime ?? this.createdTime);
  }

  static Note fromJson(Map<String, Object?> json) {
    return Note(
        id: json[NotesImpNames.id] as int?,
        pin: json[NotesImpNames.pin] == 1,
        title: json[NotesImpNames.title] as String,
        content: json[NotesImpNames.content] as String,
        createdTime: DateTime.parse(json[NotesImpNames.createdTime] as String));
  }

  Map<String, Object?> toJson() {
    return {
      NotesImpNames.id: id,
      NotesImpNames.pin: pin ? 1 : 0,
      NotesImpNames.title: title,
      NotesImpNames.content: content,
      NotesImpNames.createdTime: createdTime.toIso8601String(),
    };
  }
}
