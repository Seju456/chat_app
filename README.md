# Chat App

A WhatsApp-style chat client in Flutter, built with Clean Architecture,
**Cubit** (flutter_bloc) state management and a **Drift** (SQLite) local cache.

## Running

```bash
flutter pub get
dart run build_runner build   # regenerates lib/core/database/app_database.g.dart
flutter run                   # Android / iOS / macOS (needs Xcode for Apple targets)
flutter test
```

There is no real backend. `FakeChatRemoteDataSource` acts like one: network
latency, a ~10% failure rate, cursor pagination, delivery/read receipts, and
replies from the other person. About every 45 s a message also arrives in a
random chat. Seed photos come from `picsum.photos`; photos you send are
picked from the device gallery (multi-select, up to 30) with `image_picker`,
reviewed on a preview screen (remove, add more, caption) and stored in the
app's documents folder.

Voice messages are real audio: holding the mic records with `record` (AAC
`.m4a` in the app's documents folder), and one shared `just_audio` player
plays them, so only one plays at a time. The demo's seed voice messages
have no recording, so they play a generated placeholder tone of the
right length. Microphone permission is declared for Android, iOS and macOS.

To use a real API, implement `ChatRemoteDataSource` and register it in
`lib/core/di/injection.dart`.

## Architecture

```
lib/
├── core/            database (drift), di (get_it), error, theme, utils, reusable widgets
└── features/
    ├── chat/
    │   ├── domain/        entities, repository interfaces, use cases (pure Dart)
    │   ├── data/          DTOs, mappers, remote + local data sources, repository impls
    │   └── presentation/  chat_list, conversation, search, forward, gallery (cubit + pages + widgets)
    ├── settings/          theme mode persisted in drift
    └── home/              responsive shell (one pane on phones, two panes on wide screens)
```

- **Dependency rule:** presentation → domain ← data. Cubits depend only on use
  cases. Repositories return `Result<T>` (`Success` / `Err(Failure)`) and never
  throw. Data sources throw `NetworkException` / `ServerException`, and the
  repository converts them to typed `Failure`s.
- **Offline-first:** the UI reads from Drift streams only. The network refreshes
  the cache. Message pages use the cache first and go to the network only when
  the cache runs out. The cursor is `(createdAt, id)` keyset pagination, so
  pages stay stable while new messages arrive. When the app is offline but has
  cached data, it shows that data with a banner instead of an error screen.
- **Why Cubit:** every screen's state is a small, explicit state machine
  (loading → success/failure, with paging/selection/reply sub-state). Cubits
  give the predictable, testable state of Bloc without event boilerplate. Each
  screen gets its own cubit from a get_it factory, so state is scoped and is
  disposed with the screen.
- **Business rules live in use cases.** Examples: at most 3 pinned chats, at
  most 5 forward recipients, message validation.

## Features

Infinite pagination · local caching · search (chats + cached messages, debounced,
highlighted) · message grouping with date separators · reply (swipe or select) ·
multi-select forward / copy · hold-to-record voice messages (slide to cancel)
with real audio, seekable waveform, speed control and one-at-a-time playback ·
image albums + full-screen gallery (zoom, swipe, thumbnails) + per-chat media grid · scroll-to-bottom FAB
with new-message badge · unread badges · pinned & archived chats (swipe or
long-press, with undo) · failed-message retry · skeleton loading · empty and
error states · light / dark / system theme · two-pane layout ≥ 840 px.

## Tests

- `message_grouping_test` – grouping and date separators
- `message_repository_test` – pagination with no gaps or duplicates, cache
  reads while offline, failed send then resend, pin/archive rules, search
  (in-memory drift)
- `chat_list_cubit_test` – loading, error, offline banner and empty-state transitions
- `app_smoke_test` – the whole app with real DI on phone and tablet sizes:
  open chat, send, swipe to reply, archive, search, dark two-pane layout
