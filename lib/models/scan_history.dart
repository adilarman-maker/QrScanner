class ScanHistory {
  final String id;
  final String content;
  final String type;
  final DateTime timestamp;

  ScanHistory({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ScanHistory.fromJson(Map<String, dynamic> json) => ScanHistory(
    id: json['id'],
    content: json['content'],
    type: json['type'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}