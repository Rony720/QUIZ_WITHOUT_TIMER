import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '/screens/main_menu.dart';

List<CameraDescription> cameras = [];
final Changer changer = Changer();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

class Changer extends ChangeNotifier {
  double poseStanding = 0;
  int currentSelectedOption = 0;
  bool positionCapture = true;

  bool confirmAnswer = false;

  void notify() {
    notifyListeners();
  }
}
