import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mr_collection/constants/base_url.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/data/repository/event_repository.dart';

class AddEventDialog extends ConsumerStatefulWidget {
  final String userId;

  const AddEventDialog({required this.userId, super.key});

  @override
  AddEventDialogState createState() => AddEventDialogState();
}

class AddEventDialogState extends ConsumerState<AddEventDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _isButtonEnabled = true;
  bool isToggleOn = true;

  final EventRepository eventRepository = EventRepository(baseUrl: baseUrl);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text.trim();
      if (text.length > 8) {
        setState(() {
          _errorMessage = '最大8文字まで入力可能です';
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _createEvent() async {
    final eventName = _controller.text.trim();
    // final isCopy = isToggleOn;
    final userId = ref.read(userProvider)!.userId;

    if (!_isButtonEnabled) return;
    setState(() {
      _isButtonEnabled = false;
    });

    if (eventName.isEmpty) {
      _errorMessage = "イベント名を入力してください";
    }
    else if(eventName.length > 8){
      _errorMessage = "イベント名は最大8文字までです";
    }
    else{
      _errorMessage = null;
    }

    if(eventName.isEmpty || eventName.length > 8){
      setState(() {
        _isButtonEnabled = true;
      });
      return;
    }

    try {
      debugPrint('イベント名: $eventName, ユーザーID: $userId');
      await ref.read(userProvider.notifier).createEvent(eventName, userId);
      Navigator.of(context).pop();
    } catch (error) {
      debugPrint('イベントの追加に失敗しました: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF2F2F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
        child: Container(
          width: 328,
          height: 270,
          color: const Color(0xFFF2F2F2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset("assets/icons/close_circle.svg"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    'イベントの追加',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                      icon: SvgPicture.asset("assets/icons/check_circle.svg"),
                      onPressed: _isButtonEnabled
                          ? () => _createEvent()
                          : null),
                ],
              ),
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
                    hintText: 'イベント名を入力',
                  ),
                ),
              ),
              if (_errorMessage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child:
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                        fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  )
              else const SizedBox(height: 24),
              // Options Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                child: Column(
                  children: [
                    //TODO: 現状まだ実装できていないが、今後実装予定
                    /*ListTile(
                      title: const Text('参加者引継ぎ'),
                      trailing: ToggleButton(
                        initialValue: isToggleOn,
                        onChanged: (bool isOn) {
                          setState(() {
                            isToggleOn = isOn;
                          });
                        },
                      ),
                    ),*/
                    const Divider(height: 1, color: Color(0xFFE8E8E8)),
                    ListTile(
                      title: const Text('LINEから参加者取得'),
                      trailing: IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/line.svg',
                          width: 28,
                          height: 28,
                        ),
                        onPressed: () {
                          //LINE認証申請前の臨時ダイアログ
                          showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 56.0, horizontal: 24.0),
                              content: Text(
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 29)
            ],
          ),
        ),
      ),
    );
  }
}
