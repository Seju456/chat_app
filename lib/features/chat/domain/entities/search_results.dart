import 'package:equatable/equatable.dart';

import 'chat.dart';
import 'message.dart';

class MessageSearchHit extends Equatable {
  const MessageSearchHit({required this.message, required this.chat});

  final Message message;
  final Chat chat;

  @override
  List<Object?> get props => [message, chat];
}

class SearchResults extends Equatable {
  const SearchResults({this.chats = const [], this.messages = const []});

  static const empty = SearchResults();

  final List<Chat> chats;
  final List<MessageSearchHit> messages;

  bool get isEmpty => chats.isEmpty && messages.isEmpty;

  @override
  List<Object?> get props => [chats, messages];
}
