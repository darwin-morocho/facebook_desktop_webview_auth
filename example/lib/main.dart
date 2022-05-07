// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import 'package:facebook_desktop_webview_auth/desktop_webview_auth.dart';
import 'package:facebook_desktop_webview_auth/facebook.dart';

void main() {
  runApp(const MyApp());
}

typedef SignInCallback = Future<void> Function();

const FACEBOOK_CLIENT_ID = '1329834907365798';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  SignInCallback signInWithArgs(BuildContext context, ProviderArgs args) =>
      () async {
        final result = await DesktopWebviewAuth.signIn(args);
        notify(context, result?.toString());
      };

  void notify(BuildContext context, String? result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Result: $result'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
          ),
        ),
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) {
            final buttons = [
              ElevatedButton(
                child: const Text('Sign in with Facebook'),
                onPressed: signInWithArgs(
                  context,
                  FacebookSignInArgs(
                    clientId: FACEBOOK_CLIENT_ID,
                    scope: 'email,public_profile',
                    version: 'v13.0',
                  ),
                ),
              ),
            ];

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: ListView.separated(
                  itemCount: buttons.length,
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    return buttons[index];
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
