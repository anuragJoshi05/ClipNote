class Note {
  final int? id;
  final bool pin;
  final bool isArchieve;
  final String title;
  final String uniqueID;
  final String content;
  final DateTime createdTime;
  final String? backgroundImage; // New field
  final String? summary;

  Note({
    this.id,
    required this.pin,
    required this.isArchieve,
    required this.title,
    required this.uniqueID,
    required this.content,
    required this.createdTime,
    this.backgroundImage = "", // Default value set to ""
    this.summary,
  });

  Note copy({
    int? id,
    bool? pin,
    bool? isArchieve,
    String? title,
    String? uniqueID,
    String? content,
    DateTime? createdTime,
    String? backgroundImage,
    String? summary,// New parameter in copy method
  }) {
    return Note(
      id: id ?? this.id,
      pin: pin ?? this.pin,
      isArchieve: isArchieve ?? this.isArchieve,
      title: title ?? this.title,
      content: content ?? this.content,
      uniqueID: uniqueID ?? this.uniqueID,
      createdTime: createdTime ?? this.createdTime,
      backgroundImage:
          backgroundImage ?? this.backgroundImage,
      summary: summary ?? this.summary,// Copy background image
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
      backgroundImage: json[NoteFields.backgroundImage] as String?,
      summary: json[NoteFields.summary] as String?,// From JSON
    );
  }

  Map<String, Object?> toJson() {
    return {
      NoteFields.id: id,
      NoteFields.pin: pin ? 1 : 0,
      NoteFields.isArchieve: isArchieve ? 1 : 0,
      NoteFields.title: title,
      NoteFields.content: content,
      NoteFields.uniqueID: uniqueID,
      NoteFields.createdTime: createdTime.toIso8601String(),
      NoteFields.backgroundImage: backgroundImage,
      NoteFields.summary: summary,// To JSON
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
    createdTime,
    backgroundImage // Add new field
  ];

  static const String id = '_id';
  static const String uniqueID = 'uniqueID';
  static const String pin = 'pin';
  static const String isArchieve = 'isArchieve';
  static const String title = 'title';
  static const String content = 'content';
  static const String createdTime = 'createdTime';
  static const String backgroundImage = 'backgroundImage';
  static const String summary = 'summary';// New constant
}
