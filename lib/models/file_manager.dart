import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  static bool useMockerPath = false;

  static Future<String> get baseFolder async => useMockerPath
      ? 'mockFolder'
      : (await getApplicationDocumentsDirectory()).path;

  static Future<String> get cacheFolder async =>
      '${(await getApplicationCacheDirectory()).path}/camerawesome';

  static Future<String> get dataFolder async {
    final folder = '${await baseFolder}/data';
    final dir = Directory(folder);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return folder;
  }
}
