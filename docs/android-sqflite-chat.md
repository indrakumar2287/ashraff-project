# Add a local SQLite subscription to the current chat (Android)

This guide is specific to the current chat under `lib/screens/chat/`. It
changes the data flow so the UI subscribes to SQLite:

```text
Firestore snapshot -> ChatController -> sqflite upsert -> local change event
    -> SQLite query -> StreamBuilder -> chat UI
```

The UI must not render the Firestore message snapshot directly. Firestore
continues to send and synchronize messages; every successful remote update is
first written to SQLite, and the SQLite stream supplies the rows shown on
screen.

Important: `sqflite` does not provide a reactive `watch()` query. Add a Dart
`StreamController` notification layer to the database service. Emit a local
change event only after the corresponding SQLite write succeeds. All writes
that should refresh the UI must go through that service.

## Current chat files

- `lib/screens/chat/controller/chat_module_controller.dart`: Firestore chat
  and message queries, selected chat state, and send methods.
- `lib/screens/chat/view/chat_list_screen.dart`: currently displays chats
  using a Firestore `StreamBuilder`.
- `lib/screens/chat/view/chat_screen.dart`: currently displays messages
  using a Firestore `StreamBuilder`.
- `lib/screens/chat/view/message_bubble.dart`: expects maps with `senderId`,
  `senderName`, `message`, `createdAt`, `type`, and `image`.

The Firestore paths are `User Chats/{chatId}` and
`User Chats/{chatId}/Messages/{messageId}`.

## File-by-file changes

| File | Change |
| --- | --- |
| `pubspec.yaml` | No change. `sqflite` and `path` are already dependencies. |
| `lib/services/chat_local_database.dart` | Create the SQLite schema, CRUD methods, broadcast change stream, and `watchChats`/`watchMessages` query streams. |
| `lib/screens/chat/controller/chat_module_controller.dart` | Subscribe to Firestore as an ingestion source only. Upsert snapshots in SQLite and expose local SQLite streams to the screens. |
| `lib/screens/chat/view/chat_list_screen.dart` | Replace the Firestore chat `StreamBuilder` with a `StreamBuilder` using the controller's local chat stream. |
| `lib/screens/chat/view/chat_screen.dart` | Replace the Firestore message `StreamBuilder` with a `StreamBuilder` using the controller's local message stream. |
| `lib/screens/chat/view/message_bubble.dart` | No change if the controller converts SQLite rows into the existing map shape. |
| `lib/utils/local_db.dart` | No change. This is the student database helper; keep its file and tables separate. |
| `lib/main.dart` | No change. Open the chat database lazily. Do not uncomment the old student `DatabaseHelper` call. |

SQLite needs no Android manifest permission or Gradle setup.

## 1. Create `lib/services/chat_local_database.dart`

Use the existing `sqflite` and `path` packages. Give chat storage its own file,
`chat_cache.db`; do not reuse the existing student database.

```dart
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class _ChatCacheChange {
  const _ChatCacheChange({
    required this.ownerUid,
    this.chatId,
    this.chatsChanged = false,
  });

  final String ownerUid;
  final String? chatId;
  final bool chatsChanged;
}

class ChatLocalDatabase {
  ChatLocalDatabase._();

  static final instance = ChatLocalDatabase._();
  final _changes = StreamController<_ChatCacheChange>.broadcast();
  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final path = join(await getDatabasesPath(), 'chat_cache.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            owner_uid TEXT NOT NULL,
            remote_chat_id TEXT NOT NULL,
            member_ids TEXT NOT NULL DEFAULT '[]',
            member_names TEXT NOT NULL DEFAULT '[]',
            last_message TEXT NOT NULL DEFAULT '',
            updated_at_ms INTEGER,
            UNIQUE(owner_uid, remote_chat_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            owner_uid TEXT NOT NULL,
            remote_chat_id TEXT NOT NULL,
            remote_message_id TEXT NOT NULL,
            sender_id TEXT NOT NULL DEFAULT '',
            sender_name TEXT NOT NULL DEFAULT '',
            message TEXT NOT NULL DEFAULT '',
            message_type TEXT NOT NULL DEFAULT 'text',
            image TEXT,
            created_at_ms INTEGER,
            UNIQUE(owner_uid, remote_chat_id, remote_message_id)
          )
        ''');
        await db.execute('''
          CREATE INDEX messages_by_chat_time
          ON messages(owner_uid, remote_chat_id, created_at_ms)
        ''');
      },
    );
  }

  // Add the methods described below to this class.
}
```

