import 'dart:io';

import 'package:flight_time/models/file_manager.dart';
import 'package:flight_time/models/video_meta_data.dart';
import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';

class Athletes {
  Database? _database;
  bool _isReady = false;
  bool get isReady => _isReady;
  final _store = StoreRef.main();
  final List<Athlete> _athletes = [];

  // Prepare the singleton
  static Athletes? _instance;
  static Athletes get instance => _instance!;
  Athletes._();

  ///
  /// Wait for the database to be ready
  static Future<void> initialize() async {
    if (Athletes._instance?.isReady ?? false) return;

    Athletes._instance = Athletes._();
    Athletes._instance!._initializeDataBase();

    await _deleteCacheFolder();

    while (!Athletes._instance!.isReady) {
      // wait for the database to be ready
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  ///
  /// Return an immutable list of athletes
  List<Athlete> get athletes => List.unmodifiable(_athletes);

  ///
  /// Delete the cache folder where the videos are stored
  static Future<void> _deleteCacheFolder() async {
    final cacheDir = Directory(await FileManager.cacheFolder);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  Future<void> _initializeDataBase() async {
    // open the database
    _database = await databaseFactoryIo.openDatabase(await databasePath());

    // load the athletes
    final athletes = await _store.find(_database!);
    _athletes.addAll(athletes.map(
        (record) => Athlete.fromJson(record.value as Map<String, dynamic>)));

    _isReady = true;
  }

  Future<String> databasePath() async =>
      join(await FileManager.dataFolder, 'athletes.db');

  ///
  /// Get an athlete from their name, throws if the athlete does not exist
  Athlete athleteFromName(String name) =>
      _athletes.firstWhere((athlete) => athlete.name == name);

  ///
  /// Get an athlete from their name, adds it if it does not exist
  Athlete athleteFromNameOrAdd(String name) {
    try {
      return athleteFromName(name);
    } on StateError {
      addAthlete(name);
      return athleteFromName(name);
    }
  }

  ///
  /// Add a new athlete from their name, if the athlete already exists, throw an error
  /// Return the newly created athlete
  Future<void> addAthlete(String name) async {
    if (!isReady) throw StateError('Database is not ready');
    if (_athletes.any((athlete) => athlete.name == name)) {
      throw StateError('Athlete already exists');
    }

    final athlete = Athlete(name: name);
    await _store.record(athlete.name).put(_database!, athlete.toJson());
    _athletes.add(athlete);
  }

  ///
  /// Add a video to an athlete, if the video already exists in the database,
  /// only the metadata file is updated
  Future<void> addVideo(VideoMetaData metaData) async {
    if (!isReady) throw StateError('Database is not ready');

    final athlete = metaData.athlete;

    // Update the metadata file
    await metaData.writeToDisk();

    // If the video already exists, we are done
    if (athlete.videoMetaDataPaths.contains(metaData.path)) return;

    // Add the video to the athlete
    athlete._videoMetaDataPaths.add(metaData.path);

    // Update the database
    await _store.record(athlete.name).put(_database!, athlete.toJson());
  }

  ///
  /// Remove a video from an athlete, throws if the video does not exist
  Future<void> removeVideo(VideoMetaData metaData) async {
    if (!isReady) throw StateError('Database is not ready');

    final athlete = metaData.athlete;

    // If the video does not exist, then it is not possible to remove it
    if (!athlete.videoMetaDataPaths.contains(metaData.path)) {
      throw StateError('Video does not exist');
    }

    // Delete the metadata
    await metaData.deleteFile();

    // Remove the video from the athlete
    athlete._videoMetaDataPaths.remove(metaData.path);

    // Update the database
    await _store.record(athlete.name).put(_database!, athlete.toJson());

    // Remove file from disk
    File(metaData.videoPath).delete();
  }

  ///
  /// Remove an athlete, throws if the athlete does not exist
  Future<void> removeAthlete(String name) async {
    if (!isReady) throw StateError('Database is not ready');

    // Get the athlete and remove it from the database
    Athlete athlete = athleteFromName(name);
    await _store.record(athlete.name).delete(_database!);
    _athletes.remove(athlete);
  }

  ///
  /// Get the athletes names
  Iterable<String> get athleteNames => _athletes.map((athlete) => athlete.name);

  ///
  /// Reset the database
  /// This will remove all the athletes and their videos. This is irreversible!
  Future<void> reset() async {
    if (!isReady) throw StateError('Database is not ready');

    // Remove all the athletes
    for (var athlete in _athletes) {
      await _store.record(athlete.name).delete(_database!);
    }
    _athletes.clear();
  }
}

class Athlete {
  final String name;
  final List<String> _videoMetaDataPaths = [];
  List<String> get videoMetaDataPaths => List.unmodifiable(_videoMetaDataPaths);

  Athlete({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
        'meta_data_paths': videoMetaDataPaths,
      };

  factory Athlete.fromJson(
          Map<String, dynamic> json) =>
      Athlete(name: json['name'])
        .._videoMetaDataPaths
            .addAll((json['meta_data_paths'] as List).cast<String>());
}
