import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> chatsForCurrentUser() {
    final user = currentUser;
    if (user == null) {
      return Stream.error(StateError('Sign in to see your chats.'));
    }

    return _firestore
        .collection('chats')
        .where('members', arrayContains: user.uid)
        .snapshots();
  }

  Future<List<ChatUser>> loadUsers() async {
    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in to find people to chat with.');
    }

    final snapshot = await _firestore.collection('Users').get();
    final users = snapshot.docs
        .map(ChatUser.fromDocument)
        .where((otherUser) => otherUser.id != user.uid)
        .toList();
    users.sort((first, second) => first.name.compareTo(second.name));
    return users;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messagesForChat(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<String> openChat(ChatUser otherUser) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in before starting a chat.');
    }

    final chats = await _firestore
        .collection('chats')
        .where('members', arrayContains: user.uid)
        .get();

    for (final chat in chats.docs) {
      final members = List<String>.from(chat.data()['members'] ?? []);
      if (members.length == 2 && members.contains(otherUser.id)) {
        return chat.id;
      }
    }

    final chat = _firestore.collection('chats').doc();
    await chat.set({
      'members': [user.uid, otherUser.id],
      'memberNames': {
        user.uid: user.email ?? 'User',
        otherUser.id: otherUser.name,
      },
      'lastMessage': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return chat.id;
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final user = currentUser;
    if (user == null) {
      throw StateError('Sign in before sending a message.');
    }

    final messageText = text.trim();
    if (messageText.isEmpty) return;

    final chat = _firestore.collection('chats').doc(chatId);
    final batch = _firestore.batch();
    final message = chat.collection('messages').doc();

    batch.set(message, {
      'senderId': user.uid,
      'senderName': user.email ?? 'User',
      'text': messageText,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(chat, {
      'lastMessage': messageText,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}

class ChatUser {
  const ChatUser({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory ChatUser.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final email = data['email']?.toString() ?? '';
    final savedName = data['name']?.toString().trim() ?? '';
    return ChatUser(
      id: data['uid']?.toString() ?? document.id,
      name: savedName.isEmpty ? email : savedName,
      email: email,
    );
  }
}

class ChatRoomArguments {
  const ChatRoomArguments({required this.chatId, required this.otherUserName});

  final String chatId;
  final String otherUserName;
}

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.otherUserName,
    required this.lastMessage,
    required this.updatedAt,
  });

  final String id;
  final String otherUserName;
  final String lastMessage;
  final DateTime? updatedAt;

  factory ChatConversation.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
    String currentUserId,
  ) {
    final data = document.data();
    final members = List<String>.from(data['members'] ?? []);
    final otherUserId = members.firstWhere(
      (memberId) => memberId != currentUserId,
      orElse: () => '',
    );
    final names = Map<String, dynamic>.from(data['memberNames'] ?? {});
    final timestamp = data['updatedAt'];

    return ChatConversation(
      id: document.id,
      otherUserName: names[otherUserId]?.toString() ?? 'Chat',
      lastMessage: data['lastMessage']?.toString() ?? '',
      updatedAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String senderId;
  final String text;
  final DateTime? createdAt;

  factory ChatMessage.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final timestamp = data['createdAt'];
    return ChatMessage(
      senderId: data['senderId']?.toString() ?? '',
      text: data['text']?.toString() ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}
