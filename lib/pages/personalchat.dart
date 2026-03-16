import 'package:flutter/material.dart';

class PersonalChat extends StatefulWidget {
  const PersonalChat({super.key});

  @override
  State<PersonalChat> createState() => _PersonalChatState();
}

class _PersonalChatState extends State<PersonalChat> {
  List<MessageObject> messages = [
    MessageObject(text: 'Hey, how are you?', isMe: false),
    MessageObject(text: 'I am good, thanks! How about you?', isMe: true),
    MessageObject(
      text: 'Doing well, just working on a Flutter project.',
      isMe: false,
    ),
    MessageObject(text: 'That sounds great! Flutter is awesome.', isMe: true),
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageInputController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); 

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _scrollController.dispose();
    _messageInputController.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
                    backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/68.jpg'),
                    radius: 25,
                  ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Alice Smith'),
              ],
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              reverse: true,
              itemBuilder: (context, index) {
                return Align(
                  alignment: messages[index].isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: messages[index].isMe
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: messages[index].isMe
                            ? const Radius.circular(15)
                            : Radius.zero,
                        bottomRight: messages[index].isMe
                            ? Radius.zero
                            : const Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      messages[index].text,
                      style: TextStyle(
                        color: messages[index].isMe
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input field
          Container(
            height: 80,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.emoji_emotions_outlined),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageInputController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 15,
                      ),
                      fillColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onSubmitted: (value) {
                      sendMessage(value);
                      _focusNode.requestFocus(); 
                    },
                  ),
                ),
                IconButton(onPressed: () {sendMessage(_messageInputController.text);}, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(text) {
    text = text.trim();
    
    if (text.isEmpty) return;

    setState(() {
      messages.insert(0, MessageObject(text: text, isMe: true));
    });
    _messageInputController.clear();
    _focusNode.requestFocus();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class MessageObject {
  final String text;
  final bool isMe;

  MessageObject({required this.text, required this.isMe});
}
