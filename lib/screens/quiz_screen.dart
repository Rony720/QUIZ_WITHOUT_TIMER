import 'package:flutter/material.dart';
import '../main.dart';
import '/data/questions_example.dart';
import '/screens/result_screen.dart';
import '/ui/shared/color.dart';
import '/widgets/quizz_widget.dart';
import '/model/question_model.dart';
import 'package:provider/provider.dart';

class QuizzScreen extends StatefulWidget {
  const QuizzScreen({Key? key}) : super(key: key);

  @override
  _QuizzScreenState createState() => _QuizzScreenState();
}

class _QuizzScreenState extends State<QuizzScreen> {
  int score = 0;
  bool btnPressed = false;
  PageController? _controller;
  String btnText = "Next Question";
  bool answered = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController(initialPage: 0);
    changer.addListener(_onChangerUpdated); //
  }
    void _onChangerUpdated() {
    setState(() {
      // The listener is called here whenever changer.currentSelectedOption changes
    });
  }

  @override
  Widget build(BuildContext context) {
     
    return Scaffold(
      backgroundColor: AppColor.pripmaryColor,
      body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: PageView.builder(
            controller: _controller!,
            onPageChanged: (page) {
              // changer.currentSelectedOption = 0;
              changer.notify();
              if (page == questions.length - 1) {
                setState(() {
                  btnText = "See Results";
                });
              }
              setState(() {
                answered = false;
              });
            },
            physics: new NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Question ${index + 1}/10",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 28.0,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50.0,
                    child: Text(
                      "${questions[index].question}",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                      ),
                    ),
                  ),
                  for (int i = 0; i < questions[index].answers!.length; i++)
                    Container(
                      width: double.infinity,
                      height: 50.0,
                      margin: EdgeInsets.only(
                          bottom: 20.0, left: 12.0, right: 12.0),
                      child: RawMaterialButton(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: changer.currentSelectedOption == i
                                ? Colors
                                    .green // Set border color to green if currentSelectedOption matches the button's index
                                : Color.fromARGB(
                                    255, 236, 217, 199), // Default border color
                            width: 5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        fillColor: btnPressed
                            ? questions[index].answers!.values.toList()[i]
                                ? Colors.green
                                : Colors.red
                            : AppColor.secondaryColor,
                        onPressed: !answered
                            ? () {
                                if (questions[index]
                                    .answers!
                                    .values
                                    .toList()[i]) {
                                  score++;
                                  print("yes");
                                } else {
                                  print("no");
                                }
                                setState(() {
                                  btnPressed = true;
                                  answered = true;
                                });
                              }
                            : null,
                        child: Text(
                          questions[index].answers!.keys.toList()[i],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 40.0,
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      if (_controller!.page?.toInt() == questions.length - 1) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResultScreen(score)));
                      } else {
                        _controller!.nextPage(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInExpo);

                        setState(() {
                          btnPressed = false;
                        });
                      }
                    },
                    shape: StadiumBorder(),
                    fillColor: Colors.blue,
                    padding: EdgeInsets.all(18.0),
                    elevation: 0.0,
                    child: Text(
                      btnText,
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              );
            },
            itemCount: questions.length,
          )),
    );
  }
}
