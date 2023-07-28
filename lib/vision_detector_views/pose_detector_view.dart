import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../main.dart';
import 'camera_view.dart';
import 'painters/pose_painter.dart';

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  int i = 1;
  double standing = 0;
  int squatno = 0;
  int frame = 0;
  bool squat = false;
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose() async {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      title: 'Pose Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: (inputImage) {
        processImage(inputImage);
      },
    );
  }

  Future<void> processImage(InputImage inputImage) async {
    i++;
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final poses = await _poseDetector.processImage(inputImage);

    // getting individual value

    for (Pose pose in poses) {
      // to access specific landmarks  [ we need hip,knee,ankle]
      final rightHipPoint = pose.landmarks[PoseLandmarkType.rightHip];
      final rightKneePoint = pose.landmarks[PoseLandmarkType.rightKnee];
      final rightAnklePoint = pose.landmarks[PoseLandmarkType.rightAnkle];

      final leftHipPoint = pose.landmarks[PoseLandmarkType.leftHip];
      final leftKneePoint = pose.landmarks[PoseLandmarkType.leftKnee];
      final leftAnklePoint = pose.landmarks[PoseLandmarkType.leftAnkle];

      if (rightHipPoint != null &&
          rightKneePoint != null &&
          rightAnklePoint != null &&
          leftHipPoint != null &&
          leftKneePoint != null &&
          leftAnklePoint != null) {
        // slope of hip and knee
        double slopeA = (rightHipPoint.y - rightKneePoint.y) /
            (rightHipPoint.x - rightKneePoint.x);

        double slopeB = (rightAnklePoint.y - rightKneePoint.y) /
            (rightAnklePoint.x - rightKneePoint.x);

        double angle = atan((slopeB - slopeA) / (1 + slopeA * slopeB));

        // convert angle to radian

        double degree = angle * 180 / pi;

        standing = changer.poseStanding = 0;
        changer.positionCapture = true;
        changer.notify();

        // check squat

        if (changer.positionCapture && !squat) {
          // print("CURRENT ANGLE: ${degree.abs()}");
          if ((degree.abs() - changer.poseStanding.abs() > 40)) {
            squat = true;
            squatno++;
            changer.currentSelectedOption =
                (changer.currentSelectedOption + 1) % 4;
            changer.notify();

            // print(
            //     "CURRENT SELECTED OPTION IS ${changer.currentSelectedOption}");
            // print(
            //     "CURRENT SELECTED OPTION IS ${changer.currentSelectedOption}");
            // print(
            //     "CURRENT SELECTED OPTION IS ${changer.currentSelectedOption}");
            // print(
            //     "CURRENT SELECTED OPTION IS ${changer.currentSelectedOption}");

            // print("SQUAT");
          }
        }

        // check for standing

        if (changer.positionCapture && squat) {
          // print("CURRENT ANGLE: ${degree.abs()}");
          if ((degree.abs() - changer.poseStanding.abs() < 20)) {
            squat = false;
            // print("STAND");
          }
        }

        // FOR LEFT LEG
        double slopeA2 = (leftHipPoint.y - leftKneePoint.y) /
            (leftHipPoint.x - leftKneePoint.x);

        double slopeB2 = (leftAnklePoint.y - leftKneePoint.y) /
            (leftAnklePoint.x - leftKneePoint.x);

        double angle2 = atan((slopeB2 - slopeA2) / (1 + slopeA2 * slopeB2));

        // convert angle to radian

        double degree2 = angle2 * 180 / pi;

        print("DEGREE 1 is $degree");
        print("DEGREE 2 is $degree2");
        print("DIFF is ${(degree2.abs() - degree.abs()).abs()}");
      }
    }

    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      final painter = PosePainter(poses, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = 'Poses found: ${poses.length}\n\n';
      // TODO: set _customPaint to draw landmarks on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
