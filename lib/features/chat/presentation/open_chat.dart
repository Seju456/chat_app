import '../domain/entities/chat.dart';

/// Opens [chat]; with [messageId], also scrolls to and highlights it.
typedef OpenChat = void Function(Chat chat, {String? messageId});
