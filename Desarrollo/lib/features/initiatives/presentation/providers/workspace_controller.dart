import 'package:flutter/foundation.dart';

import '../../domain/entities/workspace_comment.dart';
import '../../domain/entities/workspace_member.dart';
import '../../domain/entities/workspace_message.dart';
import '../../domain/entities/workspace_publication.dart';
import '../../domain/entities/publication_comment.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../domain/repositories/public_feed_repository.dart';

class WorkspaceController extends ChangeNotifier {
  final WorkspaceRepository _repository;

  final PublicFeedRepository? _publicFeedRepository;

  WorkspaceController(this._repository, {PublicFeedRepository? publicFeedRepository})
      : _publicFeedRepository = publicFeedRepository;

  List<WorkspaceMessage> _messages = [];
  List<WorkspaceComment> _comments = [];
  List<WorkspaceMember> _members = [];
  List<WorkspacePublication> _publications = [];
  List<PublicationComment> _publicationComments = [];
  bool _isLoading = false;
  String? _error;

  List<WorkspaceMessage> get messages => List.unmodifiable(_messages);
  List<WorkspaceComment> get comments => List.unmodifiable(_comments);
  List<WorkspaceMember> get members => List.unmodifiable(_members);
  List<WorkspacePublication> get publications =>
      List.unmodifiable(_publications);
  List<PublicationComment> commentsForPublication(String publicationId) =>
      _publicationComments
          .where((comment) => comment.publicationId == publicationId)
          .toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load(
    String initiativeId, {
    List<WorkspaceMember> initialMembers = const [],
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _messages = await _repository.getMessages(initiativeId);
      _comments = await _repository.getComments(initiativeId);
      _members = await _repository.getMembers(initiativeId);
      _publications = _publicFeedRepository == null
          ? await _repository.getPublications(initiativeId)
          : (await _publicFeedRepository.getPublications())
                .where((item) => item.initiativeId == initiativeId)
                .toList();
      _publicationComments = _publicFeedRepository == null
          ? await _repository.getPublicationComments(initiativeId)
          : (await _publicFeedRepository.getComments())
                .where((item) => item.initiativeId == initiativeId)
                .toList();
      final knownIds = _members.map((member) => member.id).toSet();
      final missing = initialMembers
          .where((member) => !knownIds.contains(member.id))
          .toList();
      for (final member in missing) {
        await _repository.updateMember(member);
      }
      _members = [..._members, ...missing];
    } catch (_) {
      _error = 'No se pudo cargar la información del proyecto.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMember(WorkspaceMember member) async {
    final updated = await _repository.updateMember(member);
    _members = [
      for (final item in _members) item.id == updated.id ? updated : item,
    ];
    notifyListeners();
  }

  Future<void> sendMessage({
    required String initiativeId,
    required String author,
    required String text,
  }) async {
    final message = await _repository.sendMessage(
      initiativeId: initiativeId,
      author: author,
      text: text,
    );
    _messages = [..._messages, message];
    notifyListeners();
  }

  Future<void> addComment({
    required String initiativeId,
    required String author,
    required String text,
  }) async {
    final comment = await _repository.addComment(
      initiativeId: initiativeId,
      author: author,
      text: text,
    );
    _comments = [..._comments, comment];
    notifyListeners();
  }

  Future<void> createPublication({
    required String initiativeId,
    required String author,
    required String title,
    required String text,
  }) async {
    final draft = WorkspacePublication(
        id: '',
        initiativeId: initiativeId,
        author: author,
        title: title,
        text: text,
        createdAt: DateTime.now(),
      );
    final publication = _publicFeedRepository == null
        ? await _repository.createPublication(draft)
        : await _publicFeedRepository.createPublication(draft);
    _publications = [..._publications, publication];
    notifyListeners();
  }

  Future<void> addPublicationComment({
    required String initiativeId,
    required String publicationId,
    required String author,
    required String text,
  }) async {
    final draft = PublicationComment(
        id: '',
        publicationId: publicationId,
        initiativeId: initiativeId,
        author: author,
        text: text,
        createdAt: DateTime.now(),
      );
    final comment = _publicFeedRepository == null
        ? await _repository.addPublicationComment(draft)
        : await _publicFeedRepository.addComment(draft);
    _publicationComments = [..._publicationComments, comment];
    notifyListeners();
  }
}
