import 'package:flutter/material.dart';
import 'package:matrix/encryption/utils/key_verification.dart';

class VerificationDialog extends StatefulWidget {
  final KeyVerification request;
  const VerificationDialog({required this.request, super.key});

  @override
  State<VerificationDialog> createState() => _VerificationDialogState();
}

class _VerificationDialogState extends State<VerificationDialog> {
  
  @override
  void initState() {
    super.initState();

    widget.request.onUpdate = () {
      if (mounted) {
        setState(() {});
      }
    };
  }

  Widget _wrapInDialog(Widget content) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = switch (widget.request.state) {
      KeyVerificationState.askAccept => _buildAcceptView(),
      KeyVerificationState.askSas    => _buildEmojiView(),
      KeyVerificationState.waitingSas => _buildWaitingView(),
      KeyVerificationState.done      => _buildDoneView(),
      KeyVerificationState.error     => _buildErrorView(),
      _ => _buildLoadingView(),
    };

    return _wrapInDialog(content);
  }

  // Schritt A: Anfrage annehmen
  Widget _buildAcceptView() => Column(
    children: [
      Text('Verifizierungsanfrage von ${widget.request.userId}'),
      ElevatedButton(
        onPressed: () => widget.request.acceptVerification(),
        child: const Text('Akzeptieren'),
      ),
      TextButton(
        onPressed: () => widget.request.rejectVerification(),
        child: const Text('Ablehnen'),
      ),
    ],
  );

  // Schritt B: Emojis anzeigen + Nutzer bestätigen lassen
  Widget _buildEmojiView() {
    final emojis = widget.request.sasEmojis;
    
    return Column(
      children: [
        const Text('Stimmen diese Emojis überein?'),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: emojis.map((e) => _EmojiTile(emoji: e)).toList(),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => widget.request.acceptSas(),
              child: const Text('✓ Stimmt überein'),
            ),
            TextButton(
              onPressed: () => widget.request.rejectSas(),
              child: const Text('✗ Stimmt nicht'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoneView() => Column(
    children: [
      ListTile(
        leading: Icon(Icons.verified, color: Colors.green),
        title: Text('Verifizierung erfolgreich!'),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Okay'),
          ),
        ],
      ),
    ],
  );

  

  Widget _buildErrorView() {
    
    var code = widget.request.canceledCode;

    if (code == 'm.user') {
      // Nutzer hat selbst abgebrochen → kein "Fehler" anzeigen
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: const Icon(Icons.error, color: Colors.red),
      title: Text('Fehler'),
      subtitle: Text('${widget.request.canceledReason}'),
    );
  }

  Widget _buildWaitingView() => Column(
    children: [
      const Text('Warten auf User-Bestätigung...'),
      Center(
        child: CircularProgressIndicator(),
      ),
      Row(
        children: [
          ElevatedButton(
            onPressed: () {
              widget.request.cancel("m.user");
              Navigator.of(context).pop();
            },
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    ],
  );

  Widget _buildLoadingView() => Column(
    children: [
      const Text('Warte auf Verifizierungsanfrage...'),
      const SizedBox(height: 12),
      CircularProgressIndicator(),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: () {
          widget.request.cancel("m.user");
          Navigator.of(context).pop();
        },
        child: const Text('Abbrechen'),
      ),
    ],
  );
}

// Hilfs-Widget für einzelnes Emoji
class _EmojiTile extends StatelessWidget {
  final KeyVerificationEmoji emoji;
  const _EmojiTile({required this.emoji});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        Text(emoji.emoji, style: const TextStyle(fontSize: 32)),
        Text(emoji.name,  style: const TextStyle(fontSize: 11)),
      ],
    ),
  );
}