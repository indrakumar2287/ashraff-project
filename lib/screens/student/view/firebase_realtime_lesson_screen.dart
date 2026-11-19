import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseRealtimeLessonScreen extends StatefulWidget {
  const FirebaseRealtimeLessonScreen({super.key});

  @override
  State<FirebaseRealtimeLessonScreen> createState() =>
      _FirebaseRealtimeLessonScreenState();
}

class _FirebaseRealtimeLessonScreenState
    extends State<FirebaseRealtimeLessonScreen> {
  final TextEditingController _textController = TextEditingController();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('student_lesson_messages');

  bool _isSending = false;

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await _messagesCollection.add({
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _textController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _deleteMessage(String docId) async {
    try {
      await _messagesCollection.doc(docId).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting message: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Firestore Lesson'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Teaching Concept Card
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.indigo.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '📚 Lesson: Firestore Collections & Real-Time Streams',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '1. Type text below and tap Send to store it in a Firestore Collection.\n'
                  '2. StreamBuilder listens to .snapshots() for instant real-time UI updates.\n'
                  '3. Open this screen on another device or window to see changes sync live!',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),

          // Input Box Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Enter message for your student...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendMessage,
                  icon: const Icon(Icons.send),
                  label: const Text('Send'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Real-Time List Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Live Firestore Collection (`student_lesson_messages`)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Icon(Icons.bolt, color: Colors.amber, size: 20),
              ],
            ),
          ),

          // Real-Time StreamBuilder List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading data: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No messages yet. Type above to add one!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>?;
                    final messageText = data?['text'] ?? '';
                    final timestamp = data?['createdAt'] as Timestamp?;
                    final timeString = timestamp != null
                        ? timestamp.toDate().toLocal().toString().substring(11, 19)
                        : 'Just now';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          messageText,
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          'Added at: $timeString',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteMessage(doc.id),
                          tooltip: 'Delete document',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
