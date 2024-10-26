// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flight_time/models/athletes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_linux/path_provider_linux.dart';

Future<Athletes> getDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isLinux) {
    throw UnsupportedError('This test is for Linux only');
  }
  PathProviderLinux.registerWith();

  await AthletesMock.initialize();
  await Athletes.instance.reset();
  return Athletes.instance;
}

void main() {
  test('One must initialize the database before using it', () async {
    // Throws a type error
    expect(() => Athletes.instance, throwsA(isA<TypeError>()));
  });

  test('Connect to the athlete database', () async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!Platform.isLinux) {
      throw UnsupportedError('This test is for Linux only');
    }
    PathProviderLinux.registerWith();
    await AthletesMock.initialize();
    expect(AthletesMock.instance.isReady, true);
  });

  test('Reset the database', () async {
    final athletes = await getDatabase();

    // Add an athlete to the database
    await athletes.addAthlete('John Doe');
    expect(athletes.athleteNames.length, 1);

    // Add videos to the athlete
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video2.mp4');
    final athlete = athletes.athleteFromName('John Doe');
    expect(athlete.videoPaths.length, 2);

    // Reset the database
    await athletes.reset();
    expect(athletes.athleteNames.length, 0);

    // Adding back the athlete should not have any videos
    await athletes.addAthlete('John Doe');
    final athlete2 = athletes.athleteFromName('John Doe');
    expect(athlete2.videoPaths.length, 0);
  });

  test('Add an athlete to the database', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    expect(athletes.athleteNames.length, 1);
    expect(athletes.athleteNames.contains('John Doe'), true);
  });

  test('Get an athlete from the database', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    final athlete = athletes.athleteFromName('John Doe');
    expect(athlete.name, 'John Doe');
    expect(athlete.videoPaths.length, 0);
  });

  test('Get a non-existing athlete from the database', () async {
    final athletes = await getDatabase();
    expect(() => athletes.athleteFromName('John Doe'), throwsStateError);
  });

  test('Add a video to an athlete', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4');

    final athlete = athletes.athleteFromName('John Doe');
    expect(athlete.videoPaths.length, 1);
    expect(athlete.videoPaths[0], 'my_folder/my_video.mp4');
  });

  test('Add more than one video', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video2.mp4');

    final athlete = athletes.athleteFromName('John Doe');
    expect(athlete.videoPaths.length, 2);
    expect(athlete.videoPaths[1], 'my_folder/my_video2.mp4');
  });

  test('Add a video that already exists', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4');
    expect(
        () =>
            athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4'),
        throwsStateError);
  });

  test('Add a video to a non-existing athlete', () async {
    final athletes = await getDatabase();
    expect(
        () =>
            athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4'),
        throwsStateError);
  });

  test('Try to modify the video path without using Athletes interface',
      () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4');

    final athlete = athletes.athleteFromName('John Doe');
    expect(
      () => athlete.videoPaths[0] = 'my_folder/my_video3.mp4',
      throwsUnsupportedError,
    );
  });

  test('Remove a video from an athlete', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video2.mp4');

    await athletes.removeVideo('John Doe', videoPath: 'my_folder/my_video.mp4');

    final athlete = athletes.athleteFromName('John Doe');
    expect(athlete.videoPaths.length, 1);
    expect(athlete.videoPaths[0], 'my_folder/my_video2.mp4');
  });

  test('Remove a non-existing video from an athlete', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    expect(
        () => athletes.removeVideo('John Doe',
            videoPath: 'my_folder/my_video.mp4'),
        throwsStateError);
  });

  test('Remove a video from a non-existing athlete', () async {
    final athletes = await getDatabase();
    expect(
        () => athletes.removeVideo('John Doe',
            videoPath: 'my_folder/my_video.mp4'),
        throwsStateError);
  });

  test('Remove an athlete from the database', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    await athletes.removeAthlete('John Doe');
    expect(() => athletes.athleteFromName('John Doe'), throwsStateError);
  });

  test('Re-add an athlete to the database', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    await athletes.addVideo('John Doe', videoPath: 'my_folder/my_video.mp4');
    await athletes.removeAthlete('John Doe');

    expect(() => athletes.athleteFromName('John Doe'), throwsStateError);
  });

  test('Remove a non-existing athlete from the database', () async {
    final athletes = await getDatabase();
    expect(() => athletes.removeAthlete('Jane Doe'), throwsStateError);
  });

  test('Get the names of the athletes', () async {
    final athletes = await getDatabase();
    await athletes.addAthlete('John Doe');
    await athletes.addAthlete('Jane Doe');

    final names = athletes.athleteNames;
    expect(names.length, 2);
    expect(names.contains('John Doe'), true);
    expect(names.contains('Jane Doe'), true);
  });
}