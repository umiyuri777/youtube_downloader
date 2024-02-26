
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';


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

  Future<void> downloading(String link) async {
    debugPrint('Aダウンロード中');
    try {
      final youtubeDlResult = await Process.run('yt-dip', ['-f', '"bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]"', link]);
      var fileName = '';
      if (youtubeDlResult.stderr != null && youtubeDlResult.stderr is String && youtubeDlResult.stderr.isNotEmpty) {
        debugPrint(youtubeDlResult.stderr);
        exit(-1);
      }
      for (final line in (youtubeDlResult.stdout as String).split('\n')) {
        if (line.startsWith('[download] Destination: ')) {
          fileName = line.replaceFirst('[download] Destination: ', '');
          break;
        }
      }
      if (fileName == '') {
        debugPrint('Could not locate downloaded file. Perhaps the file already exists?'); return;
      } else {
        debugPrint('Finished downloading video: $fileName');
      }
      // プロセスの結果を確認
      debugPrint('Exit code: ${youtubeDlResult.exitCode}');
      debugPrint('Stdout: ${youtubeDlResult.stdout}');
      debugPrint('Stderr: ${youtubeDlResult.stderr}');
    } catch (e) {
      debugPrint('An error occurred: $e');
    }
    debugPrint('Bダウンロード中');
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ダウンロード中'),
      ),
      body: Center(
        child:FutureBuilder(
          // future: wait(), 
          future: downloading(url),
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



