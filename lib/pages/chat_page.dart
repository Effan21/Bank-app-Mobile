import 'dart:async';
import 'dart:convert';
import 'package:bank_app/const.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../theme/colors.dart';

class ChatScreen extends StatefulWidget {
  final int clientId;
  final String clientName;

  const ChatScreen({required this.clientId, required this.clientName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  late int conversationId;
  TextEditingController messageController = TextEditingController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    checkConversation();
    startPolling();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  void startPolling() {
    const duration = Duration(seconds: 5);
    timer = Timer.periodic(duration, (_) {
      checkMessages();
    });
  }

  void stopPolling() {
    timer?.cancel();
  }



  Future<void> checkConversation() async {
    try {
      var response = await http.get(
        Uri.parse(
            'http://$ip_server:8000/bank/conversations/?user=${widget.clientId}'),
      );

      if (response.statusCode == 200) {
        conversationId = jsonDecode(response.body)[0]['id'];
        await getMessages();
      } else if (response.statusCode == 404) {
        var createConversationResponse = await http.post(
          Uri.parse('http://192.168.1.66:8000/bank/conversations/'),
          body: {
            'admin': 1,
            'user': widget.clientId.toString(),
          },
        );

        if (createConversationResponse.statusCode == 201) {
          conversationId =
          jsonDecode(createConversationResponse.body)['id'];
          await getMessages();
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> getMessages() async {
    try {
      var messagesResponse = await http.get(
        Uri.parse(
            'http://$ip_server:8000/bank/conversations/$conversationId/messages/'),
      );

      if (messagesResponse.statusCode == 200) {
        var messagesData = jsonDecode(messagesResponse.body);
        setState(() {
          messages = messagesData
              .map<Message>((data) => Message(
            content: data['content'],
            timestamp: DateTime.parse(data['timestamp']),
            type: MessageType.values[data['type']],
            sentStatus: MessageSentStatus.Sent,
          ))
              .toList();
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }



  Future<void> sendMessage(String messageText) async {
    if (messageText.isNotEmpty) {
      setState(() {
        Message newMessage = Message(
          content: messageText,
          timestamp: DateTime.now(),
          type: MessageType.Client,
          sentStatus: MessageSentStatus.Sending,
        );

        messages.add(newMessage);
        messageController.clear();
      });

      try {
        var response = await http.post(
          Uri.parse(
              'http://$ip_server:8000/bank/conversations/$conversationId/messages/'), // Replace with your actual API URL
          body: json.encode({
            'conversation': conversationId, // Replace with your actual conversation ID
            'content': messageText.toString(),
            'type': 0, // Assuming '0' represents 'Client' messages
          }),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 201) {
          setState(() {
            messages.last.sentStatus = MessageSentStatus.Sent;
          });
        } else {
          setState(() {
            messages.last.sentStatus = MessageSentStatus.Failed;
          });
        }
      } catch (e) {
        setState(() {
          messages.last.sentStatus = MessageSentStatus.Failed;
        });
      }
    } else {
      print('Message is empty');
    }
  }

  void checkMessages() {
    getMessages();
  }

  Widget _buildMessage(Message message) {
    bool isCurrentUser = message.type == MessageType.Client;
    String formattedTimestamp = DateFormat('MMM d, HH:mm').format(message.timestamp);

    return ChatBubble(
      text: message.content,
      timestamp: formattedTimestamp,
      isCurrentUser: isCurrentUser,
      sentStatus: message.sentStatus,
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: messageController,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {},
              decoration: const InputDecoration.collapsed(
                hintText: 'Envoyer un message ...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              sendMessage(messageController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              _buildHeader(context),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 15.0),
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final message = messages[index];
                      return _buildMessage(message);
                    },
                  ),
                ),
              ),
              _buildMessageComposer(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    required this.text,
    required this.timestamp,
    required this.isCurrentUser,
    required this.sentStatus,
  });

  final String text;
  final String timestamp; // Add a timestamp property
  final bool isCurrentUser;
  final MessageSentStatus sentStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? 64.0 : 16.0,
        4,
        isCurrentUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(
                        color: isCurrentUser ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1.0),
                    Text(
                      timestamp,
                      style: Theme
                          .of(context)
                          .textTheme
                          .caption!
                          .copyWith(
                        color: isCurrentUser ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8.0),
                if (sentStatus == MessageSentStatus.Sending)
                  SizedBox(
                    width: 18.0,
                    height: 18.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCurrentUser ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                if (sentStatus == MessageSentStatus.Sent)
                  Icon(
                    Icons.check,
                    size: 18.0,
                    color: isCurrentUser ? Colors.white : Colors.black87,
                  ),
                if (sentStatus == MessageSentStatus.Failed)
                  Icon(
                    Icons.error,
                    size: 18.0,
                    color: Colors.red,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class Message {
  final String content;
  final DateTime timestamp;
  final MessageType type;
  MessageSentStatus sentStatus;

  Message({
    required this.content,
    required this.timestamp,
    required this.type,
    this.sentStatus = MessageSentStatus.Sending,
  });
}

enum MessageType {
  Client,
  Server,
}

enum MessageSentStatus {
  Sending,
  Sent,
  Failed,
}

Widget _buildHeader(BuildContext context) {
  return Container(
    height: 100,
    decoration: BoxDecoration(
      color: AppColor.appBgColor,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColor.shadowColor.withOpacity(0.1),
          blurRadius: .5,
          spreadRadius: .5,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        SizedBox(
          width: 80,
        ),
        Expanded(
          child: Text(
            "Assistance par message",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
        ),
      ],
    ),
  );

}
