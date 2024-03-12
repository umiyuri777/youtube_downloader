

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

    // APIにリクエストを送信
    final response = await http.get(apiurl);
    if(response.statusCode == 200){
      debugPrint('success');
    } else {
      debugPrint('failed');
    }
  }

  Stream<String> getMultipleResponses(String link) async* {

    try {
      // APIにリクエストを送信
      var request = http.Request('GET', Uri.parse('http://127.0.0.1:7000/download'));

      debugPrint('リクエストを送信しました');

      // レスポンスを取得
      http.StreamedResponse response = await request.send();

      debugPrint('レスポンスを取得しました');

      // エラーハンドリング
      if (response.statusCode == 200) {

        debugPrint('接続成功！');

        await for (var data in response.stream.transform(utf8.decoder)) {
          debugPrint('data: $data');
          yield data;
        }
        yield 'ダウンロード中です';
      } else {
        debugPrint('接続失敗...');
        yield 'エラー: ステータスコード ${response.statusCode}';
      }
    } catch (e) {
      yield 'Error: $e';
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
          stream: getMultipleResponses(videourl),
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



