import 'package:flutter/foundation.dart';

import '../../domain/entities/publication_comment.dart';
import '../../domain/entities/workspace_publication.dart';
import '../../domain/repositories/public_feed_repository.dart';

class PublicFeedController extends ChangeNotifier {
  final PublicFeedRepository _repository;

  PublicFeedController(this._repository);

  List<WorkspacePublication> _publications = [];
  List<PublicationComment> _comments = [];
  bool _isLoading = false;
  String? _error;

  List<WorkspacePublication> get publications =>
      List.unmodifiable(_publications);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PublicationComment> commentsFor(String publicationId) =>
      _comments.where((item) => item.publicationId == publicationId).toList();

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _publications = await _repository.getPublications();
      _comments = await _repository.getComments();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required WorkspacePublication publication,
    required String author,
    required String text,
  }) async {
    final comment = await _repository.addComment(
      PublicationComment(
        id: '',
        publicationId: publication.id,
        initiativeId: publication.initiativeId,
        author: author,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
    _comments = [..._comments, comment];
    notifyListeners();
  }
}
