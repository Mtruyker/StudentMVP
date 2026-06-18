enum UserRole { student, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.role,
    this.groupId,
    this.groupName,
    this.specialty,
    this.course,
    this.studentCard,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String? groupId;
  final String? groupName;
  final String? specialty;
  final int? course;
  final String? studentCard;

  String get firstName => fullName.split(' ').first;
}
