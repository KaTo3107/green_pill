import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:green_pill/pages/RoomAvatar.dart';
import 'package:green_pill/pages/personalchat.dart';
import 'package:green_pill/service/matrix_service.dart';
import 'package:provider/provider.dart';

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
    final matrix = context.watch<MatrixService>();
    if (!matrix.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final rooms = matrix.rooms;//.where((room) => room.isDirectChat).toList();

    // Empty State
    if (rooms.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Keine Räume vorhanden')),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          
          var imageUrl = matrix.getRoomAvatarUrl(room);

          return Material(
            child: ListTile(
              leading: RoomAvatar(room: room),
              title: Text(room.getLocalizedDisplayname()),
              subtitle: Text(room.lastEvent?.text ?? 'Keine Nachrichten'),
              tileColor: Colors.cyan,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalChat())
                );
              },
              trailing: room.notificationCount > 0
                ? CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${room.notificationCount}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  )
                : null,
            ),
          );
        },
      ),
    );
  }
}