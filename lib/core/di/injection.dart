import 'package:get_it/get_it.dart';

import '../../features/chat/data/datasources/chat_local_data_source.dart';
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/datasources/fake_chat_remote_data_source.dart';
import '../../features/chat/data/datasources/message_local_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/data/repositories/message_repository_impl.dart';
import '../../features/chat/domain/entities/message.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/repositories/message_repository.dart';
import '../../features/chat/domain/usecases/chat_usecases.dart';
import '../../features/chat/domain/usecases/message_usecases.dart';
import '../../features/chat/presentation/chat_list/cubit/chat_list_cubit.dart';
import '../../features/chat/presentation/conversation/cubit/conversation_cubit.dart';
import '../../features/chat/presentation/conversation/cubit/voice_playback_cubit.dart';
import '../../features/chat/presentation/forward/cubit/forward_cubit.dart';
import '../../features/chat/presentation/gallery/media_cubit.dart';
import '../../features/chat/presentation/search/cubit/search_cubit.dart';
import '../../features/settings/data/settings_repository_impl.dart';
import '../../features/settings/domain/settings_repository.dart';
import '../../features/settings/presentation/theme_cubit.dart';
import '../audio/audio_engine.dart';
import '../audio/voice_recorder.dart';
import '../audio/voice_source_resolver.dart';
import '../database/app_database.dart';
import '../media/image_picker_service.dart';

final sl = GetIt.instance;

/// Composition root. Everything is wired against interfaces, so swapping
/// e.g. the fake backend for a real one is a one-line change here.
Future<void> configureDependencies({
  AppDatabase? database,
  ChatRemoteDataSource? remote,
  AudioEngine? audioEngine,
  VoiceRecorder? voiceRecorder,
  VoiceSourceResolver? voiceSourceResolver,
  ImagePickerService? imagePicker,
}) async {
  // Core
  sl.registerLazySingleton<AppDatabase>(
    () => database ?? AppDatabase(),
    dispose: (db) => db.close(),
  );

  // Audio (plugins behind interfaces; tests pass fakes)
  sl
    ..registerLazySingleton<AudioEngine>(() => audioEngine ?? JustAudioEngine())
    ..registerLazySingleton<VoiceRecorder>(
      () => voiceRecorder ?? MicVoiceRecorder(),
      dispose: (r) => r.dispose(),
    )
    ..registerLazySingleton<VoiceSourceResolver>(
      () => voiceSourceResolver ?? FileVoiceSourceResolver(),
    )
    ..registerLazySingleton<ImagePickerService>(
      () => imagePicker ?? DeviceImagePickerService(),
    );

  // Data sources
  sl
    ..registerLazySingleton<ChatRemoteDataSource>(
      () => remote ?? FakeChatRemoteDataSource(),
      dispose: (r) => r.dispose(),
    )
    ..registerLazySingleton(() => ChatLocalDataSource(sl()))
    ..registerLazySingleton(() => MessageLocalDataSource(sl()));

  // Repositories
  sl
    ..registerLazySingleton<ChatRepository>(
      () =>
          ChatRepositoryImpl(remote: sl(), chatLocal: sl(), messageLocal: sl()),
    )
    ..registerLazySingleton<MessageRepository>(
      () => MessageRepositoryImpl(
        remote: sl(),
        messageLocal: sl(),
        chatLocal: sl(),
      ),
      dispose: (r) => (r as MessageRepositoryImpl).dispose(),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    );

  // Use cases
  sl
    ..registerLazySingleton(() => WatchChats(sl()))
    ..registerLazySingleton(() => WatchArchivedSummary(sl()))
    ..registerLazySingleton(() => WatchChat(sl()))
    ..registerLazySingleton(() => RefreshChats(sl()))
    ..registerLazySingleton(() => TogglePinChat(sl()))
    ..registerLazySingleton(() => SetChatArchived(sl()))
    ..registerLazySingleton(() => MarkChatRead(sl()))
    ..registerLazySingleton(() => SearchChats(sl()))
    ..registerLazySingleton(() => GetMessages(sl()))
    ..registerLazySingleton(() => WatchMessageChanges(sl()))
    ..registerLazySingleton(() => SendMessage(sl()))
    ..registerLazySingleton(() => ResendMessage(sl()))
    ..registerLazySingleton(() => ForwardMessages(sl()))
    ..registerLazySingleton(() => GetChatMedia(sl()))
    ..registerLazySingleton(() => SetActiveChat(sl()));

  // Cubits (factories: a fresh instance per screen)
  sl
    ..registerLazySingleton(() => ThemeCubit(sl()))
    ..registerLazySingleton(
      () => VoicePlaybackCubit(sl(), sl()),
      dispose: (c) => c.close(),
    )
    ..registerFactoryParam<ChatListCubit, bool, void>(
      (archived, _) => ChatListCubit(
        archived: archived,
        watchChats: sl(),
        watchArchivedSummary: sl(),
        refreshChats: sl(),
        togglePinChat: sl(),
        setChatArchived: sl(),
        markChatRead: sl(),
      ),
    )
    ..registerFactory(() => SearchCubit(sl()))
    ..registerFactoryParam<ConversationCubit, String, void>(
      (chatId, _) => ConversationCubit(
        chatId: chatId,
        watchChat: sl(),
        getMessages: sl(),
        watchMessageChanges: sl(),
        sendMessage: sl(),
        resendMessage: sl(),
        markChatRead: sl(),
        setActiveChat: sl(),
      ),
    )
    ..registerFactoryParam<ForwardCubit, List<Message>, void>(
      (messages, _) => ForwardCubit(
        messages: messages,
        watchChats: sl(),
        forwardMessages: sl(),
      ),
    )
    ..registerFactoryParam<MediaCubit, String, void>(
      (chatId, _) => MediaCubit(sl(), chatId),
    );
}
