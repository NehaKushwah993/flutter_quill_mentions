import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_mention/custom_quill/custom_quill_constants.dart';
import 'package:intl/intl.dart';

class CustomQuillEditor extends StatefulWidget {
  final GlobalKey? keyForPosition;
  final QuillController controller;

  const CustomQuillEditor({
    super.key,
    required this.controller,
    required this.keyForPosition,
  });

  @override
  State<CustomQuillEditor> createState() => _CustomQuillEditorState();
}

class _CustomQuillEditorState extends State<CustomQuillEditor> {
  late final QuillController _controller;

  String? _currentTaggingCharacter = '#';
  OverlayEntry? _hashTagOverlayEntry;
  bool _isEditorLTR = true;
  int? lastHashTagIndex = -1;
  ValueNotifier<List<String>> hashTagWordList = ValueNotifier([]);
  ValueNotifier<List<String>> atMentionSearchList = ValueNotifier([]);
  final FocusNode _focusNode = FocusNode();

  final List<String> _tempHashTagList = ["Instagram", "Facebook", "Youtube"];

  final List<String> _tempAtMentionList = ["Neha", "John", "Tim"];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(editorListener);
    _focusNode.addListener(_advanceTextFocusListener);
    fillDataInTags();
  }

  fillDataInTags() {
    hashTagWordList.value = <String>[..._tempHashTagList];
    atMentionSearchList.value = <String>[..._tempAtMentionList];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.keyForPosition,
      child: QuillEditor.basic(
        focusNode: _focusNode,
        configurations: QuillEditorConfigurations(
          controller: _controller,
          builder: (context, rawEditor) {
            return rawEditor;
          },
          onLaunchUrl: (string) async {
            await launch(context, string);
          },
          elementOptions: elementOptions,
          padding: const EdgeInsets.all(8),
          maxHeight: 120,
          minHeight: 30,
          readOnly: false,
          showCursor: true,
          customShortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter, alt: true):
                AltEnterIntent(SelectionChangedCause.keyboard),
            SingleActivator(LogicalKeyboardKey.enter):
                EnterIntent(SelectionChangedCause.keyboard),
          },
          customActions: <Type, Action<Intent>>{
            AltEnterIntent: QuillEditorAltEnterAction(_controller),
            EnterIntent: QuillEditorEnterAction(
              onEnterPressedOnKeyboard: () {
                if ((_hashTagOverlayEntry?.mounted ?? false)) {
                  // insert first visible item from list
                  if (_currentTaggingCharacter == "@" &&
                      atMentionSearchList.value.firstOrNull != null) {
                    _onTapOverLaySuggestionItem(atMentionSearchList.value.first,
                        uid: atMentionSearchList.value.first);
                  } else if (_currentTaggingCharacter == "#" &&
                      hashTagWordList.value.firstOrNull != null) {
                    _onTapOverLaySuggestionItem(hashTagWordList.value.first,
                        uid: hashTagWordList.value.first);
                  }
                }
              },
            ),
          },
          customStyles: defaultStyles,
          textInputAction: TextInputAction.send,
          isOnTapOutsideEnabled: true,
        ),
      ),
    );
  }

  void editorListener() {
    try {
      final index = _controller.selection.baseOffset;
      final value = _controller.plainTextEditingValue.text;
      if (value.trim().isNotEmpty) {
        final newString = value.substring(index - 1, index);

        /// check text directionality
        if (newString != ' ' && newString != '\n') {
          _checkEditorTextDirection(newString);
        }
        if (newString == '\n') {
          _isEditorLTR = true;
        }

        if (newString == '#') {
          _currentTaggingCharacter = '#';
          if (_hashTagOverlayEntry == null &&
              !(_hashTagOverlayEntry?.mounted ?? false)) {
            lastHashTagIndex = _controller.selection.baseOffset;
            _hashTagOverlayEntry = _createHashTagOverlayEntry();
            Overlay.of(context).insert(_hashTagOverlayEntry!);
          }
        }

        if (newString == '@') {
          _currentTaggingCharacter = '@';
          if (_hashTagOverlayEntry == null &&
              !(_hashTagOverlayEntry?.mounted ?? false)) {
            lastHashTagIndex = _controller.selection.baseOffset;
            _hashTagOverlayEntry = _createHashTagOverlayEntry();
            Overlay.of(context).insert(_hashTagOverlayEntry!);
          }
        }

        /// Add #tag without selecting from suggestion
        if ((newString == ' ' || newString == '\n') &&
            _hashTagOverlayEntry != null &&
            _hashTagOverlayEntry!.mounted) {
          _removeOverLay();
        }

        /// Show overlay when #tag detect and filter it's list
        if (lastHashTagIndex != -1 &&
            _hashTagOverlayEntry != null &&
            (_hashTagOverlayEntry?.mounted ?? false)) {
          var newWord = value
              .substring(lastHashTagIndex!, value.length)
              .replaceAll('\n', '');
          if (_currentTaggingCharacter == '#') {
            _getHashTagSearchList(newWord.toLowerCase());
          }

          if (_currentTaggingCharacter == '@') {
            _getAtMentionSearchList(newWord.toLowerCase());
          }
        }
      } else {
        _removeOverLay();
      }
    } catch (e) {
      print('Exception in catching last character : $e');
    }
  }

  void _removeOverLay() {
    try {
      if (_hashTagOverlayEntry != null && _hashTagOverlayEntry!.mounted) {
        _hashTagOverlayEntry!.remove();
        _hashTagOverlayEntry = null;
        fillDataInTags();
      }
    } catch (e) {
      print('Exception in removing overlay :$e');
    }
  }

  Future<void> _getHashTagSearchList(String? query) async {
    /// you can call api here to get the list
    try {
      hashTagWordList.value = _tempHashTagList
          .where((element) =>
              (element).toLowerCase().contains(query?.toLowerCase() ?? ""))
          .toList()
        ..sort((t1, t2) => t1.compareTo(t2));
      if (hashTagWordList.value.isEmpty) {
        _removeOverLay();
      }
    } catch (e) {
      print('Exception in getHashTagSearchList : $e');
    }
  }

  Future<void> _getAtMentionSearchList(String? query) async {
    /// you can call api here to get the list
    try {
      atMentionSearchList.value = _tempAtMentionList
          .where((element) =>
              element.toLowerCase().contains(query?.toLowerCase() ?? ""))
          .toList()
        ..sort((t1, t2) => t1.compareTo(t2));
      if (atMentionSearchList.value.isEmpty) {
        _removeOverLay();
      }
    } catch (e) {
      print('Exception in _getAtMentionSearchList : $e');
    }
  }

  void _refreshScreen() {
    if (mounted) {
      setState(() {});
    }
  }

  void _checkEditorTextDirection(String text) {
    try {
      var _isRTL = Bidi.detectRtlDirectionality(text);
      var style = _controller.getSelectionStyle();
      var attribute = style.attributes[Attribute.align.key];
      // print(attribute);
      if (_isEditorLTR) {
        if (_isEditorLTR != !_isRTL) {
          if (_isRTL) {
            _isEditorLTR = false;
            _controller.formatSelection(Attribute.clone(Attribute.align, null));
            _controller.formatSelection(Attribute.rightAlignment);
            _refreshScreen();
          } else {
            var validCharacters = RegExp(r'^[a-zA-Z]+$');
            if (validCharacters.hasMatch(text)) {
              _isEditorLTR = true;
              _controller
                  .formatSelection(Attribute.clone(Attribute.align, null));
              _controller.formatSelection(Attribute.leftAlignment);
              _refreshScreen();
            }
          }
        } else {
          if (attribute == null && _isRTL) {
            _isEditorLTR = false;
            _controller.formatSelection(Attribute.clone(Attribute.align, null));
            _controller.formatSelection(Attribute.rightAlignment);
            _refreshScreen();
          } else if (attribute == Attribute.rightAlignment && !_isRTL) {
            var validCharacters = RegExp(r'^[a-zA-Z]+$');
            if (validCharacters.hasMatch(text)) {
              _isEditorLTR = true;
              _controller
                  .formatSelection(Attribute.clone(Attribute.align, null));
              _controller.formatSelection(Attribute.leftAlignment);
              _refreshScreen();
            }
          }
        }
      }
    } catch (e) {
      print('Exception in _checkEditorTextDirection : $e');
    }
  }

  void _onTapOverLaySuggestionItem(String value, {required String? uid}) {
    var _lastHashTagIndex = lastHashTagIndex;
    _controller.replaceText(_lastHashTagIndex!,
        _controller.selection.extentOffset - _lastHashTagIndex, value, null);
    _controller.updateSelection(
        TextSelection(
            baseOffset: _lastHashTagIndex - 1,
            extentOffset: _controller.selection.extentOffset +
                (value.length -
                    (_controller.selection.extentOffset - _lastHashTagIndex))),
        ChangeSource.local);
    if (_currentTaggingCharacter == '#') {
      /// Channel
      _controller.formatSelection(LinkAttribute("$prefix_hashtag$uid"));
    } else {
      /// User
      _controller.formatSelection(LinkAttribute("$prefix_mention$uid"));
    }
    Future.delayed(Duration.zero).then((value) {
      _controller.moveCursorToEnd();
    });
    lastHashTagIndex = -1;
    _controller.document.insert(_controller.selection.extentOffset, ' ');
    Future.delayed(const Duration(seconds: 1))
        .then((value) => _removeOverLay());
    fillDataInTags();
  }

  @override
  void dispose() {
    _controller.removeListener(editorListener);
    _focusNode.removeListener(_advanceTextFocusListener);
    _controller.dispose();
    if (_hashTagOverlayEntry != null) {
      if (_hashTagOverlayEntry!.mounted) {
        _removeOverLay();
      }
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        _hashTagOverlayEntry!.dispose();
      });
    }
    super.dispose();
  }

  void _advanceTextFocusListener() {
    FocusNode? focusedChild = FocusScope.of(context).focusedChild;
    if (focusedChild != null && !_focusNode.hasPrimaryFocus) {
      if (_hashTagOverlayEntry != null) {
        if (_hashTagOverlayEntry!.mounted) {
          _removeOverLay();
        }
      }
    }
  }

  OverlayEntry _createHashTagOverlayEntry() {
    RenderBox box =
        widget.keyForPosition?.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero); //this is global position
    double y = position.dy;
    double x = position.dx;
    final viewInsets = EdgeInsets.fromViewPadding(
        View.of(context).viewInsets, View.of(context).devicePixelRatio);
    double heightKeyboard = viewInsets.bottom - viewInsets.top;

    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).size.height - heightKeyboard - y,
        width: MediaQuery.of(context).size.width - (2 * x),
        left: x,
        child: Material(
          elevation: 4.0,
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.4)),
            ),
            clipBehavior: Clip.hardEdge,
            constraints: const BoxConstraints(maxHeight: 150, minHeight: 50),
            child: _currentTaggingCharacter == '#'
                ? ValueListenableBuilder(
                    valueListenable: hashTagWordList,
                    builder: (BuildContext context, List<String> value,
                        Widget? child) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: value.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              _onTapOverLaySuggestionItem(value[index],
                                  uid: value[index]);
                            },
                            child: ListTile(
                              title: Text(
                                value[index],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : ValueListenableBuilder(
                    valueListenable: atMentionSearchList,
                    builder: (BuildContext context, List<String> value,
                        Widget? child) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: value.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          var data = value[index];
                          return InkWell(
                            onTap: () {
                              _onTapOverLaySuggestionItem(data, uid: data);
                            },
                            child: ListTile(
                              leading: const Icon(Icons.search),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class QuillEditorAltEnterAction extends ContextAction<AltEnterIntent> {
  QuillEditorAltEnterAction(this.controller);

  final QuillController controller;

  @override
  void invoke(AltEnterIntent intent, [BuildContext? context]) {
    TextSelection selection = controller.plainTextEditingValue.selection;
    controller.replaceText(
        selection.start,
        selection.end - selection.start,
        '\n',
        TextSelection(
            baseOffset: selection.start + 1,
            extentOffset: selection.start + 1));
  }

  @override
  bool get isActionEnabled => true;
}

class QuillEditorEnterAction extends ContextAction<EnterIntent> {
  QuillEditorEnterAction({required this.onEnterPressedOnKeyboard});

  final Function? onEnterPressedOnKeyboard;

  @override
  void invoke(EnterIntent intent, [BuildContext? context]) {
    onEnterPressedOnKeyboard?.call();
  }

  @override
  bool get isActionEnabled => true;
}

/// An [Intent] that represents a user interaction when pressed alt+enter
class AltEnterIntent extends Intent {
  /// Creates an [UndoTextIntent].
  const AltEnterIntent(this.cause);

  /// {@macro flutter.widgets.TextEditingIntents.cause}
  final SelectionChangedCause cause;
}

/// An [Intent] that represents a user interaction when pressed enter
class EnterIntent extends Intent {
  /// Creates an [UndoTextIntent].
  const EnterIntent(this.cause);

  /// {@macro flutter.widgets.TextEditingIntents.cause}
  final SelectionChangedCause cause;
}
