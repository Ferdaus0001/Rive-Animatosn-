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
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart'; // <-- Music Import

class PlantScreen extends StatefulWidget {
  const PlantScreen({super.key});

  @override
  _PlantScreenState createState() => _PlantScreenState();
}

class _PlantScreenState extends State<PlantScreen>
    with SingleTickerProviderStateMixin {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _progress;
  String plantButtonText = "Start Growing";

  int _treeProgress = 0;
  final int _treeMaxProgress = 100;
  Timer? _timer;

  final List<int> _timerOptions = [60,180, 600, 900, 1200, 1500, 1800, 2400, 2700, 3000];
  late int _selectedTimeInSeconds;
  bool _isTimerRunning = false;
  int _remainingTimeInSeconds = 0;

  late ConfettiController _confettiController;

  // Button animation controller
  late AnimationController _buttonController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer(); // <-- Add music player

  @override
  void initState() {
    super.initState();

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    _selectedTimeInSeconds = _timerOptions.first;
    _remainingTimeInSeconds = _selectedTimeInSeconds;

    _loadRiveFile();

    // Button animation
    _buttonController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // নিচ থেকে আসবে
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeIn));

    // Animate button only once
    _buttonController.forward();
  }

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

  void _startOrResetGrowing() {
    // Play background music once
    _playBackgroundMusic();

    if (_treeProgress >= _treeMaxProgress) {
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

    if (_isTimerRunning) return;

    setState(() {
      plantButtonText = "Growing...";
      _isTimerRunning = true;
    });

    _timer?.cancel();

    const intervalMs = 1000;
    _timer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      setState(() {
        if (_remainingTimeInSeconds <= 0) {
          _treeProgress = _treeMaxProgress;
          _progress?.value = _treeProgress.toDouble();
          plantButtonText = "Plant Fully Grown";
          _confettiController.play();
          _isTimerRunning = false;
          _remainingTimeInSeconds = 0;
          timer.cancel();
        } else {
          _remainingTimeInSeconds--;
          _treeProgress =
              ((_selectedTimeInSeconds - _remainingTimeInSeconds) /
                  _selectedTimeInSeconds *
                  _treeMaxProgress)
                  .round();
          _progress?.value = _treeProgress.toDouble();
        }
      });
    });
  }

  void _playBackgroundMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop music
      await _audioPlayer.play(AssetSource('assets/image/soundTow.mp3'));
    } catch (e) {
      debugPrint('❌ Error playing music: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    _confettiController.dispose();
    _buttonController.dispose();
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double treeVisualSize = MediaQuery.of(context).size.width - 40;
    double displayedPercent = _treeProgress / _treeMaxProgress;
    Color percentColor =
    _treeProgress >= _treeMaxProgress ? Colors.green : Colors.deepOrange;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double fixedWidgetsHeight = 60 +
                  20 +
                  (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) +
                  20 +
                  10 +
                  (Theme.of(context).textTheme.displayLarge?.fontSize ?? 30) +
                  30 +
                  (Theme.of(context).textTheme.bodySmall?.fontSize ?? 10) +
                  100 +
                  40;

              double availableHeightForRive =
                  constraints.maxHeight - fixedWidgetsHeight;

              double riveSectionHeight =
              availableHeightForRive > treeVisualSize
                  ? availableHeightForRive
                  : treeVisualSize;

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

                      // Timer dropdown
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

                      // Rive tree with circular progress
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

                      // Animated Start/Reset button
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 100, left: 50, right: 50, top: 5),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(200, 45),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                elevation: 12,
                                shadowColor: Colors.green.withOpacity(0.6),
                                padding: EdgeInsets.zero,
                              ).copyWith(
                                backgroundColor:
                                MaterialStateProperty.all(Colors.transparent),
                                overlayColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.2)),
                                surfaceTintColor:
                                MaterialStateProperty.all(Colors.transparent),
                              ),
                              onPressed: _startOrResetGrowing,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.green, Colors.teal],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Container(
                                  height: 65,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.local_florist,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        plantButtonText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Confetti effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.1,
              numberOfParticles: 50,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.2,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.red,
                Colors.purple,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String intToTimeLeft(int value) {
  int m = value ~/ 60;
  int s = value % 60;
  return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
}
