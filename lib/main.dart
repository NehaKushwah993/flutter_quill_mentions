import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_mention/custom_quill/custom_quill_editor.dart';

import 'custom_quill/custom_quill_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Quill',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Quill Editor with mention feature'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _quillKey = GlobalKey();
  final QuillController _quillControllerViewer = QuillController.basic();
  final QuillController _quillControllerEditor = QuillController.basic();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.purple.withOpacity(0.2),
              child: QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: _quillControllerEditor,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('en'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: CustomQuillEditor(
                controller: _quillControllerEditor,
                keyForPosition: _quillKey,
              ),
            ),
            const Divider(),
            ///
            ///
            ///
            ///
            ///
            ///
            ///
            ///
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Quill Viewer with HashTag/Mentions click handles",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    _quillControllerViewer.document =
                        _quillControllerEditor.document;
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("refresh"),
                      Icon(Icons.refresh),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomQuillViewer(
                  controller: _quillControllerViewer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
