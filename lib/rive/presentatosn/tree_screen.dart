// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:rive/rive.dart';
// import '../../times.dart'; // Assuming this contains intToTimeLeft
//
// class PlantScreen extends StatefulWidget {
//   const PlantScreen({super.key});
//
//   @override
//   _PlantScreenState createState() => _PlantScreenState();
// }
//
// class _PlantScreenState extends State<PlantScreen> {
//   Artboard? _riveArtboard;
//   StateMachineController? _controller;
//   SMIInput<double>? _progress;
//   String plantButtonText = "Start Growing";
//
//   int _treeProgress = 0;
//   final int _treeMaxProgress = 100;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadRiveFile();
//   }
//
//   Future<void> _loadRiveFile() async {
//     try {
//       final data = await rootBundle.load('assets/rive/pomodoro_tree.riv');
//       final file = RiveFile.import(data);
//       final artboard = file.mainArtboard;
//
//       _controller =
//           StateMachineController.fromArtboard(artboard, 'State Machine 1');
//       if (_controller != null) {
//         artboard.addController(_controller!);
//
//         for (var input in _controller!.inputs) {
//           print("Found input: ${input.name} (${input.runtimeType})");
//         }
//
//         _progress = _controller!.findInput<double>('input'); // Correct name
//         if (_progress != null) {
//           _progress!.value = _treeProgress.toDouble();
//           print('Initial Progress value: ${_progress!.value}');
//         }
//       }
//
//       setState(() => _riveArtboard = artboard);
//     } catch (e) {
//       print('❌ Error loading Tree Rive file: $e');
//     }
//   }
//
//   void _startOrResetGrowing() {
//     // যদি গাছ already fully grown → reset
//     if (_treeProgress >= _treeMaxProgress) {
//       _timer?.cancel();
//       setState(() {
//         _treeProgress = 0;
//         _progress?.value = 0.0;
//         plantButtonText = "Start Growing";
//       });
//       return;
//     }
//
//     // Start growing
//     plantButtonText = "Growing...";
//     _timer?.cancel();
//
//     const totalDuration = 30; // seconds
//     const interval = 0.3; // seconds
//     final increments = _treeMaxProgress / (totalDuration / interval);
//
//     _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
//       setState(() {
//         _treeProgress += increments.toInt();
//         if (_treeProgress >= _treeMaxProgress) {
//           _treeProgress = _treeMaxProgress;
//           _progress?.value = _treeProgress.toDouble();
//           plantButtonText = "Plant Fully Grown";
//           timer.cancel();
//         } else {
//           _progress?.value = _treeProgress.toDouble();
//         }
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double treeWidth = MediaQuery.of(context).size.width - 40;
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(top: 60),
//             child: Text(
//               "Stay Focused",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Center(
//               child: _riveArtboard == null
//                   ? const SizedBox()
//                   : Container(
//                 width: treeWidth,
//                 height: treeWidth,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(treeWidth / 2),
//                   border: Border.all(color: Colors.white12, width: 10),
//                 ),
//                 child: Rive(
//                   alignment: Alignment.center,
//                   artboard: _riveArtboard!,
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 10),
//             child: Text(
//               intToTimeLeft(_treeMaxProgress - _treeProgress),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 30,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(bottom: 30),
//             child: Text(
//               "Time left to grow the plant",
//               style: TextStyle(
//                 color: Colors.white60,
//                 fontSize: 10,
//                 fontWeight: FontWeight.normal,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 100),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(180, 40),
//                 backgroundColor: Colors.green,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 elevation: 8,
//               ),
//               onPressed: _startOrResetGrowing,
//               child: Text(
//                 plantButtonText,
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }









import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rive/rive.dart';
import 'package:confetti/confetti.dart';

class PlantScreen extends StatefulWidget {
  const PlantScreen({super.key});

  @override
  _PlantScreenState createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen> {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _progress;
  String plantButtonText = "Start Growing";

  int _treeProgress = 0; // Current progress (0–100%)
  final int _treeMaxProgress = 100; // Maximum growth (100%)
  Timer? _timer;

  // Timer options in seconds (3, 10, 15, 20 minutes)
  final List<int> _timerOptions = [180, 600, 900, 1200];

  // Selected time from dropdown, initialized with the first option
  late int _selectedTimeInSeconds;
  bool _isTimerRunning = false;

  // Remaining time in seconds
  int _remainingTimeInSeconds = 0;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Initialize selected time and remaining time with the first option
    _selectedTimeInSeconds = _timerOptions.first;
    _remainingTimeInSeconds = _selectedTimeInSeconds;

    _loadRiveFile();
  }

  // Load the Rive animation file
  Future<void> _loadRiveFile() async {
    try {
      final data = await rootBundle.load('assets/rive/pomodoro_tree.riv');
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      _controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
      if (_controller != null) {
        artboard.addController(_controller!);
        _progress = _controller!.findInput<double>('input');
        if (_progress != null) _progress!.value = _treeProgress.toDouble();
      }

      setState(() => _riveArtboard = artboard);
    } catch (e) {
      debugPrint('❌ Error loading Tree Rive file: $e');
    }
  }

