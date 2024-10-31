import 'dart:convert';
import 'dart:io';

import 'package:flight_time/models/athletes.dart';

class VideoMetaData {
  final Athlete athlete;
  final String trialName;
  final Directory baseFolder;

  final Duration duration;
  final DateTime creationDate;
  final DateTime lastModified;

  final Duration timeJumpStarts;
  final Duration timeJumpEnds;

  VideoMetaData({
    required this.athlete,
    required this.trialName,
    required this.baseFolder,
    required this.duration,
    required this.creationDate,
    required this.lastModified,
    required this.timeJumpStarts,
    required this.timeJumpEnds,
  });

  VideoMetaData copyWith({
    DateTime? lastModified,
    Duration? timeJumpStarts,
    Duration? timeJumpEnds,
  }) {
    return VideoMetaData(
      athlete: athlete,
      trialName: trialName,
      baseFolder: baseFolder,
      duration: duration,
      creationDate: creationDate,
      lastModified: lastModified ?? this.lastModified,
      timeJumpStarts: timeJumpStarts ?? this.timeJumpStarts,
      timeJumpEnds: timeJumpEnds ?? this.timeJumpEnds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'athleteName': athlete.name,
      'trialName': trialName,
      'baseFolder': baseFolder.path,
      'duration': duration.inMilliseconds,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'lastModified': lastModified.millisecondsSinceEpoch,
      'timeJumpStarts': timeJumpStarts.inMilliseconds,
      'timeJumpEnds': timeJumpEnds.inMilliseconds,
    };
  }

  factory VideoMetaData.fromMetaDataFile(String file) {
    final json = File(file).readAsStringSync();
    return VideoMetaData.fromJson(jsonDecode(json));
  }

  factory VideoMetaData.fromJson(Map<String, dynamic> json) {
    return VideoMetaData(
      athlete: Athletes.instance.athleteFromName(json['athleteName']),
      trialName: json['trialName'],
      baseFolder: Directory(json['baseFolder']),
      duration: Duration(milliseconds: json['duration']),
      creationDate: DateTime.fromMillisecondsSinceEpoch(json['creationDate']),
      lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified']),
      timeJumpStarts: Duration(milliseconds: json['timeJumpStarts']),
      timeJumpEnds: Duration(milliseconds: json['timeJumpEnds']),
    );
  }

  String get videoPath => '${baseFolder.path}/$trialName.mp4';
  String get path => '${baseFolder.path}/$trialName.meta';

  ///
  /// Write the metadata on the disk. This method do not update the database.
  Future<void> writeToDisk() async {
    // Create the target structure
    if (!(await baseFolder.exists())) {
      await baseFolder.create(recursive: true);
    }

    // Delete the file if it exists, otherwise the write silently fails
    if (await File(path).exists()) {
      await File(path).delete();
    }

    await File(path).writeAsString(
        JsonEncoder.withIndent('  ').convert(toJson()),
        flush: true);
  }

  ///
  /// Delete the metadata file from the disk. This method do not update the database.
  Future<void> deleteFile() async {
    if (await File(path).exists()) {
      await File(path).delete();
    }
  }

  Duration get fligthTime => timeJumpEnds - timeJumpStarts;
  double get flightHeight =>
      9.81 *
      (fligthTime.inMilliseconds / 1000) *
      (fligthTime.inMilliseconds / 1000) /
      8.0;
}
