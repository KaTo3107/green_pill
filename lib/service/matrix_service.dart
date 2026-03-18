import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class MatrixService extends ChangeNotifier {


  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => isInitialized && client.isLogged();

  late Client client;

  List<Room> get rooms => client.rooms;
  Room? getRoomById(String id) => client.getRoomById(id);

  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    client = Client(
      "Green Pill",
       databaseBuilder: (clientName) async {
        final dbPath = p.join(dir.path, '$clientName.db');
        final db = MatrixSdkDatabase(
          clientName.clientName,
          database: await sqflite.openDatabase(dbPath),
        );
        await db.open();
        return db;
      },
    );

    await client.init(
      waitForFirstSync: false,
      waitUntilLoadCompletedLoaded: false,
    );

    client.onSync.stream.listen((_) => notifyListeners());

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login({
    required String homeserver,
    required String username,
    required String password,
  }) async {
    homeserver = homeserver.trim();
    username = username.trim();
    password = password;

    // Homeserver setzen
    await client.checkHomeserver(Uri.parse(homeserver));

    // Einloggen
    await client.login(
      LoginType.mLoginPassword,
      identifier: AuthenticationUserIdentifier(user: username),
      password: password,
    );
    
    notifyListeners();
  }
  
  Future<void> logout() async {
    await client.logout();
    
    notifyListeners();
  }

  Future<String?> getRoomAvatarUrl(Room room, {int size = 50}) async {
    if (room.avatar == null) return null;
    final url = await room.avatar!
        .getThumbnailUri(client,
            width: size, height: size, method: ThumbnailMethod.crop);
            
    return url.toString();
  }

  @override
  void dispose() {
    client.dispose();
    super.dispose();
  }
}