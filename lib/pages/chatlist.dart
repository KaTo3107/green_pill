import 'package:flutter/material.dart';
import 'package:green_pill/pages/personalchat.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Hero(
              tag: 'ListTile-Hero',
              child: Material(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage('https://randomuser.me/api/portraits/women/68.jpg'),
                    radius: 25,
                  ),
                  title: const Text('Alice Smith'),
                  subtitle: const Text('Hey, how are you?'),
                  tileColor: Colors.cyan,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalChat())
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}