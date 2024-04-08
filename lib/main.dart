
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
// import 'package:youtube/youtube_thumbnail.dart';
import 'package:gap/gap.dart';

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
                  MaterialPageRoute(builder: (context) => Downloadprogress(filename: Title_controller.text, videourl : URL_controller.text)),
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
  final String filename;
  Downloadprogress({super.key, required this.videourl, required this.filename});

  final apiurl = Uri.parse('http://127.0.0.1:7000/download');   //実機用
  // final apiurl = Uri.parse('http://10.0.2.2:8000/download');    //Android Emulator用

  late String videoid = get_videoID(videourl);
  late String title;

  //URLから動画IDを抽出する関数
  String get_videoID(String url){
    const patternWatch = 'https://www.youtube.com/watch?v=';
    const patternShort = 'https://youtu.be/';
    const patternMobile = 'https://m.youtube.com/watch?v=';
    if(url.contains(patternWatch)){
      debugPrint("普通のURLです");
      return url.substring(patternWatch.length, patternWatch.length + 11);
    } else if(url.contains(patternShort)){
      debugPrint("短縮URLです");
      final id = url.substring(patternShort.length, patternShort.length + 11);
      return id;
    } else if(url.contains(patternMobile)){
      debugPrint("モバイルURLです");
      return url.substring(patternMobile.length, patternMobile.length + 11);
    } else {
      debugPrint('URLが不正です');
      return url;
    }
  }

  //動画のタイトルを取得する関数
  Future<String> get_title() async {
    final response = await http.get(Uri.parse(videourl));
    title = RegExp(r'<title>(.*?)</title>').firstMatch(response.body)?.group(1) ?? 'タイトルが取得できませんでした';

    title = title.substring(0, title.length - 10);

    debugPrint("get_titleで取得できた動画タイトル: $title");

    return title;
  }

  //動画をダウンロードをサーバにリクエストする関数
  Future<String> downloading(String link, BuildContext context) async {

    debugPrint('ダウンロードを開始します');

    //APIにリクエストを送信
    try {
      final response = await http.post(apiurl, 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Keep-Alive": "timeout=60, max=1"
        }, 
        body: jsonEncode(<String, String>{
          'url': link,
        })
      );
  
      debugPrint('サーバから応答が返ってきました');

      if(response.statusCode == 200){
        debugPrint('success');
        final data = json.decode(response.body);
        return data['message'] ?? 'データがありません';
      } else {
        debugPrint('failed');
        return 'エラー: ステータスコード${response.statusCode}';
      }
    } catch (e) {
      debugPrint('エラーが発生しました: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('サーバーからの応答がありませんでした。もう一度試してみてください'),
        ),
      );
      Navigator.of(context).pop();
      return 'エラー: タイムアウト';
    }
  }

  //ファイルを保存する関数
  Future<bool> saveFile(String filename) async {
    final url = Uri.parse("http://127.0.0.1:7000/file_download");      //実機用
    // final url = Uri.parse("http://10.0.2.2:8000/file_download");        //Android Emulator用
    debugPrint('ファイルをダウンロードします');
    debugPrint('ファイル名: $filename');
    
    if(filename == ''){
      filename = title;
    }

    final data = await http.post(url, 
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }, 
      body: jsonEncode(<String, String>{
        'videoTitle': title,
      })
    ).timeout(const Duration(minutes: 10));

    debugPrint('ファイルのダウンロードが完了しました');
    debugPrint('debug: ${data.statusCode}');
    try {
      if(data.statusCode == 200){
        final params = SaveFileDialogParams(
          data: data.bodyBytes,
          fileName: '$filename.mp4',
        );
        debugPrint('ファイルを保存します');
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

  //ダウンロード中のダイアログを表示する関数
  void downloadindwaitdialog(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('ファイルを保存中です'),
          content: CircularProgressIndicator(),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ダウンロード中'),
      ),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          Image.network(Uri.parse('https://img.youtube.com/vi/$videoid/0.jpg').toString()),

          const Gap(10),

          FutureBuilder(
            future: get_title(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('エラーが発生しました: ${snapshot.error}');
                } else {
                  return Text(snapshot.data);
                }
              } else {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '動画タイトル取得中…',
                    ),
                  ]
                );
              }
            }
          ),

          const Gap(10),

          FutureBuilder(
            future: downloading(videourl, context),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('エラーが発生しました: ${snapshot.error}');
                } else {
                  if(snapshot.data == 'Download successful'){
                    return ElevatedButton(
                          onPressed: () async {
                            downloadindwaitdialog(context);
                            final result = await saveFile(filename);
                            if(result == true){
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ファイルの保存に成功しました'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ファイルの保存に失敗しました'),
                                ),
                              );
                            }
                          }, 
                          child: const Text("ファイルを保存")
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
        ]
      )
    );
  }
}



