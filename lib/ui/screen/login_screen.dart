import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mr_collection/provider/access_token_provider.dart';
import 'package:mr_collection/provider/user_provider.dart';
import 'package:mr_collection/ui/screen/home_screen.dart';
import 'package:mr_collection/ui/screen/privacy_policy_screen.dart';
import 'package:mr_collection/ui/screen/terms_of_service_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;

final checkboxProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    bool isChecked = ref.watch(checkboxProvider);
    debugPrint('isChecked: $isChecked');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Text("集金くん",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 100),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked
                      ? const Color(0xFF06C755)
                      : const Color(0xFFD7D7D7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  if (isChecked) {
                    final prefs = await SharedPreferences.getInstance();
                    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
                    debugPrint('isLoggedIn: $isLoggedIn');
                    final userId = prefs.getString('userId');

                    if (isLoggedIn && userId != null) {
                      try {
                        await ref
                            .read(userProvider.notifier)
                            .fetchUserById(userId);

                        final user = ref.read(userProvider);
                        if (mounted && user != null) {
                          debugPrint('既存ユーザーでHomeScreenに遷移します。user: $user');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen(title: '集金くん', user: user),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('ユーザー情報の取得に失敗しました。: $e');
                      }
                    } else {
                      try {
                        final result = await LineSDK.instance.login();
                        final accessToken = result.accessToken.value;
                        ref.read(accessTokenProvider.notifier).state =
                            accessToken;

                        final user = await ref
                            .read(userProvider.notifier)
                            .registerUser(accessToken);

                        if (user != null) {
                          prefs.setString('userId', user.userId);
                          prefs.setBool('isLoggedIn', true);
                        } else {
                          debugPrint('ユーザー情報がnullです');
                        }

                        if (mounted && user != null) {
                          debugPrint(
                              'LoginScreenからHomeScreenに遷移します。user: $user');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen(title: '集金くん', user: user),
                            ),
                          );
                        }
                      } on PlatformException catch (e) {
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('ログイン失敗'),
                              content: Text(
                                  'エラーコード: ${e.code}\nメッセージ: ${e.message}'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // const SizedBox(width: 12),
                    SvgPicture.asset(
                      'assets/icons/line-login.svg',
                    ),
                    const SizedBox(width: 40),
                    const Text(
                      'LINEでログイン',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isChecked
                      ? const Color(0xFF000000)
                      : const Color(0xFFD7D7D7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onPressed: () async {
                  try {
                    // Appleサインインの認証情報を取得
                    final credential =
                        await SignInWithApple.getAppleIDCredential(
                      scopes: [
                        AppleIDAuthorizationScopes.email,
                        AppleIDAuthorizationScopes.fullName,
                      ],
                      webAuthenticationOptions: WebAuthenticationOptions(
                        clientId: 'com.tanotyan.syukinkun.service',
                        redirectUri: kIsWeb
                            ? Uri.parse('https://${Uri.base.host}/')
                            : Uri.parse(
                                'https://shukinkun-49fb12fd2191.herokuapp.com/auth/apple/callback',
                              ),
                      ),
                    );

                    debugPrint("Appleサインイン認証情報: $credential");

                    final url = Uri.https(
                        'shukinkun-49fb12fd2191.herokuapp.com', '/auth/apple');

                    final response = await http.get(
                      url,
                      headers: {'Content-Type': 'application/json'},
                    );

                    if (response.statusCode == 200 ||
                        response.statusCode == 201) {
                      final user = await ref
                          .read(userProvider.notifier)
                          .registerUser(response.body);

                      if (user != null) {
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString('userId', user.userId);
                        prefs.setBool('isLoggedIn', true);

                        if (mounted) {
                          debugPrint(
                              'Appleサインイン成功。HomeScreenへ遷移します。user: $user');
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomeScreen(title: '集金くん', user: user),
                            ),
                          );
                        }
                      } else {
                        debugPrint('ユーザー情報がnullです');
                      }
                    } else {
                      debugPrint(
                          'Appleサインインエンドポイントエラー: ${response.statusCode}');
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('サインイン失敗'),
                            content: Text(
                                'Appleサインインに失敗しました。エラーコード: ${response.statusCode}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  } on PlatformException catch (e) {
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('サインイン失敗'),
                          content:
                              Text('エラーコード: ${e.code}\nメッセージ: ${e.message}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('Appleサインイン中にエラーが発生: $e');
                    if (mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('サインイン失敗'),
                          content: Text('エラーが発生しました: $e'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/apple_logo.svg',
                      height: 24,
                    ),
                    const SizedBox(width: 40),
                    const Text(
                      'Appleでサインイン',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    ref.read(checkboxProvider.notifier).state = value!;
                  },
                  activeColor: Colors.black,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen()),
                    );
                  },
                  child: const Text(
                    '利用規約',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
                const Text(' と '),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen()),
                    );
                  },
                  child: const Text(
                    'プライバシーポリシー',
                    style: TextStyle(color: Colors.blue, fontSize: 14),
                  ),
                ),
                const Text(' に同意します。'),
              ],
            ),
            const SizedBox(height: 100)
          ],
        ),
      ),
    );
  }
}
