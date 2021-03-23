import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int interval_time = 25;
  double progress = 1;
  int intervals = 6;
  int long_break_after = 4;
  int short_break_time = 5;
  int long_break_time = 15;
  int minutes = 00;
  int seconds = 00;
  int current_interval = 0;
  bool start = false;
  bool isBreak = false;
  int min = 0;

  void initState() {
    super.initState();
    minutes = interval_time;
    seconds = 00;
  }

  playLocalAsset() {
// Vibrate with pauses between each vibration
    final Iterable<Duration> pauses = [
      const Duration(milliseconds: 500),
      const Duration(milliseconds: 1000),
      const Duration(milliseconds: 500),
      const Duration(milliseconds: 1000),
      const Duration(milliseconds: 500),
    ];
// vibrate - sleep 0.5s - vibrate - sleep 1s - vibrate - sleep 0.5s - vibrate
    Vibrate.vibrateWithPauses(pauses);
  }

  void reset() {
    setState(() {
      minutes = interval_time;
      seconds = 0;
      progress = 1.0;
    });
  }

  void resetAll() {
    setState(() {
      current_interval = 0;
    });
  }

  void startBreak(int mins) {
    setState(() {
      isBreak = true;
    });
    minutes = mins;
    seconds = 0;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (isBreak) {
        if (seconds != 0) {
          setState(() {
            seconds = seconds - 1;
          });
        } else {
          if (minutes == 0) {
            reset();
            setState(() {
              isBreak = false;
            });
            playLocalAsset();
          } else {
            setState(() {
              seconds = 59;
              minutes = minutes - 1;
            });
          }
        }
        setState(() {
          print(progress);

          progress = ((minutes + seconds / 60) / min);
          if (progress >= 1.0) {
            progress = 1.0;
          }
          if (progress <= 0) {
            progress = 0.0;
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void startTimer() {
    setState(() {
      start = true;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (start == true) {
        if (seconds != 0) {
          setState(() {
            seconds = seconds - 1;
          });
        } else {
          if (minutes == 0) {
            reset();

            if (current_interval + 1 == intervals) {
              resetAll();
              setState(() {
                start = false;
              });
              print("Play");
              playLocalAsset();
            } else {
              current_interval = current_interval + 1;

              setState(() {
                start = false;
                isBreak = true;

                min = ((current_interval) % long_break_after == 0 &&
                        current_interval != 0)
                    ? long_break_time
                    : short_break_time;
                minutes = min;
              });
              playLocalAsset();
            }
          } else {
            setState(() {
              seconds = 59;
              minutes = minutes - 1;
            });
          }
        }
        if (!isBreak) {
          setState(() {
            progress = (minutes + seconds / 60) / interval_time;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Image.asset(
                  "images/logo.png",
                  height: 60,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  'Pomo Timer',
                  style: TextStyle(
                    fontFamily: "Ranchers",
                    fontSize: 35,
                    color: Color(0xffEE4446),
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: CircularPercentIndicator(
              radius: 310.0,
              lineWidth: 50.0,
              percent: progress,
              circularStrokeCap: CircularStrokeCap.round,
              center: Text(
                minutes.toString().padLeft(2, '0') +
                    ":" +
                    seconds.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontFamily: "Raleways",
                  fontSize: 55,
                  color: (isBreak) ? Colors.green : Color(0xffEE4446),
                ),
              ),
              progressColor: (isBreak) ? Colors.green : Color(0xffEE4446),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    if (!isBreak) {
                      if (start) {
                        setState(() {
                          start = false;
                        });
                      } else {
                        startTimer();
                      }
                    } else {
                      startBreak(min);
                    }
                  },
                  child: Icon(
                    (start ? Icons.pause : Icons.play_arrow),
                    color: (isBreak) ? Colors.blueGrey : Color(0xffEE4446),
                    size: 30.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    if (!isBreak) {
                      setState(() {
                        start = false;
                        reset();
                      });
                    }
                  },
                  child: Icon(
                    Icons.undo,
                    color: (isBreak) ? Colors.blueGrey : Color(0xffEE4446),
                    size: 30.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    if (!isBreak) {
                      reset();
                      setState(() {
                        start = false;
                        if (current_interval + 1 >= intervals) {
                          resetAll();
                        } else {
                          current_interval = current_interval + 1;
                        }
                      });
                    }
                  },
                  child: Icon(
                    Icons.redo,
                    color: (isBreak) ? Colors.blueGrey : Color(0xffEE4446),
                    size: 30.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    SystemSound.play(SystemSoundType.click);
                    if (!isBreak) {
                      reset();
                      setState(() {
                        start = false;
                        resetAll();
                      });
                    }
                  },
                  child: Icon(
                    Icons.restore,
                    color: (isBreak) ? Colors.blueGrey : Color(0xffEE4446),
                    size: 30.0,
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.all(10.0),
              //   child: GestureDetector(
              //     onTap: () {
              //       SystemSound.play(SystemSoundType.click);
              //     },
              //     child: Icon(
              //       Icons.settings,
              //       color: (isBreak) ? Colors.blueGrey : Color(0xffEE4446),
              //       size: 30.0,
              //     ),
              //   ),
              // ),
            ],
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              children: [
                Text(
                  "$current_interval / $intervals",
                  style: TextStyle(
                    fontFamily: "Raleways",
                    fontSize: 50,
                    color: (isBreak) ? Colors.green : Color(0xffEE4446),
                  ),
                ),
                Text(
                  "Lapse Completed",
                  style: TextStyle(
                    fontFamily: "Raleway",
                    fontSize: 25,
                    color: (isBreak) ? Colors.green : Color(0xffEE4446),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
