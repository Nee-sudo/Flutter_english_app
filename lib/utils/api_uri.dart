import 'constants.dart';

/// Resolves API paths for web (`/api/...`) and absolute production URLs.
Uri apiUri(String path) {
  final segment = path.startsWith('/') ? path.substring(1) : path;
  final base = AppAPI.baseUrl;
  if (base.startsWith('http://') || base.startsWith('https://')) {
    final root = base.endsWith('/') ? base : '$base/';
    return Uri.parse('$root$segment');
  }
  final root = base.startsWith('/') ? base : '/$base';
  final combined = root.endsWith('/') ? '$root$segment' : '$root/$segment';
  return Uri.base.resolve(combined);
}