Add `dart:convert` for encoding `membersIds` and `memberNames` as JSON text
when saving a chat, and decoding them when reading chats. Publish local chat
maps with `memberNames`, `membersIds`, and `lastMessage` keys so the existing
chat-list logic can still use them.

### Add writes and reads

Implement these methods in `ChatLocalDatabase`:

- `upsertChat(ownerUid, row)`: insert/replace by the unique
  `(owner_uid, remote_chat_id)` key. After the insert succeeds, emit
  `_ChatCacheChange(ownerUid: ownerUid, chatsChanged: true)`.
- `upsertMessages(ownerUid, chatId, rows)`: batch-insert/replace by the unique
  `(owner_uid, remote_chat_id, remote_message_id)` key. After the batch commits,
  emit `_ChatCacheChange(ownerUid: ownerUid, chatId: chatId)`.
- `getChats(ownerUid)`: select rows for that UID ordered by
  `updated_at_ms DESC`, decode the JSON member arrays, and map database column
  names to the chat-list keys.
- `getMessages(ownerUid, chatId)`: select rows for that UID and chat ordered
  by `created_at_ms ASC`.
- `deleteUserCache(ownerUid)`: if required by sign-out policy, delete only
  that user's rows from both tables.

Use `ConflictAlgorithm.replace` for the two upserts and `whereArgs` for query
values. Use a transaction/batch for multi-message snapshots. Emit change
events only after a successful write/commit; propagate failures instead of
emitting success-shaped empty data.

### Add a query stream that emits the initial rows and later changes

Add this private helper to `ChatLocalDatabase`. It subscribes to notifications
before querying the initial rows, then re-queries SQLite after matching writes.
Errors reading SQLite are sent to the stream as errors.

```dart
Stream<List<Map<String, Object?>>> _watchRows({
  required bool Function(_ChatCacheChange change) matches,
  required Future<List<Map<String, Object?>>> Function() query,
}) {
  late final StreamController<List<Map<String, Object?>>> output;
  StreamSubscription<_ChatCacheChange>? subscription;

  Future<void> refresh() async {
    try {
      final rows = await query();
      if (!output.isClosed) output.add(rows);
    } catch (error, stackTrace) {
      if (!output.isClosed) output.addError(error, stackTrace);
    }
  }

  output = StreamController<List<Map<String, Object?>>>(
    onListen: () {
      subscription = _changes.stream.listen((change) {
        if (matches(change)) unawaited(refresh());
      });
      unawaited(refresh());
    },
    onCancel: () async {
      await subscription?.cancel();
    },
  );
  return output.stream;
}
```

Add the two public stream methods using that helper:

```dart
Stream<List<Map<String, Object?>>> watchChats(String ownerUid) {
  return _watchRows(
    matches: (change) =>
        change.ownerUid == ownerUid && change.chatsChanged,
    query: () => getChats(ownerUid),
  );
}

Stream<List<Map<String, Object?>>> watchMessages(
  String ownerUid,
  String chatId,
) {
  return _watchRows(
    matches: (change) =>
        change.ownerUid == ownerUid && change.chatId == chatId,
    query: () => getMessages(ownerUid, chatId),
  );
}
```

Ensure `getChats` and `getMessages` return rows in the shape used by their
streams. Do not close the shared `_changes` controller after an individual
screen closes; each query stream cancels only its own notification
subscription.

## 2. Change `chat_module_controller.dart`

In `lib/screens/chat/controller/chat_module_controller.dart`:

1. Import `dart:async`, `dart:convert`, `cloud_firestore`,
   `firebase_auth`, and the new `chat_local_database.dart` as needed.
2. Keep `loadChats()` and `getChat(chatId)` as Firestore query factories, but
   stop passing their streams to the UI.
3. Add a Firestore chat `StreamSubscription` and a Firestore message
   `StreamSubscription`; cancel them in `onClose()`.
4. Expose a local chats stream and a nullable local messages stream for the
   screens.
5. Add `startWatchingChats()`: set the local chats stream to
   `ChatLocalDatabase.instance.watchChats(currentUid)`, then listen to
   `loadChats()`. For each Firestore chat doc, map it to a local row and call
   `upsertChat`. The UI will be notified by the local stream after that write.
6. Add `openChat(chatId, otherUserId, otherUserName)`: set the existing
   selected-user/chat fields, set the local messages stream to
   `watchMessages(currentUid, chatId)`, cancel the prior Firestore message
   subscription, and listen to `getChat(chatId)`. For each snapshot, map its
   docs to local rows and await `upsertMessages`.

Map Firestore chat documents as follows:

