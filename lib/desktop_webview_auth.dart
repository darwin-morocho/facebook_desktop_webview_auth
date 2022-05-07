import 'dart:async';

import 'package:facebook_desktop_webview_auth/src/jsonable.dart';
import 'package:facebook_desktop_webview_auth/src/platform_response.dart';
import 'package:flutter/services.dart';

import 'src/provider_args.dart';

export 'src/provider_args.dart';

const _channelName = 'io.invertase.flutter/desktop_webview_auth';

class DesktopWebviewAuth {
  static final _channel = const MethodChannel(_channelName)
    ..setMethodCallHandler(_onMethodCall);

  static late ProviderArgs _args;
  static late Completer<Map<String, String>?> _signInResultCompleter;

  static _invokeMethod<T>({
    required String name,
    required Jsonable args,
    num? width,
    num? height,
  }) async {
    final _args = await args.toJson();

    return _channel.invokeMethod<T>(name, {
      if (width != null) 'width': width.toInt(),
      if (height != null) 'height': height.toInt(),
      ..._args,
    });
  }

  static Future<void> _invokeSignIn(
    ProviderArgs args, [
    int? width,
    int? height,
  ]) async {
    return await _invokeMethod<void>(
      name: 'signIn',
      args: args,
      width: width,
      height: height,
    );
  }

  static Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCallbackUrlReceived':
        final args = call.arguments.cast<String, dynamic>();
        final res = PlatformResponse.fromJson(args);

        if (res.flow == 'signIn') {
          await _onSignInCallbackUrlReceived(res.url);
        }
        break;

      case 'onDismissed':
        final args = call.arguments.cast<String, dynamic>();
        final res = PlatformResponse.fromJson(args);

        if (res.flow == 'signIn') {
          _onDismissed(_signInResultCompleter);
        }
        break;

      default:
        throw UnimplementedError('${call.method} is not implemented');
    }
  }

  static void _onDismissed(Completer completer) {
    if (completer.isCompleted) return;
    completer.complete();
  }

  static Future<void> _onSignInCallbackUrlReceived(String? callbackUrl) async {
    if (callbackUrl == null) {
      _signInResultCompleter.complete(null);
    } else {
      try {
        final authResult = _args.authorizeFromCallback(callbackUrl);
        _signInResultCompleter.complete(authResult);
      } catch (e) {
        _signInResultCompleter.complete(null);
      }
    }
  }

  static Future<Map<String, String>?> signIn(
    ProviderArgs args, {
    int? width,
    int? height,
  }) async {
    _args = args;
    _signInResultCompleter = Completer<Map<String, String>?>();

    try {
      await _invokeSignIn(args, width, height);
      return _signInResultCompleter.future;
    } catch (_) {
      return null;
    }
  }
}
