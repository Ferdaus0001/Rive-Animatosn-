
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rive_animation/rive/presentatosn/rive_fire_animatosn_screen.dart'; // <-- Music Import

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

  final List<int> _timerOptions = [ 30,60,180, 600, 900, 1200, 1500, 1800, 2400, 2700, 3000];
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
      begin: const Offset(0, 1),
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
    double _ = MediaQuery.of(context).size.width - 40;
    double _ = _treeProgress / _treeMaxProgress;
    Color _ =
    _treeProgress >= _treeMaxProgress ? Colors.green : Colors.deepOrange;

    return Scaffold(
      appBar: AppBar(
        elevation: 6, // shadow
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Plant Growing 🌱",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.nature),
            onPressed: () {
              // কোনো action
            },
            color: Colors.white,
          ),
        ],
      ),
      drawer: Drawer(
        shape:   RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30.r),
            bottomRight: Radius.circular(30.r),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName:   Text(
                "Rive Animations",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text("choose your animation"),
              currentAccountPicture:   CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.play_circle_fill, size: 40.h, color: Colors.blue),
              ),
            ),

            // Tree
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.nature, color: Colors.green),
              ),
              title: const Text("Tree Animation"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RiveFireScreen()),
                );
              },
            ),
            const Divider(),

            // Fire
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.red),
              ),
              title: const Text("Fire Animation"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RiveFireScreen()),
                );
              },
            ),
            const Divider(),

            // Girls
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.girl, color: Colors.pink),
              ),
              title: const Text("Girls Animation"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RiveFireScreen()),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,

      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double treeVisualSize = MediaQuery.of(context).size.width - 40;
              double displayedPercent = _treeProgress / _treeMaxProgress;
              Color percentColor =
              _treeProgress >= _treeMaxProgress ? Colors.green : Colors.deepOrange;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Text(
                            "Stay Focused",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Timer dropdown
                        Padding(
                          padding:   EdgeInsets.symmetric(vertical: 20.h),
                          child: Container(
                            padding:   EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.white54, width: 1.w),
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
                                icon:   Icon(Icons.arrow_drop_down,
                                    color: Colors.white70, size: 30.h),
                                style:   TextStyle(
                                    color: Colors.white, fontSize: 18.sp),
                                dropdownColor: Colors.black.withOpacity(0.9),
                                elevation: 8,
                                items: _timerOptions.map((int seconds) {
                                  return DropdownMenuItem<int>(
                                    value: seconds,
                                    child: Text(
                                      "${seconds ~/ 60} minutes",
                                      style:   TextStyle(
                                          color: Colors.white, fontSize: 16.sp),
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
                        Expanded(
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
                        SizedBox(height: 10.h,),
                        // Remaining time display
                        Padding(
                          padding:   EdgeInsets.only(bottom: 10.h),
                          child: Text(
                            intToTimeLeft(_remainingTimeInSeconds),
                            style:   TextStyle(
                              color: Colors.white,
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                         Padding(
                          padding: EdgeInsets.only(bottom: 12.sp),
                          child: Text(
                            "Time left to grow the plant",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12.sp,
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
                              padding:   EdgeInsets.only(
                                  bottom: 20.h, left: 50.w, right: 50.w, top: 5.h),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize:   Size(200.w, 45.h),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0.r),
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
                                    gradient:   LinearGradient(
                                      colors: [Colors.green, Colors.teal],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20.0.r),
                                  ),
                                  child: Container(
                                    height: 65.h,
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
                                          SizedBox(width: 10.w),
                                        Text(
                                          plantButtonText,
                                          style:   TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.sp,
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