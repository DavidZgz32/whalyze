class WrappedModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final Map<String, dynamic> data;
  final List<String> participants;
  final int totalLines;

  WrappedModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.data,
    required this.participants,
    required this.totalLines,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'data': data,
      'participants': participants,
      'totalLines': totalLines,
    };
  }

  factory WrappedModel.fromJson(Map<String, dynamic> json) {
    return WrappedModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      data: json['data'] as Map<String, dynamic>,
      participants: List<String>.from(json['participants'] as List),
      totalLines: json['totalLines'] as int,
    );
  }
}

