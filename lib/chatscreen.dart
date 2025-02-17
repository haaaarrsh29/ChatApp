import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: ChatScreen()));
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  /// Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Add pagination logic if needed
    }
  }

  /// Send message to Firestore
  void _sendMessage() {
    final user = FirebaseAuth.instance.currentUser;
    if (_controller.text.isNotEmpty && user != null) {
      FirebaseFirestore.instance.collection('chat_messages').add({
        'text': _controller.text,
        'email': user.email, // Store sender email
        'createdAt': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  /// Real-time message stream
  Stream<QuerySnapshot> _chatStream = FirebaseFirestore.instance
      .collection('chat_messages')
      .orderBy('createdAt', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AARam'),
        backgroundColor: Colors.blue, // Customize app bar color
        elevation: 4, // Add elevation for a shadow effect
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              stream: _chatStream,
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final chatDocs = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: chatDocs.length,
                  itemBuilder: (ctx, index) {
                    final chat = chatDocs[index];
                    final messageText = chat['text'];
                    final senderEmail = chat['email'] ?? 'Unknown';
                    final isMe = FirebaseAuth.instance.currentUser?.email == senderEmail;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderEmail,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue[300] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              margin: EdgeInsets.only(top: 4),
                              child: Text(
                                messageText,
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Send a message...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
