import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class RiveHomeScreen extends StatefulWidget {
  const RiveHomeScreen({super.key});

  @override
  State<RiveHomeScreen> createState() => _RiveHomeScreenState();
}

class _RiveHomeScreenState extends State<RiveHomeScreen> {
  StateMachineController? _stateMachineController;
  Artboard? _riveArtboard;
  SMIInput<bool>? _onInput; // Renamed from _fireInput to match the correct input

  @override
  void initState() {
    super.initState();

    // Load the Rive file
    rootBundle.load('assets/rive/fire_button.riv').then(
          (data) {
        try {
          final file = RiveFile.import(data);
          final artboard = file.mainArtboard;

          // Attach state machine
          final controller = StateMachineController.fromArtboard(
            artboard,
            'State Machine 1', // ✅ Must match your Rive file
          );

          if (controller != null) {
            artboard.addController(controller);

            // Debug: List all inputs
            for (var input in controller.inputs) {
              print("Found input: ${input.name} (${input.runtimeType})");
            }

            // Try to find ON input
            _onInput = controller.findInput<bool>('ON'); // Updated to match the input name
            print('ON input found: ${_onInput != null}');

            if (_onInput != null) {
              print('Initial ON value: ${_onInput!.value}');
            }
          } else {
            print('❌ State Machine controller is NULL');
          }

          setState(() {
            _riveArtboard = artboard;
            _stateMachineController = controller;
          });
        } catch (e) {
          print('❌ Error processing Rive file: $e');
        }
      },
    ).catchError((error) {
      print('❌ Error loading Rive file: $error');
    });
  }

  // Tap function to toggle ON
  void _onTap() {
    print('🔥 Tap detected');
    if (_onInput != null) {
      final newValue = !_onInput!.value; // Toggle boolean
      _onInput!.value = newValue;
      print('✅ ON toggled to: $newValue');
    } else {
      print('❌ ON input is NULL');
    }
  }

  @override
  void dispose() {
    _stateMachineController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: _riveArtboard == null
              ? const CircularProgressIndicator()
              : GestureDetector(
            onTap: _onTap,
            child: Rive(
              artboard: _riveArtboard!,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}