
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
// import 'dart:io';


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

    final TextEditingController controller = TextEditingController();
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
                controller: controller,
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
                  MaterialPageRoute(builder: (context) => Downloadprogress(videourl: controller.text)),
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

  final String videourl;
  Downloadprogress({super.key, required this.videourl});

  final apiurl = Uri.parse('http://127.0.0.1:7000/download');


  // Future<void> downloading(String link) async {

  //   debugPrint('start downloading');

  //   //APIにリクエストを送信
  //   final response = await http.get(apiurl); 
  //   if(response.statusCode == 200){
  //     debugPrint('success');
  //   } else {
  //     debugPrint('failed');
  //   }
  // }

  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('ダウンロード中'),
  //     ),
  //     body: Center(
  //       child:FutureBuilder(
  //         future: downloading(videourl),
  //         builder: (BuildContext context, AsyncSnapshot snapshot) {
  //           if (snapshot.connectionState == ConnectionState.done) {
  //             return Text(snapshot.data.toString());
  //           } else if (snapshot.hasError) {
  //             return Text('Error: ${snapshot.error}');
  //           } else {
  //             return const Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: <Widget>[
  //                 Text(
  //                   'ダウンロード中です',
  //                 ),
  //                 CircularProgressIndicator()
  //               ]
  //             );
  //           }
  //         },
  //       )
  //     ),
  //   );
  // }

  Stream<void> downloading(String link) async* {

    debugPrint('start downloading');

    //APIにリクエストを送信
    final response = await http.get(apiurl); 
    if(response.statusCode == 200){
      debugPrint('success');
    } else {
      debugPrint('failed');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ダウンロード中'),
      ),
      body: Center(
        child:StreamBuilder(
          stream: downloading(videourl),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data.toString());
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



