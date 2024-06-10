import 'dart:async';
import 'dart:math';

import 'package:compass/counter/counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CounterCubit(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  MagnetometerEvent _magneticEvent = MagnetometerEvent(0, 0, 0);
  StreamSubscription<MagnetometerEvent>? _magneticSub;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    _magneticSub = magnetometerEventStream().listen((event) {
      setState(() {
        _magneticEvent = event;
      });
    });
  }

  @override
  void dispose() {
    _magneticSub?.cancel();
    super.dispose();
  }

  double calculateDegress({
    required double x,
    required double y,
  }) {
    var heading = atan2(x, y);

    heading = heading * 180 / pi;
    if (heading > 0) {
      heading -= 360;
    }

    return heading * -1;
  }

  @override
  Widget build(BuildContext context) {
    final degrees = calculateDegress(
      x: _magneticEvent.x,
      y: _magneticEvent.y,
    );
    final angle = -1 * pi / 180 * degrees;
    print(degrees);
    print(angle);

    final sizeDevice = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Transform.rotate(
              angle: angle,
              child: Image.asset(
                'assets/line_background.png',
                height: sizeDevice.height,
                width: sizeDevice.height,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Center(
            child: Image.asset(
              'assets/dial.png',
              height: sizeDevice.height * 0.7,
            ),
          ),
          Center(
            child: Text(
              degrees.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
