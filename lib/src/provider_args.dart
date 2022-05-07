import 'package:flutter/foundation.dart';

import 'jsonable.dart';

abstract class ProviderArgs implements Jsonable {
  String get redirectUri;
  String get host;
  String get path;

  Map<String, String> buildQueryParameters();

  Future<String> buildSignInUri() {
    final uri = Uri(
      scheme: 'https',
      host: host,
      path: path,
      queryParameters: buildQueryParameters(),
    );

    return SynchronousFuture(uri.toString());
  }

  bool usesFragment = true;

  Future<Map<String, String>?> authorizeFromCallback(String callbackUrl) {
    final uri = Uri.parse(callbackUrl);
    late Map<String, String> args;

    if (usesFragment) {
      args = Uri.splitQueryString(uri.fragment);
    } else {
      args = uri.queryParameters;
    }

    if (args.containsKey('access_token')) {
      return SynchronousFuture(args);
    }

    throw Exception('No access token found');
  }

  @override
  Future<Map<String, String>> toJson() async {
    final signInUri = await buildSignInUri();

    return {
      'signInUri': signInUri,
      'redirectUri': redirectUri,
    };
  }
}
