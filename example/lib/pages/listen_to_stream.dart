// Dart Packages
import 'dart:async';

// Flutter Packages
import 'package:flutter/material.dart';

// This Package
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ListenToStream extends StatefulWidget {
  const ListenToStream({super.key});

  @override
  State<ListenToStream> createState() => _ListenToStreamState();
}

class _ListenToStreamState extends State<ListenToStream> {
  InternetStatus? _connectionStatus;
  late StreamSubscription<InternetStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      setState(() {
        _connectionStatus = status;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Listen to Stream')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This example shows how to listen for the internet connection '
                'status using a StreamSubscription.\n\n'
                'Changes to the internet connection status are listened and '
                'reflected in this example.',
                textAlign: TextAlign.center,
              ),
              const Divider(height: 48.0, thickness: 2.0),
              const Text('Connection Status:'),
              _connectionStatus == null
                  ? const CircularProgressIndicator.adaptive()
                  : Text(
                    _connectionStatus.toString(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
