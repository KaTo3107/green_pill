import 'package:flutter/material.dart';
import 'package:green_pill/pages/RoomAvatar.dart';
import 'package:green_pill/service/matrix_service.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class PersonalChat extends StatefulWidget {
  const PersonalChat({super.key, required this.room});

  final Room room;
  @override
  State<PersonalChat> createState() => _PersonalChatState();
}

class _PersonalChatState extends State<PersonalChat> {
  List<MessageObject> messages = [
  ];

  Timeline? timeline;
  bool _isDisposed = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageInputController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); 

  @override
  void initState() {
    super.initState();

    _loadTimeline();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  Future<void> _loadTimeline() async {
    final matrix = context.watch<MatrixService>();

    await matrix.client.roomsLoading;
    await matrix.client.accountDataLoading;

    timeline = await widget.room.getTimeline(
      onUpdate: () {
        // 🔧 NEU: Nur setState wenn Widget noch mounted ist
        if (!_isDisposed && mounted) {
          setState(() {});
        }
      },
    );

    // Initial setState nur wenn noch mounted
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageInputController.dispose();
    _focusNode.dispose();
    super.dispose();
    _isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    final matrixService = Provider.of<MatrixService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            RoomAvatar(room: widget.room, radius: 20),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.room.getLocalizedDisplayname(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          // 🔐 NEU: Encryption Toggle Button
          if (!widget.room.encrypted)
            IconButton(
              icon: const Icon(Icons.lock_outline),
              tooltip: 'Verschlüsselung aktivieren',
              onPressed: () async {
                await _enableEncryption(matrixService);
              },
            ),
          // 🔐 NEU: Info Button
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showEncryptionInfo(context),
          ),
        ],
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: timeline?.events.length ?? 0,
              reverse: true,
              itemBuilder: (context, index) {
                if(timeline == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final event = timeline!.events[index];
                final isMe = event.senderId == matrixService.client.userID;

                String messageText = event.body;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isMe
                            ? const Radius.circular(15)
                            : Radius.zero,
                        bottomRight: isMe
                            ? Radius.zero
                            : const Radius.circular(15),
                      ),
                    ),
                    child: Text(
                      messageText,
                      style: TextStyle(
                        color: isMe
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
                      hintText: 'Nachricht eingeben...',
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

  // 🔐 NEU: Encryption aktivieren
  Future<void> _enableEncryption(MatrixService matrixService) async {
    try {
      await matrixService.enableRoomEncryption(widget.room);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Verschlüsselung aktiviert!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Fehler: $e')),
        );
      }
    }
  }

  // 🔐 NEU: Encryption Info Dialog
  void _showEncryptionInfo(BuildContext context) {
    final info = context.read<MatrixService>().getEncryptionInfo(widget.room);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('Verschlüsselung'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Status:', info['encrypted'] ? '🔒 Verschlüsselt' : '🔓 Nicht verschlüsselt'),
            if (info['encrypted'])
              _buildInfoRow('Algorithmus:', info['algorithm'] ?? 'N/A'),
            _buildInfoRow('Teilnehmer:', '${info['participantCount']}'),
            _buildInfoRow('Client Encryption:', info['encryptionEnabled'] ? 'Aktiv' : 'Inaktiv'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
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
