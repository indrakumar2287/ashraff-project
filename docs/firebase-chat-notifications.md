# Send a push notification for a new chat message

This guide uses the `chat_module` chat flow in this app. It stores chats at
`User Chats/{chatId}` and messages at
`User Chats/{chatId}/Messages/{messageId}`. A Firebase Cloud Function watches
for new message documents and sends an FCM push notification to the other chat
members.

## 1. Check the recipient's FCM token

The app's signup flow saves an FCM token in
`Users/{userId}.fcmToken`. Check that each recipient's user document has a
non-empty `fcmToken` field. Existing users may need to sign in again or refresh
their token before they can receive notifications.

Keep the token current: save the token returned by
`FirebaseMessaging.instance.getToken()` to the signed-in user's `Users/{uid}`
document, and update that field when `FirebaseMessaging.instance.onTokenRefresh`
emits a new token. Merge the update so it does not overwrite the user's name
and email. The app currently stores the token at signup; for login and token
refresh, add this to the notification service and call it after authentication:

```dart
Future<void> syncFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userDoc = FirebaseFirestore.instance.collection('Users').doc(user.uid);
  Future<void> saveToken(String token) =>
      userDoc.set({'fcmToken': token}, SetOptions(merge: true));

  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) await saveToken(token);
  FirebaseMessaging.instance.onTokenRefresh.listen(saveToken);
}
```

Import `firebase_auth`, `cloud_firestore`, and `firebase_messaging` where this
method is added. Call it once after each successful sign-in; avoid registering
multiple token-refresh listeners during the same app session.

## 2. Set up Cloud Functions

From the project root, install the Firebase CLI if needed, sign in, and select
the Firebase project used by the app:

```sh
npm install -g firebase-tools
firebase login
firebase use notebox-1919
firebase init functions
```

Choose **TypeScript** when prompted and avoid overwriting unrelated Firebase
configuration. Functions deployment requires the Firebase project to be on
the Blaze (pay-as-you-go) plan.

## 3. Add the Firestore trigger

Put this in `functions/src/index.ts` (or add the export to the file created by
the CLI):

```ts
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

initializeApp();

export const notifyOnNewChatMessage = onDocumentCreated(
  "User Chats/{chatId}/Messages/{messageId}",
  async (event) => {
    const message = event.data?.data();
    if (!message) return;

    const db = getFirestore();
    const chatSnapshot = await db
      .collection("User Chats")
      .doc(event.params.chatId)
      .get();
    const memberIds = chatSnapshot.data()?.membersIds;

    if (!Array.isArray(memberIds)) return;

    const recipientIds = memberIds.filter(
      (id): id is string =>
        typeof id === "string" && id !== message.senderId,
    );
    const recipientSnapshots = await Promise.all(
      recipientIds.map((id) => db.collection("Users").doc(id).get()),
    );
    const tokens = recipientSnapshots
      .map((snapshot) => snapshot.data()?.fcmToken)
      .filter((token): token is string => typeof token === "string" && token.length > 0);

    if (tokens.length === 0) return;

    await getMessaging().sendEachForMulticast({
      tokens,
      notification: {
        title: String(message.senderName ?? "New message"),
        body: String(message.message ?? "You received a message"),
      },
      data: {
        chatId: event.params.chatId,
        messageId: event.params.messageId,
      },
    });
  },
);
```

The function reads `membersIds`, `senderId`, `senderName`, and `message`, which
match the current `chat_module` data. It excludes the sender and notifies the
other members. For a group chat, it sends to each other member that has a
saved token.

## 4. Deploy and test

From the project root, deploy the function:

```sh
firebase deploy --only functions:notifyOnNewChatMessage
```

Sign in as two users on separate devices (or emulators), confirm both users
have tokens in Firestore, then send a message from one account. The other
account should receive a notification. When the app is in the foreground,
`NotificationService` displays the incoming FCM notification locally; in the
background, the operating system displays the notification payload.

## Notes

- Never put Firebase Admin credentials or server keys in the Flutter app. The
  Cloud Function uses the Admin SDK on Firebase's trusted server.
- Android notification permission is declared in the app manifest. For iOS,
  configure push notifications and an APNs key in the Firebase project.
- This repository also has a separate chat flow using
  `chats/{chatId}/messages` and different message field names. This trigger
  does not watch that flow; if that is the chat screen in use, change the
  trigger path and adapt the member and message fields to that schema.
