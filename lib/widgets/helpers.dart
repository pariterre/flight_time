import 'package:flutter/material.dart';

Size computeSize(context,
    {required Size videoSize, required double videoAspectRatio}) {
  final width = videoSize.width;
  final height = videoSize.height;

  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final widthSizeFactor = width / screenWidth;
  final heightSizeFactor = height / screenHeight;

  final sizeFactor =
      widthSizeFactor > heightSizeFactor ? widthSizeFactor : heightSizeFactor;

  return Size(videoSize.width / sizeFactor,
      videoSize.height * videoAspectRatio / sizeFactor);
}

Duration fligthTime(
        {required Duration timeJumpStarts, required Duration timeJumpEnds}) =>
    timeJumpEnds - timeJumpStarts;

double flightHeight({required Duration fligthTime}) =>
    9.81 *
    (fligthTime.inMilliseconds / 1000) *
    (fligthTime.inMilliseconds / 1000) /
    8.0;
