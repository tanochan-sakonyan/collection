import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/provider/user_provider.dart';

class AddMemberDialog extends ConsumerStatefulWidget {
  final String userId;
  final String eventId;

  const AddMemberDialog(
      {required this.userId, required this.eventId, super.key});

  @override
  AddMemberDialogState createState() => AddMemberDialogState();
}

class AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  Future<void> _createMember() async {
    setState(() {
      if (_controller.text.trim().isEmpty) {
        _errorMessage = 'メンバーを入力してください';
      } else {
        _errorMessage = null;
      }
    });

    try {
      await ref
          .read(userProvider.notifier)
          .createMember(widget.userId, widget.eventId, _controller.text.trim());
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'メンバーの追加に失敗しました';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          color: const Color(0xFFF2F2F2),
          height: 144,
          width: 380,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'メンバーを入力',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/line.svg"),
                    color: const Color(0xFF06C755),
                    onPressed: () {
                      //LINE認証申請前の臨時ダイアログ
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 56.0, horizontal: 24.0),
                          content: const Text(
                            'LINEへの認証申請中のため、\n機能解禁までしばらくお待ちください',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                      //TODO LINE認証申請が通ったらこちらに戻す
                      /*showDialog(
                        context: context,
                        builder: (context) => const ConfirmationDialog(),
                      );*/
                    },
                  ),
                  SizedBox(
                    width: 118,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _createMember,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5AFF9C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0),
                      child: Text(
                        'メンバー追加',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ],
              ),
              if (_errorMessage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