| SQLite column | Current Firestore value |
| --- | --- |
| `owner_uid` | Signed-in user's Firebase UID |
| `remote_chat_id` | Chat document ID |
| `member_ids` | JSON encoding of `membersIds` |
| `member_names` | JSON encoding of `memberNames` |
| `last_message` | `lastMessage` |
| `updated_at_ms` | `lastMessageTime` converted from `Timestamp` to milliseconds, or null |

Map Firestore message documents as follows:

| SQLite column | Current Firestore value |
| --- | --- |
| `owner_uid` | Signed-in user's Firebase UID |
| `remote_chat_id` | Selected chat ID |
| `remote_message_id` | Message document ID |
| `sender_id` | `senderId` |
| `sender_name` | `senderName` |
| `message` | `message` |
| `message_type` | `type`, defaulting to `text` |
| `image` | `image` for image messages, otherwise null |
| `created_at_ms` | `createdAt` converted from `Timestamp` to milliseconds, or null |

When adapting SQLite rows for `MessageBubble`, return the existing UI keys:
`senderId`, `senderName`, `message`, `type`, and `image`. Convert a non-null
`created_at_ms` to
`Timestamp.fromMillisecondsSinceEpoch(created_at_ms)` and set `createdAt` to
null otherwise. This keeps `message_bubble.dart` unchanged.

The current `sendMessage()` updates the chat's `lastMessage` but not its
`lastMessageTime`. Add
`'lastMessageTime': FieldValue.serverTimestamp()` to the same merged Firestore
chat update so the local chat stream can order recently active chats. If image
sends should update the preview too, update the chat document from
`sendMediaMsg()` as well.

When `createANdOpenNewChat()` creates a Firestore chat, upsert its chat row and
call `openChat(...)` before navigating. For taps on existing chats, the list
screen calls `openChat(...)` before navigation. These paths make sure the
local message stream is selected before `ChatScreen` subscribes.

## 3. Change `chat_list_screen.dart`

In `lib/screens/chat/view/chat_list_screen.dart`, remove the
`StreamBuilder(stream: controller.loadChats(), ...)`. Replace it with a
`StreamBuilder<List<Map<String, Object?>>>` whose stream is the controller's
local chats stream. Continue using the same `ListView.builder`, tile,
`memberNames`, `membersIds`, and `lastMessage` display logic; use the local
maps emitted by `watchChats`.

In the current tile's `onTap`, replace direct writes to
`selectedUsername`, `selectedUserId`, and `selectedChatId` with an async call
to `controller.openChat(chatId, otherUserId, otherUserName)`, then navigate
to `RouteNames.chatModuleScreen`.

Start `controller.startWatchingChats()` once when `ChatController` is
initialized (for example in `onInit()` or the screen's `initState`), not
inside `build()`. The current screen calls `Get.put(ChatController())` in
`build()`; move that registration to `initState` if using the screen to start
the subscription. Preserve the floating action button and
`RouteNames.newChatModule`.

## 4. Change `chat_screen.dart`

In `lib/screens/chat/view/chat_screen.dart`, remove the current
`StreamBuilder<QuerySnapshot<...>>` that calls `controller.getChat(...)`.
Replace it with a `StreamBuilder` listening to the controller's local message
stream. The builder should pass the adapted SQLite rows to the existing
`MessageBubble`:

```dart
StreamBuilder<List<Map<String, dynamic>>>(
  stream: controller.localMessagesStream,
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return Center(child: Text('Could not load messages: ${snapshot.error}'));
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    final messages = snapshot.data!;
    return ListView.builder(
      controller: scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageBubble(msg: messages[index]);
      },
    );
  },
)
```

Keep the composer, send controls, and scroll controller. `openChat(...)` must
be called before this screen is opened so `localMessagesStream` is set.

## 5. Verify the local subscription

Run on an Android emulator or device:

```sh
flutter pub get
flutter run
```

Verify the data path in this order:

1. Open a chat. `watchMessages` first emits the rows already in SQLite, even
   before Firestore returns.
2. Send a message from this or another signed-in device.
3. Confirm the Firestore listener in `ChatController` awaits the SQLite
   upsert.
4. Confirm the upsert emits a change event after commit.
5. Confirm the local query stream re-queries SQLite and the screen displays
   the new row from that query.
6. Confirm repeated Firestore snapshots replace the existing row rather than
   duplicate it.
7. Reopen the chat offline; previously cached messages should still appear.

This notification stream only observes writes made through
`ChatLocalDatabase` in this app process. If another code path writes directly
to the database, it must also emit a change event or the UI will not be
notified. Offline sending/retry is not included: the cache displays saved
messages but does not queue undelivered sends.

When changing tables later, increment the database version and add an
`onUpgrade` migration that preserves cached rows.
