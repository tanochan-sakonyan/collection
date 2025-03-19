import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';

class DeleteEventDialog extends ConsumerStatefulWidget {
  final String userId;
  final String eventId;
  const DeleteEventDialog(
      {required this.userId, required this.eventId, super.key});

  get eventRepository => null;

  @override
  ConsumerState<DeleteEventDialog> createState() => _DeleteEventDialogState();
}

class _DeleteEventDialogState extends ConsumerState<DeleteEventDialog> {
  bool _isButtonEnabled = true;
  Future<void> _deleteEvent(ref, String userId, String eventId) async {
    if (!_isButtonEnabled) return;
    setState(() {
      _isButtonEnabled = false;
    });
    try {
      await ref.read(userProvider.notifier).deleteEvent(userId, eventId);
      Navigator.of(ref).pop();
    } catch (error) {
      debugPrint('イベントの削除に失敗しました: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 320,
        height: 179,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'このイベントを削除しますか？', //TODO 実際にイベント名を取得
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(flex: 2),
                SizedBox(
                  height: 36,
                  width: 107,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD7D7D7),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'いいえ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 36,
                  width: 107,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () => _deleteEvent(ref, widget.userId, widget.eventId)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F2),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'はい',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
