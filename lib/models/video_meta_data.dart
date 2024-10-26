import 'dart:convert';
import 'dart:io';

class VideoMetaData {
  final String athleteName;
  final String trialName;
  final Directory baseFolder;

  final Duration duration;
  final DateTime creationDate;
  final DateTime lastModified;

  final int frameJumpStarts;
  final int frameJumpEnds;

  VideoMetaData({
    required this.athleteName,
    required this.trialName,
    required this.baseFolder,
    required this.duration,
    required this.creationDate,
    required this.lastModified,
    required this.frameJumpStarts,
    required this.frameJumpEnds,
  });

  VideoMetaData copyWith({
    String? athleteName,
    String? trialName,
    Directory? baseFolder,
    Duration? duration,
    DateTime? creationDate,
    DateTime? lastModified,
    int? frameJumpStarts,
    int? frameJumpEnds,
  }) {
    return VideoMetaData(
      athleteName: athleteName ?? this.athleteName,
      trialName: trialName ?? this.trialName,
      baseFolder: baseFolder ?? this.baseFolder,
      duration: duration ?? this.duration,
      creationDate: creationDate ?? this.creationDate,
      lastModified: lastModified ?? this.lastModified,
      frameJumpStarts: frameJumpStarts ?? this.frameJumpStarts,
      frameJumpEnds: frameJumpEnds ?? this.frameJumpEnds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'athleteName': athleteName,
      'trialName': trialName,
      'baseFolder': baseFolder.path,
      'duration': duration.inMilliseconds,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'lastModified': lastModified.millisecondsSinceEpoch,
      'frameJumpStarts': frameJumpStarts,
      'frameJumpEnds': frameJumpEnds,
    };
  }

  factory VideoMetaData.fromFile(String file) {
    final json = File(file).readAsStringSync();
    return VideoMetaData.fromJson(jsonDecode(json));
  }

  factory VideoMetaData.fromJson(Map<String, dynamic> json) {
    return VideoMetaData(
      athleteName: json['athleteName'],
      trialName: json['trialName'],
      baseFolder: Directory(json['baseFolder']),
      duration: Duration(milliseconds: json['duration']),
      creationDate: DateTime.fromMillisecondsSinceEpoch(json['creationDate']),
      lastModified: DateTime.fromMillisecondsSinceEpoch(json['lastModified']),
      frameJumpStarts: json['frameJumpStarts'],
      frameJumpEnds: json['frameJumpEnds'],
    );
  }

  String get videoPath => '${baseFolder.path}/$trialName.mp4';
  String get path => '${baseFolder.path}/$trialName.meta';
}
