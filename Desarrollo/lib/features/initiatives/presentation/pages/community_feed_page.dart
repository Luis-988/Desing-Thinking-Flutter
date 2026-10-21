import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_snack.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/providers/session_controller.dart';
import '../../domain/entities/publication_comment.dart';
import '../../domain/entities/workspace_publication.dart';
import '../providers/initiatives_controller.dart';
import '../providers/public_feed_controller.dart';

class CommunityFeedPage extends StatelessWidget {
  const CommunityFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<PublicFeedController>();
    return Column(
      children: [
        const ScreenHeader(
          icon: Icons.forum_outlined,
          title: 'Comunidad',
          subtitle: 'Comparte ideas, avances y feedback',
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: feed.load,
            child: _FeedBody(feed: feed),
          ),
        ),
      ],
    );
  }
}

class _FeedBody extends StatelessWidget {
  final PublicFeedController feed;

  const _FeedBody({required this.feed});

  @override
  Widget build(BuildContext context) {
    if (feed.isLoading && feed.publications.isEmpty) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: SkeletonList(count: 3),
      );
    }
    if (feed.error != null && feed.publications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [ErrorState(message: feed.error!, onRetry: feed.load)],
      );
    }
    if (feed.publications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          EmptyState(
            icon: Icons.auto_awesome_outlined,
            title: 'Aún no hay avances',
            message: 'Los avances de los proyectos aparecerán aquí para que toda la comunidad pueda conocerlos.',
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: feed.publications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _PublicationCard(
        publication: feed.publications[index],
        comments: feed.commentsFor(feed.publications[index].id),
      ),
    );
  }
}

class _PublicationCard extends StatelessWidget {
  final WorkspacePublication publication;
  final List<PublicationComment> comments;

  const _PublicationCard({required this.publication, required this.comments});

  Future<void> _comment(BuildContext context) async {
    final textController = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comentar avance'),
        content: TextField(
          controller: textController,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Escribe un comentario para la comunidad',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final value = textController.text.trim();
              if (value.isNotEmpty) Navigator.pop(context, value);
            },
            child: const Text('Publicar comentario'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (text == null || !context.mounted) return;
    final user = context.read<SessionController>().user;
    if (user == null) return;
    try {
      await context.read<PublicFeedController>().addComment(
        publication: publication,
        author: user.name,
        text: text,
      );
    } catch (error) {
      if (context.mounted) showAppSnack(context, messageOf(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initiative = context.read<InitiativesController>().initiativeById(
      publication.initiativeId,
    );
    final isAuthenticated = context.watch<SessionController>().isAuthenticated;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.violetBg,
                  child: Icon(Icons.campaign_outlined, color: AppColors.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        initiative?.title ?? 'Proyecto de innovación',
                        style: AppText.caption.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Publicado por ${publication.author}',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(publication.title, style: AppText.sectionTitle),
            const SizedBox(height: 8),
            Text(publication.text, style: AppText.body),
            if (comments.isNotEmpty) ...[
              const Divider(height: 28),
              for (final comment in comments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${comment.author}: ${comment.text}',
                    style: AppText.body,
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: isAuthenticated ? () => _comment(context) : null,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Comentar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
