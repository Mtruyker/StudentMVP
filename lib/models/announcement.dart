class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isImportant,
    this.targetGroupId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isImportant;
  final String? targetGroupId;
}
