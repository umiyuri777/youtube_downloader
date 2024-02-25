
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_hooks/flutter_hooks.dart';


void main() {
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'youtube動画ダウンローダー',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'youtube動画ダウンローダー'),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final TextEditingController _controller = TextEditingController();
    final formkey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '動画のURLを入力してください',
            ),
            Form(
              key: formkey,
              child: TextFormField(
                onChanged: (value) {
                  
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URLを入力してください';
                  }
                  return null;
                },
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'URL',
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              if(formkey.currentState!.validate()){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Downloadprogress(url: _controller.text)),
                );                
              }
            },
            child: const Text('ダウンロード'),
          ),
          ],
        ),
      ),
    );
  }
}



class Downloadprogress extends HookConsumerWidget {

  final String url;
  const Downloadprogress({super.key, required this.url});

  Future<void> wait() async {
    await Future.delayed(const Duration(seconds: 5));
    debugPrint('ダウンロード完了');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ダウンロード中'),
      ),
      body: Center(
        child:FutureBuilder(
          future: wait(), 
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return  const Text('完了');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Text(
                  'ダウンロード中です',
                ),
                CircularProgressIndicator()
                ]
              );
            }
          },
        )
      ),
    );
  }
}



