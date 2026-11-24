/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
// import {onRequest} from "firebase-functions/https";
// import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

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

