import 'package:facebook_desktop_webview_auth/src/util.dart';

import 'src/provider_args.dart';

const _responseType = 'token,granted_scopes';

class FacebookSignInArgs extends ProviderArgs {
  final String clientId;
  final String scope;

  @override
  final String redirectUri =
      'https://www.facebook.com/connect/login_success.html';

  @override
  final host = 'www.facebook.com';

  @override
  String get path => '/$version/dialog/oauth';

  final String version;

  FacebookSignInArgs({
    required this.clientId,
    required this.scope,
    required this.version,
  });

  String state = '';

  @override
  Map<String, String> buildQueryParameters() {
    state = generateNonce();

    return {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'state': state,
      'response_type': _responseType,
      'scope': scope,
    };
  }
}