  // Start or reset plant growth
  void _startOrResetGrowing() {
    if (_treeProgress >= _treeMaxProgress) {
      // If already full grown, reset everything
      _timer?.cancel();
      setState(() {
        _treeProgress = 0;
        _progress?.value = 0.0;
        plantButtonText = "Start Growing";
        _isTimerRunning = false;
        _remainingTimeInSeconds = _selectedTimeInSeconds;
      });
      return;
    }

    if (_isTimerRunning) return; // Prevent multiple timers

    setState(() {
      plantButtonText = "Growing...";
      _isTimerRunning = true;
    });

    _timer?.cancel();

    const intervalMs = 1000; // 1 second
    _timer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      setState(() {
        if (_remainingTimeInSeconds <= 0) {
          // When time is finished, mark plant as fully grown
          _treeProgress = _treeMaxProgress;
          _progress?.value = _treeProgress.toDouble();
          plantButtonText = "Plant Fully Grown";
          _confettiController.play();
          _isTimerRunning = false;
          _remainingTimeInSeconds = 0;
          timer.cancel();
        } else {
          // Decrease remaining time and update tree progress
          _remainingTimeInSeconds--;
          _treeProgress = ((_selectedTimeInSeconds - _remainingTimeInSeconds) /
              _selectedTimeInSeconds *
              _treeMaxProgress)
              .round();
          _progress?.value = _treeProgress.toDouble();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tree size will be based on screen width
    double treeVisualSize = MediaQuery.of(context).size.width - 40;

    // Progress percentage for circular indicator
    double displayedPercent = _treeProgress / _treeMaxProgress;
    Color percentColor =
    _treeProgress >= _treeMaxProgress ? Colors.green : Colors.deepOrange;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Fixed height for non-Rive widgets
              double fixedWidgetsHeight = 60 + // Top padding
                  20 + // Dropdown vertical padding
                  (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) +
                  20 + // Dropdown approx height + padding
                  10 + // Time left text padding
                  (Theme.of(context).textTheme.displayLarge?.fontSize ?? 30) +
                  30 + // "Time left to grow..." padding
                  (Theme.of(context).textTheme.bodySmall?.fontSize ?? 10) +
                  100 + // Button bottom padding
                  40; // Button height

              // Available height for Rive section
              double availableHeightForRive =
                  constraints.maxHeight - fixedWidgetsHeight;

              double riveSectionHeight =
              availableHeightForRive > treeVisualSize
                  ? availableHeightForRive
                  : treeVisualSize;

              // Ensure it never goes below treeVisualSize
              if (riveSectionHeight < treeVisualSize) {
                riveSectionHeight = treeVisualSize;
              }

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Text(
                          "Stay Focused",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Timer dropdown menu
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white54, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedTimeInSeconds,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white70, size: 30),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                              dropdownColor: Colors.black.withOpacity(0.9),
                              elevation: 8,
                              items: _timerOptions.map((int seconds) {
                                return DropdownMenuItem<int>(
                                  value: seconds,
                                  child: Text(
                                    "${seconds ~/ 60} minutes",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              onChanged: _isTimerRunning
                                  ? null
                                  : (int? newValue) {
                                setState(() {
                                  _selectedTimeInSeconds = newValue!;
                                  _remainingTimeInSeconds = newValue;
                                  _treeProgress = 0;
                                  _progress?.value = 0.0;
                                  plantButtonText = "Start Growing";
                                });
                              },
                            ),
                          ),
                        ),
                      ),

                      // Circular tree growth with Rive
                      SizedBox(
                        height: riveSectionHeight - 20,
                        child: Center(
                          child: _riveArtboard == null
                              ? const SizedBox.shrink()
                              : CircularPercentIndicator(
                            radius: treeVisualSize / 2,
                            lineWidth: 8.0,
                            percent: displayedPercent,
                            animation: false,
                            progressColor: percentColor,
                            backgroundColor: Colors.white12,
                            circularStrokeCap: CircularStrokeCap.round,
                            center: SizedBox(
                              width: treeVisualSize,
                              height: treeVisualSize,
                              child: Rive(
                                alignment: Alignment.center,
                                artboard: _riveArtboard!,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Remaining time display
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          intToTimeLeft(_remainingTimeInSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Text(
                          "Time left to grow the plant",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),

                      // Start/Reset button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(180, 40),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            elevation: 8,
                          ),
                          onPressed: _startOrResetGrowing,
                          child: Text(
                            plantButtonText,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Confetti effect when fully grown
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.yellow, Colors.red],
            ),
          ),
        ],
      ),
    );
  }
}

// Converts integer (seconds) into MM:SS format
String intToTimeLeft(int value) {
  int m = value ~/ 60;
  int s = value % 60;

  String minuteLeft = m.toString().padLeft(2, '0');
  String secondsLeft = s.toString().padLeft(2, '0');

  return "$minuteLeft:$secondsLeft";
}
