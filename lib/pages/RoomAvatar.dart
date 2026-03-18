import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:green_pill/service/matrix_service.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class RoomAvatar extends StatelessWidget {
  final Room room;
  final double radius;

  const RoomAvatar({
    super.key,
    required this.room,
    this.radius = 25,
  });

  Color _getColorForRoom(String roomId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[roomId.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final matrix = context.read<MatrixService>();

    return FutureBuilder<String?>(
      future: matrix.getRoomAvatarUrl(room, size: (radius * 2).toInt()),
      builder: (context, snapshot) {
        final avatarUrl = snapshot.data;

        if (avatarUrl != null) {
          // ✅ Avatar-Bild vorhanden
          return CircleAvatar(
            radius: radius,
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
            backgroundColor: Colors.grey,
          );
        }

        // ✅ Fallback: Initiale
        return CircleAvatar(
          radius: radius,
          backgroundColor: _getColorForRoom(room.id),
          child: Text(
            room.getLocalizedDisplayname()[0].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}