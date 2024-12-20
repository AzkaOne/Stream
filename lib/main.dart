import 'package:flutter/material.dart';
import 'stream.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AzkaOne Stream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StreamHomePage(),
    );
  }
}

class StreamHomePage extends StatefulWidget {
  const StreamHomePage({super.key});

  @override
  State<StreamHomePage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamHomePage> {
  late StreamSubscription subscription;
  late StreamTransformer transformer;
  Color bgColor = Colors.purple;
  late ColorStream colorStream;
  int lastNumber = 0;
  late StreamController numberStreamController;
  late NumberStream numberStream;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('AzkaOne Stream'),
            centerTitle: true,
            backgroundColor: Colors.blue,
          ),
          body: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(lastNumber.toString()),
                ElevatedButton(
                  onPressed: () => addRandomNumber(),
                  child: Text('add New Number'),
                ),
                ElevatedButton(
                  onPressed: () => stopStream(),
                  child: Text('Stop Subcription'),
                )
              ],
            ),
          )),
    );
  }

  void changeColor() async {
    // await for (var eventColor in colorStream.getColors()) {
    //   setState(() {
    //     bgColor = eventColor;
    //   });
    // }

    colorStream.getColors().listen((eventColor) {
      setState(() {
        bgColor = eventColor;
      });
    });
  }

  @override
  void initState() {
    //percobaan 1
    /* super.initState();
    colorStream = ColorStream();
    changeColor();
  }*/
    numberStream = NumberStream();
    numberStreamController = numberStream.controller;
    Stream stream = numberStreamController.stream;
    subscription = stream.listen((event) {
      setState(() {
        lastNumber = event;
      });
    });
    super.initState();
    subscription.onError((error) {
      setState(() {
        lastNumber = -1;
      });
    });
    subscription.onDone(() {
      print('onDone was called');
    });

    // stream.listen((event) {
    //   setState(() {
    //     lastNumber = event;
    //   });
    // }).onError((error) {
    //   setState(() {
    //     lastNumber = -1;
    //   });
    // });

    transformer = StreamTransformer<int, int>.fromHandlers(
        handleData: (value, sink) {
          sink.add(value * 10);
        },
        handleError: (error, trace, sink) {
          sink.add(-1);
        },
        handleDone: (sink) => sink.close());

    // stream.transform(transformer).listen((event) {
    //   setState(() {
    //     lastNumber = event;
    //   });
    // }).onError((error) {
    //   setState(() {
    //     lastNumber = -1;
    //   });
    // });
    // super.initState();
  }

  @override
  void dispose() {
    // numberStreamController.close();
    // super.dispose();
    subscription.cancel();
  }

  void addRandomNumber() {
    Random random = Random();
    int myNum = random.nextInt(10);
    if (!numberStreamController.isClosed) {
      numberStream.addNumberToSink(myNum);
    } else {
      setState(() {
        lastNumber = -1;
      });
    }
    // numberStream.addError();
  }

  void stopStream() {
    numberStreamController.close();
  }
}
