import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/message.dart';
import '../../domain/usecases/message_usecases.dart';
import '../load_status.dart';

class MediaState extends Equatable {
  const MediaState({
    this.status = LoadStatus.loading,
    this.images = const [],
    this.failure,
  });

  final LoadStatus status;

  /// Flattened (url, message) pairs, newest first.
  final List<(String, Message)> images;
  final Failure? failure;

  @override
  List<Object?> get props => [status, images, failure];
}

class MediaCubit extends Cubit<MediaState> {
  MediaCubit(this._getChatMedia, this.chatId) : super(const MediaState());

  final GetChatMedia _getChatMedia;
  final String chatId;

  Future<void> load() async {
    emit(const MediaState());
    final result = await _getChatMedia(chatId);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => MediaState(status: LoadStatus.failure, failure: f),
        (messages) => MediaState(
          status: LoadStatus.success,
          images: [
            for (final m in messages)
              for (final url in m.mediaUrls) (url, m),
          ],
        ),
      ),
    );
  }
}
