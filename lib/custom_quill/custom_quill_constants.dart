import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

Color textColor = Colors.black;
Color cardBackground = Colors.white;
// ignore: constant_identifier_names
const String prefix_hashtag = "-you-can-change-this-for-hashtag--";
// ignore: constant_identifier_names
const String prefix_mention = "-you-can-change-this-for-mention--";

final _textStyle = TextStyle(
  color: textColor,
);

final _textDarkBlockStyle = DefaultListBlockStyle(
  TextStyle(color: textColor),
  const VerticalSpacing(0, 0),
  const VerticalSpacing(0, 0),
  BoxDecoration(
    color: cardBackground,
  ),
  null,
);

final _textBlockStyle = DefaultTextBlockStyle(
  TextStyle(color: textColor),
  const VerticalSpacing(0, 0),
  const VerticalSpacing(0, 0),
  BoxDecoration(
    color: textColor,
  ),
);

final _listBlockStyle = DefaultListBlockStyle(
  TextStyle(color: textColor),
  const VerticalSpacing(0, 0),
  const VerticalSpacing(0, 0),
  BoxDecoration(
    color: textColor,
  ),
  null,
);
final defaultStyles = DefaultStyles(
  link: const TextStyle().copyWith(
    color: Colors.blue,
  ),
  paragraph: _textBlockStyle,
  code: _textDarkBlockStyle,
  lists: _listBlockStyle,
  strikeThrough: _textStyle,
  inlineCode: InlineCodeStyle(
    style: _textStyle,
  ),
  quote: _textDarkBlockStyle,
  underline: _textStyle,
  indent: _textBlockStyle,
);

const elementOptions = QuillEditorElementOptions(
  orderedList: QuillEditorOrderedListElementOptions(
      // fontColor: textColor,
      ),
  unorderedList: QuillEditorUnOrderedListElementOptions(
      // fontColor: textColor,
      ),
  codeBlock: QuillEditorCodeBlockElementOptions(
    enableLineNumbers: true,
  ),
);

launch(BuildContext context, String string) async {
  if (string.contains(prefix_mention) || string.contains(prefix_hashtag)) {
    String name = string.replaceAll("https://", "").replaceAll("http://", "");

    if (name.startsWith(prefix_mention)) {
      name = name.replaceAll(prefix_mention, "");
      //TODO : Do any thing with this name
      _showAlertDialog(context, "Mention Clicked", name);
      return;
    }
    if (name.startsWith(prefix_hashtag)) {
      name = name.replaceAll(prefix_hashtag, "");
      //TODO : Do any thing with this hashtag
      _showAlertDialog(context, "Hashtag Clicked", name);
      return;
    }
  }
  // its a URL
  if (string.trim().isNotEmpty) {
    //TODO : launch(string);
  }
}

_showAlertDialog(BuildContext context, String title, String desc) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(
        desc,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: const Text(
            "Ok",
            style: TextStyle(color: Colors.cyan, fontSize: 17),
          ),
        ),
      ],
    ),
  );
}
