// Dart Packages
import 'dart:async';

// Flutter Packages
import 'package:flutter/material.dart';

// This Package
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class CustomURIs extends StatefulWidget {
  const CustomURIs({super.key});

  @override
  State<CustomURIs> createState() => _CustomURIsState();
}

class _CustomURIsState extends State<CustomURIs> {
  InternetStatus? _connectionStatus;
  late StreamSubscription<InternetStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection.createInstance(
      customCheckOptions: [
        InternetCheckOption(
          uri: Uri.parse('https://cloudflare.com/cdn-cgi/trace'),
        ),
        InternetCheckOption(uri: Uri.parse('https://ipapi.co/ip')),
        InternetCheckOption(
          uri: Uri.parse('https://api.adviceslip.com/advice'),
        ),
        InternetCheckOption(
          uri: Uri.parse('https://api.bitbucket.org/2.0/repositories'),
        ),
        InternetCheckOption(
          uri: Uri.parse('https://api.thecatapi.com/v1/images/search'),
        ),
        InternetCheckOption(
          uri: Uri.parse('https://randomuser.me/api/?inc=gender'),
        ),
        InternetCheckOption(
          uri: Uri.parse('https://dog.ceo/api/breed/husky/list'),
        ),
        InternetCheckOption(uri: Uri.parse('https://lenta.ru')),
      ],
      useDefaultOptions: false,
    ).onStatusChange.listen((status) {
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
      appBar: AppBar(title: const Text('Custom URIs')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This example shows how to use custom URIs to check the internet '
                'connection status.',
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
