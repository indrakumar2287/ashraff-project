import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ChatLocalDatabase {
  ChatLocalDatabase._();

  static final instance = ChatLocalDatabase._();

  final StreamController<void> _messagesChanged =
      StreamController<void>.broadcast();
  Future<Database>? _databaseOpening;

  Future<Database> get _database => _databaseOpening ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final path = join(await getDatabasesPath(), 'chat_messages.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            owner_uid TEXT NOT NULL,
            chat_id TEXT NOT NULL,
            remote_message_id TEXT NOT NULL,
            sender_id TEXT NOT NULL DEFAULT '',
            sender_name TEXT NOT NULL DEFAULT '',
            message TEXT NOT NULL DEFAULT '',
            message_type TEXT NOT NULL DEFAULT 'text',
            image TEXT,
            created_at_ms INTEGER,
            UNIQUE(owner_uid, chat_id, remote_message_id)
          )
        ''');
        await db.execute('''
          CREATE INDEX messages_by_chat
          ON messages(owner_uid, chat_id, created_at_ms)
        ''');
      },
    );
  }

  Future<void> saveMessages({
    required String ownerUid,
    required String chatId,
    required List<Map<String, Object?>> messages,
  }) async {
    if (messages.isEmpty) return;

    final db = await _database;
    final batch = db.batch();
    for (final message in messages) {
      batch.insert('messages', {
        ...message,
        'owner_uid': ownerUid,
        'chat_id': chatId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    _messagesChanged.add(null);
  }

  Future<List<Map<String, Object?>>> getMessages({
    required String ownerUid,
    required String chatId,
  }) async {
    final db = await _database;
    return db.query(
      'messages',
      where: 'owner_uid = ? AND chat_id = ?',
      whereArgs: [ownerUid, chatId],
      orderBy: 'created_at_ms ASC, id ASC',
    );
  }

  Stream<List<Map<String, Object?>>> watchMessages({
    required String ownerUid,
    required String chatId,
  }) {
    late final StreamController<List<Map<String, Object?>>> output;
    StreamSubscription<void>? changeSubscription;

    Future<void> refresh() async {
      try {
        final messages = await getMessages(ownerUid: ownerUid, chatId: chatId);
        if (!output.isClosed) output.add(messages);
      } catch (error, stackTrace) {
        if (!output.isClosed) output.addError(error, stackTrace);
      }
    }

    output = StreamController<List<Map<String, Object?>>>(
      onListen: () {
        changeSubscription = _messagesChanged.stream.listen((_) {
          unawaited(refresh());
        });
        unawaited(refresh());
      },
      onCancel: () async {
        await changeSubscription?.cancel();
      },
    );

    return output.stream;
  }
}
