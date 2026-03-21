import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
import 'package:matrix/encryption/utils/bootstrap.dart';
import 'package:matrix/encryption/utils/key_verification.dart';
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

    final dbPath = p.join(dir.path, 'matrix.db');
    final database = await MatrixSdkDatabase.init(
      'Green Pill',
      database: await sqflite.openDatabase(dbPath),
    );

    client = Client(
      "Green Pill",
      database: database,
      nativeImplementations: NativeImplementationsIsolate(
        compute,
        vodozemacInit: () => vod.init(),
      )
    );

    debugPrint('[Matrix] 🔍 Encryption vor init: ${client.encryption}');
    debugPrint('[Matrix] 🔍 Encryption enabled vor init: ${client.encryptionEnabled}');

    await client.init(
      waitForFirstSync: false,
      waitUntilLoadCompletedLoaded: false,
    );

    debugPrint('[Matrix] 🔍 Encryption nach init: ${client.encryption}');
    debugPrint('[Matrix] 🔍 Encryption enabled nach init: ${client.encryptionEnabled}');


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

    await _setupEncryption();
    
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

  Map<String, dynamic> getEncryptionInfo(Room room) {
    return {
      'encrypted': room.encrypted,
      'algorithm': room.encryptionAlgorithm,
      'participantCount': room.getParticipants().length,
      'encryptionEnabled': client.encryptionEnabled,
    };
  }

  Future<void> enableRoomEncryption(Room room) async {
    if (!room.encrypted) {
      try {
        await room.enableEncryption();
        debugPrint('[Matrix] ✅ Encryption aktiviert für: ${room.getLocalizedDisplayname()}');
        notifyListeners();
      } catch (e) {
        debugPrint('[Matrix] ❌ Fehler beim Aktivieren von Encryption: $e');
        rethrow;
      }
    }
  }

  Future<void> _setupEncryption() async {
    if (!client.encryptionEnabled) {
      debugPrint('[Matrix] Encryption ist nicht aktiviert!');
      return;
    }

    try {
      // Warte bis Encryption bereit ist
      await client.encryption?.keyManager.isCached();
    } catch (e) {
      debugPrint('[Matrix] Encryption Setup Fehler: $e');
    }
  }

  Future<void> bootstrapE2EE(Client client, String passphrase) async {
    Bootstrap(
      encryption: client.encryption!,
      onUpdate: (Bootstrap b) async {
        switch (b.state) {
          case BootstrapState.askWipeSsss:
            b.wipeSsss(true);
            break;
          case BootstrapState.askUseExistingSsss:
            b.useExistingSsss(false);
            break;
          case BootstrapState.askNewSsss:
            await b.newSsss(passphrase);
            break;
          case BootstrapState.askWipeCrossSigning:
            await b.wipeCrossSigning(true);
            break;
          case BootstrapState.askSetupCrossSigning:
            await b.askSetupCrossSigning(
              setupMasterKey: true,
              setupSelfSigningKey: true,
              setupUserSigningKey: true,
            );
            break;
          case BootstrapState.askWipeOnlineKeyBackup:
            b.wipeOnlineKeyBackup(true);
            break;
          case BootstrapState.askSetupOnlineKeyBackup:
            await b.askSetupOnlineKeyBackup(true);
            break;
          case BootstrapState.done:
            print('Bootstrap fertig!');
            break;
          case BootstrapState.error:
            print('Bootstrap Fehler');
            break;
          default:
            break;
        }
      },
    );
  }
}