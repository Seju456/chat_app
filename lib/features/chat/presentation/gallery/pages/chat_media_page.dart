import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/app_image.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_view.dart';
import '../../../../../core/widgets/skeleton.dart';
import '../../load_status.dart';
import '../media_cubit.dart';
import 'gallery_page.dart';

/// Grid of every cached photo in a chat.
class ChatMediaPage extends StatelessWidget {
  const ChatMediaPage({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  final String chatId;
  final String chatName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MediaCubit>(param1: chatId)..load(),
      child: Scaffold(
        appBar: AppBar(title: Text(chatName)),
        body: BlocBuilder<MediaCubit, MediaState>(
          builder: (context, state) => switch (state.status) {
            LoadStatus.loading => Shimmer(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(2),
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                children: List.generate(
                  15,
                  (_) => const SkeletonBox(height: double.infinity, radius: 0),
                ),
              ),
            ),
            LoadStatus.failure => ErrorView(
              failure: state.failure!,
              onRetry: context.read<MediaCubit>().load,
            ),
            LoadStatus.success when state.images.isEmpty => const EmptyState(
              icon: Icons.photo_library_outlined,
              title: 'No media yet',
              message: 'Photos shared in this chat will appear here.',
            ),
            LoadStatus.success => LayoutBuilder(
              builder: (context, constraints) => GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: constraints.maxWidth > 600 ? 180 : 140,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: state.images.length,
                itemBuilder: (context, i) {
                  final (url, _) = state.images[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      GalleryPage.route(
                        initialIndex: i,
                        images: [
                          for (var k = 0; k < state.images.length; k++)
                            GalleryImage(
                              url: state.images[k].$1,
                              heroTag: 'media-$k',
                              message: state.images[k].$2,
                            ),
                        ],
                      ),
                    ),
                    child: Hero(
                      tag: 'media-$i',
                      child: AppImage(url: url),
                    ),
                  );
                },
              ),
            ),
          },
        ),
      ),
    );
  }
}
