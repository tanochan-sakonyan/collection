import 'package:flutter/material.dart';

class ConfirmationPopup extends StatelessWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const ConfirmationPopup({
    super.key,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFFF2F2F2),
      child: Container(
        width: 296,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    "未払いの人にPayPayリンクを",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "送信しますか？",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              color: Colors.black,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onYes,
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: const Text(
                        "はい",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.black, // 中央の境界線
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onNo,
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: const Text(
                        "いいえ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showConfirmationPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmationPopup(
        onYes: () {
          Navigator.of(context).pop();
          // 「はい」を選択した際の処理
        },
        onNo: () {
          Navigator.of(context).pop();
          // 「いいえ」を選択した際の処理
        },
      );
    },
  );
}
