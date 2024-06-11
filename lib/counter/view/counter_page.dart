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
    _magneticSub =
        magnetometerEventStream(samplingPeriod: const Duration(seconds: 1))
            .listen((event) {
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

    if (heading != 0) {
      heading *= -1;
    }
    return heading;
  }

  String? getCardinalOrCollateralPoint(double degrees) {
    String? label;
    final tolerance = 22.5;

    // Normaliza o ângulo para o intervalo [0, 360)
    final normalizedDegrees = (degrees % 360 + 360) % 360;

    if (normalizedDegrees >= 0 && normalizedDegrees < tolerance) {
      label = 'N';
    } else if (normalizedDegrees >= 360 - tolerance ||
        normalizedDegrees < tolerance) {
      label = 'N';
    } else if (normalizedDegrees >= 45 - tolerance &&
        normalizedDegrees < 45 + tolerance) {
      label = 'NE';
    } else if (normalizedDegrees >= 90 - tolerance &&
        normalizedDegrees < 90 + tolerance) {
      label = 'L';
    } else if (normalizedDegrees >= 135 - tolerance &&
        normalizedDegrees < 135 + tolerance) {
      label = 'SE';
    } else if (normalizedDegrees >= 180 - tolerance &&
        normalizedDegrees < 180 + tolerance) {
      label = 'S';
    } else if (normalizedDegrees >= 225 - tolerance &&
        normalizedDegrees < 225 + tolerance) {
      label = 'SO';
    } else if (normalizedDegrees >= 270 - tolerance &&
        normalizedDegrees < 270 + tolerance) {
      label = 'O';
    } else if (normalizedDegrees >= 315 - tolerance &&
        normalizedDegrees < 315 + tolerance) {
      label = 'NO';
    }

    return label;
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

    final labelCardinalOrColateralPoint = getCardinalOrCollateralPoint(degrees);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: angle,
            child: Image.asset(
              'assets/line_background.png',
              height: sizeDevice.height,
              width: sizeDevice.height,
              fit: BoxFit.cover,
            ),
          ),
          Image.asset(
            'assets/dial.png',
            height: sizeDevice.height * 0.7,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (labelCardinalOrColateralPoint != null)
                Text(
                  labelCardinalOrColateralPoint,
                  style: TextStyle(
                    color: labelCardinalOrColateralPoint == 'N'
                        ? const Color(0xff6FFB01)
                        : Colors.white,
                    fontSize: 20,
                  ),
                ),
              Text(
                '${degrees.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
