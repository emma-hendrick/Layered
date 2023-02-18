import 'dart:async';
import 'package:record/record.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Layered());
}

class Layered extends StatelessWidget {
  const Layered({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layered',
      theme: ThemeData(
        // Primary app Color
        primarySwatch: Colors.deepOrange,
      ),
      home: const MicPage(title: 'Layered'),
    );
  }
}

class MicPage extends StatefulWidget {
  const MicPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {

  Record myRecording = Record();

  // TODO
  // Initialize an empty list of recordings, as the program continues we will
  // add new recordings here, and then remove them when needed
  List<Record> myRecordings = [];

  Timer? timer;

  // TODO
  // Remove these
  double volume = 0.0;
  // This sets what volume the display will trigger at
  double minVolume = -45.0;

  startTimer() async {
    timer ??= Timer.periodic(
        const Duration(milliseconds: 50), (timer) => updateVolume());
  }

  // Get the current volume - Not necessary for final program
  updateVolume() async {
    Amplitude ampl = await myRecording.getAmplitude();
    if (ampl.current > minVolume) {
      setState(() {
        volume = (ampl.current - minVolume) / minVolume;
      });
    }
  }

  // Return the volume on a scale from 0 to maxVolume - Not necessary for final program
  int volumeScaleTo(int maxVolume) {
    return (volume * maxVolume).round().abs();
  }

  Future<bool> startRecording(recording) async {
    if (await recording.hasPermission()) {
      if (!await recording.isRecording()) {
        await recording.start();
      }
      startTimer();
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: startRecording(Record()),
      builder: (context, AsyncSnapshot<bool> snapshot) {
      return Scaffold(
        appBar: AppBar(
        // Here we take the value from the MicPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                snapshot.hasData
                    ? "VOLUME\n${volumeScaleTo(100)}"
                    : "We need recording permission to show data about your audio",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 42, fontWeight: FontWeight.bold
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

