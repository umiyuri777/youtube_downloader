
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
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

    final TextEditingController Title_controller = TextEditingController();
    final TextEditingController URL_controller = TextEditingController();
    final title_formkey = GlobalKey<FormState>();
    final URL_formkey = GlobalKey<FormState>();

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
              'タイトルを入力してください',
            ),
            Form(
              key: title_formkey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
                controller: Title_controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'タイトル',
                ),
              ),
            ),

            const Text(
              '動画のURLを入力してください',
            ),
            Form(
              key: URL_formkey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URLを入力してください';
                  }
                  return null;
                },
                controller: URL_controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'URL',
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              if(URL_formkey.currentState!.validate() || title_formkey.currentState!.validate()){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Downloadprogress(title: Title_controller.text, videourl : URL_controller.text)),
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
  final String title;
  Downloadprogress({super.key, required this.videourl, required this.title});

  final apiurl = Uri.parse('http://127.0.0.1:7000/download');


  Future<String> downloading(String link) async {

    debugPrint('ダウンロードを開始します');

    //APIにリクエストを送信
    final response = await http.get(apiurl);

    debugPrint('サーバから応答が返ってきました');

    if(response.statusCode == 200){
      debugPrint('success');
      final data = json.decode(response.body);
      return data['message'] ?? 'データがありません';
    } else {
      debugPrint('failed');
      return 'エラー: ステータスコード${response.statusCode}';
    }
  }

  Future<bool> saveFile(String filename) async {
    final url = Uri.parse("http://127.0.0.1:7000/file_download");
    final data = await http.get(url);
    try {
      if(data.statusCode == 200){
        final params = SaveFileDialogParams(
          data: data.bodyBytes,
          fileName: filename,
        );
        final savedfilePath = await FlutterFileDialog.saveFile(params: params);
        if(savedfilePath == null){
          throw Exception('ファイルの保存に失敗しました');
        }
      }else{
        throw Exception('ファイルのダウンロードに失敗しました');
      }
    } catch (e) {
      if(kDebugMode){
        debugPrint('エラーが発生しました: $e');
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ダウンロード中'),
      ),
      body: Center(
        child:FutureBuilder(
          future: downloading(videourl),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('エラーが発生しました: ${snapshot.error}');
              } else {
                if(snapshot.data == 'Download successful'){
                  return ElevatedButton(
                    onPressed: () async {
                      final result = await saveFile('$title.mp4');
                      if(result){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ファイルの保存に成功しました'),
                          )
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ファイルの保存に失敗しました'),
                          )
                        );
                      }
                    },
                    child: const Text('この端末にファイルを保存'),
                  );
                } else {
                  return const Text('エラーが発生しました');

                }

              }
            } else {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'サーバーに動画をダウンロード中です\nこれには時間がかかる場合があります',
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

  // Stream<void> downloading(String link) async* {

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
  //       child:StreamBuilder(
  //         stream: downloading(videourl),
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
}



