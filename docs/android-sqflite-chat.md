# Chat messages with sqflite

This guide describes the local chat-message cache added to this project.
Firestore remains responsible for sending and syncing messages. The chat
screen reads its message list from SQLite:

```text
Firestore message snapshot
    -> ChatController saves rows in SQLite
    -> ChatLocalDatabase notifies its stream
    -> StreamBuilder reloads SQLite rows
    -> MessageBubble displays those rows
```

`sqflite` does not have a built-in reactive query. The database service uses a
Dart broadcast stream to notify the screen after a successful database write.

## What changed

| File | Change |
| --- | --- |
| `lib/services/chat_local_database.dart` | New service. Creates `chat_messages.db`, saves and reads message rows, and emits a stream update after saving. |
| `lib/screens/chat/controller/chat_controller.dart` | Listens to Firestore for incoming messages, saves each snapshot locally, and provides a stream of local rows adapted for the UI. |
| `lib/screens/chat/view/chat_list_screen.dart` | Calls `openChat()` before opening a selected conversation. The chat list itself still comes from Firestore. |
| `lib/screens/chat/view/chat_screen.dart` | Subscribes to the controller's local message stream instead of displaying the Firestore snapshot. |
| `lib/screens/chat/view/message_bubble.dart` | Unchanged; the controller converts SQLite rows to the same map fields it already uses. |
| `lib/utils/local_db.dart` and `lib/main.dart` | Unchanged; these continue to support the existing student database and app startup. |
| `pubspec.yaml` | Unchanged; `sqflite` and `path` were already dependencies. |

## How one message reaches the screen

1. `ChatController.openChat()` subscribes to the selected chat's Firestore
   message query.
2. The Firestore listener converts each message to SQLite column names and
   calls `ChatLocalDatabase.saveMessages()`.
3. `saveMessages()` inserts/replaces rows, then emits a local change event.
4. `watchMessages()` responds to that event by querying SQLite again.
5. `ChatScreen` receives the local rows through `StreamBuilder` and passes
   them to the existing `MessageBubble`.

The local database uses the signed-in user's UID, chat ID, and Firestore
message document ID as its unique key. Repeated Firestore snapshots therefore
update existing rows rather than adding duplicates. The first local query also
emits immediately, so previously cached messages can display before Firestore
has returned.

## Main implementation points

### `lib/services/chat_local_database.dart`

This new file owns the `messages` table:

- `owner_uid` and `chat_id` scope messages to the signed-in user and
  conversation.
- `remote_message_id` keeps the Firestore document ID for upserts.
- Sender, message, type, image URL, and timestamp fields are stored locally.
- `saveMessages()` commits a batch before notifying listeners.
- `watchMessages()` emits an initial SQLite query and runs another query after
  a local save notification.

The notification stream is an in-app change signal, not a feature supplied by
SQLite. Writes that should update the visible list must use
`ChatLocalDatabase.saveMessages()`.

### `lib/screens/chat/controller/chat_controller.dart`

`openChat(chatId, otherUserId, otherUserName)` selects the chat, creates the
local `watchMessages()` stream, and starts the Firestore listener. The
Firestore fields are converted as follows:

| Firestore field | SQLite column |
| --- | --- |
| Signed-in UID | `owner_uid` |
| Chat document ID | `chat_id` |
| Message document ID | `remote_message_id` |
| `senderId` | `sender_id` |
| `senderName` | `sender_name` |
| `message` | `message` |
| `type` | `message_type` |
| `image` | `image` |
| `createdAt` timestamp | `created_at_ms` |

The controller converts the local column names back to the existing
`MessageBubble` map keys (`senderId`, `senderName`, `message`, `type`, `image`,
and `createdAt`).

### Chat screens

In `chat_list_screen.dart`, tapping a Firestore chat calls `openChat()` before
navigating. The list continues to query Firestore; only the selected chat's
messages are cached locally. `createANdOpenNewChat()` also calls `openChat()`
after creating its Firestore chat, so both ways of opening a conversation set
up the same local subscription.

In `chat_screen.dart`, the `StreamBuilder` listens to
`controller.localMessagesStream`, not `controller.getChat()`. Sending still
writes to Firestore. The Firestore listener then saves the resulting message
to SQLite, and the local stream updates the displayed list.

## Test it

Run the app on an Android emulator or device:

```sh
flutter run
```

Open a chat online and send a message. Confirm that it appears from the local
stream. Reopen the chat and confirm cached messages appear before the Firestore
refresh completes. Repeated snapshots should not duplicate messages. A
different signed-in user should not see the first user's cached rows.

This implementation caches received/successfully synced messages. It does not
queue messages for sending while offline. The notification stream only sees
writes made through `ChatLocalDatabase` in this app process.
