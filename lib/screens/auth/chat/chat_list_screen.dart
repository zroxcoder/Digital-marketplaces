import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/user_model.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatProvider.getUserChats(authProvider.user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start chatting with sellers!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          List<Map<String, dynamic>> chats = snapshot.data!;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> chat = chats[index];
              UserModel? otherUser = chat['otherUser'];
              
              if (otherUser == null) return const SizedBox.shrink();

              bool isUnread = chat['lastSenderId'] != authProvider.user!.uid;

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    otherUser.displayName[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  otherUser.displayName,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  chat['lastMessage'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: Text(
                  _formatTime(chat['lastMessageTime']),
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnread ? Theme.of(context).primaryColor : Colors.grey,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        otherUserId: otherUser.id,
                        otherUserName: otherUser.displayName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    
    DateTime time = DateTime.parse(timestamp);
    DateTime now = DateTime.now();
    
    if (time.day == now.day && time.month == now.month && time.year == now.year) {
      return DateFormat('HH:mm').format(time);
    } else if (time.year == now.year) {
      return DateFormat('MMM dd').format(time);
    } else {
      return DateFormat('MMM dd, yyyy').format(time);
    }
  }
}