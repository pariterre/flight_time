import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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

    while (!Athletes._instance!.isReady) {
      // wait for the database to be ready
      await Future.delayed(const Duration(milliseconds: 100));
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

  Future<String> databasePath() async {
    // get the application documents directory
    final dir = await getApplicationDocumentsDirectory();
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }

    return join(dir.path, 'athletes.db');
  }

  ///
  /// Get an athlete from their name, throws if the athlete does not exist
  Athlete athleteFromName(String name) =>
      _athletes.firstWhere((athlete) => athlete.name == name);

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
  /// Add a video to an athlete, throws if the athlete does not exist or the video already exists
  Future<void> addVideo(String name, {required String videoPath}) async {
    if (!isReady) throw StateError('Database is not ready');

    // Get the athlete and check if the video already exists
    Athlete athlete = athleteFromName(name);
    if (athlete.videoPaths.contains(videoPath)) {
      throw StateError('Video already exists');
    }

    // Add the video to the athlete and update the database
    await _store.record(athlete.name).put(_database!, athlete.toJson());
    athlete._videoPaths.add(videoPath);
  }

  ///
  /// Remove a video from an athlete, throws if the athlete does not exist or the video does not exist
  Future<void> removeVideo(String name, {required String videoPath}) async {
    if (!isReady) throw StateError('Database is not ready');

    // Get the athlete and check if the video exists
    Athlete athlete = athleteFromName(name);
    if (!athlete.videoPaths.contains(videoPath)) {
      throw StateError('Video does not exist');
    }

    // Remove the video from the athlete and update the database
    await _store.record(athlete.name).put(_database!, athlete.toJson());
    athlete._videoPaths.remove(videoPath);
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
  /// Get the list of athletes names
  List<String> get athleteNames =>
      _athletes.map((athlete) => athlete.name).toList();

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

class AthletesMock extends Athletes {
  static AthletesMock get instance => Athletes._instance! as AthletesMock;
  AthletesMock._() : super._();

  ///
  /// Initialize the database
  static Future<void> initialize() async {
    if (Athletes._instance?.isReady ?? false) return;

    Athletes._instance = AthletesMock._();
    Athletes._instance!._initializeDataBase();

    while (!Athletes._instance!.isReady) {
      // wait for the database to be ready
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Future<String> databasePath() async {
    return join('./', 'mock_athletes_database.db');
  }
}

class Athlete {
  final String name;
  final List<String> _videoPaths = [];
  List<String> get videoPaths => List.unmodifiable(_videoPaths);

  Athlete({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
        'video_paths': videoPaths,
      };

  factory Athlete.fromJson(Map<String, dynamic> json) =>
      Athlete(name: json['name'])
        .._videoPaths.addAll((json['video_paths'] as List).cast<String>());
}
