enum WorkspaceMemberRole { leader, administrator, collaborator, observer }

class WorkspaceMember {
  final String id;
  final String initiativeId;
  final String name;
  final String roleName;
  final WorkspaceMemberRole role;
  final bool canManageTasks;
  final bool canComment;
  final bool canChat;

  const WorkspaceMember({
    required this.id,
    required this.initiativeId,
    required this.name,
    required this.roleName,
    required this.role,
    required this.canManageTasks,
    required this.canComment,
    required this.canChat,
  });

  WorkspaceMember copyWith({
    String? roleName,
    WorkspaceMemberRole? role,
    bool? canManageTasks,
    bool? canComment,
    bool? canChat,
  }) => WorkspaceMember(
    id: id,
    initiativeId: initiativeId,
    name: name,
    roleName: roleName ?? this.roleName,
    role: role ?? this.role,
    canManageTasks: canManageTasks ?? this.canManageTasks,
    canComment: canComment ?? this.canComment,
    canChat: canChat ?? this.canChat,
  );
}
