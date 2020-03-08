import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_components/formatter/rich_text_input_formatter.dart';

/// 绑定软键盘的输入框，可跟随键盘弹出和收起 ，调用KeyboardInputState.popKeyboard即可
///

typedef DoneCallback = Future<bool> Function(List<Rule> rules, String value);

class KeyboardInput extends StatefulWidget {
  final WidgetBuilder builder;
  final TriggerAtCallback triggerAtCallback;
  final String unique;
  final String showContent;

  /// 获取MediaQuery.of(context)获取的是最近的一个MediaqueryData，bottom会不正确，所以先从外部获取再上一层的传进来使用
  final MediaQueryData mediaQueryData;
  final ValueChangedCallback valueChangedCallback;
  final DoneCallback doneCallback;

  final ValueChanged<String> onChanged;

  final WidgetBuilder rightMenuBuilder;
  final InputDecoration decoration;
  final TextStyle style;
  final List<TextInputFormatter> inputFormatters;

  const KeyboardInput({
    Key key,
    @required this.builder,
    @required this.triggerAtCallback,
    this.unique,
    this.showContent,
    @required this.mediaQueryData,
    this.valueChangedCallback,
    this.doneCallback,
    this.onChanged,
    this.rightMenuBuilder,
    this.decoration,
    this.style,
    this.inputFormatters,
  }) : super(key: key);

  @override
  KeyboardInputState createState() => KeyboardInputState();
}

class KeyboardInputState extends State<KeyboardInput>
    with WidgetsBindingObserver {
  TextEditingController _controller;
  FocusNode focusNode;
  bool _autoPopInput = false;
  bool _isTriggerAting = false;
  String _inputValue;

  List<Rule> _rules = [];

  RichTextInputFormatter _formatter;

  @override
  void initState() {
    _controller = TextEditingController();
    focusNode = FocusNode();
    _formatter = RichTextInputFormatter(
        triggerAtCallback: (List<Map<String, dynamic>> list) async {
          _isTriggerAting = true;
          Map<String, dynamic> ret = await widget.triggerAtCallback(list);
          _isTriggerAting = false;
          return ret;
        },
        controller: _controller,
        valueChangedCallback: (List<Rule> rules, String value) {
          _inputValue = value;
          _rules = rules;
          widget.valueChangedCallback?.call(rules, value);
        },
        unique: widget.unique,
        showContent: widget.showContent);
    _init();
    WidgetsBinding.instance.addObserver(this);
    focusNode.addListener(() {
      if (!focusNode.hasFocus && !_isTriggerAting && _autoPopInput) {
        setState(() {
          _autoPopInput = false;
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        bool isHideKeyboard = widget.mediaQueryData.viewInsets.bottom == 0;
        if (isHideKeyboard) {
          if (!_isTriggerAting) {
            _autoPopInput = false;
          }
          focusNode.unfocus();
          _inputValue = _controller.text;
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (_autoPopInput) {
              focusNode.unfocus();
            }
          },
          child: widget.builder(context),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: _autoPopInput ? null : 0,
            width: _autoPopInput ? null : 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(
                    color: Colors.grey[300],
                    width: 0.5,
                  ))),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Container(
                    margin:
                        EdgeInsets.only(left: 8, top: 8, bottom: 8, right: 16),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(3))),
                    child: TextField(
                      controller: _controller,
                      focusNode: focusNode,
                      onChanged: widget.onChanged,
                      decoration: widget.decoration ??
                          InputDecoration(
                            enabledBorder: null,
                            disabledBorder: null,
                            contentPadding: EdgeInsets.only(
                                left: 10, right: 10, top: 6, bottom: 6),
                            hintText: "please input...",
                            border: InputBorder.none,
                          ),
                      style: widget.style ??
                          TextStyle(
                              fontSize: 16,
                              color: Color(0xFF020F22),

                              /// hintText不居中与光标位置不一致
                              textBaseline: TextBaseline.alphabetic),
                      inputFormatters: widget.inputFormatters == null
                          ? [_formatter]
                          : (widget.inputFormatters..add(_formatter)),
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: widget.rightMenuBuilder?.call(context) ??
                        GestureDetector(
                          onTap: () => doneInput(),
                          child: Icon(
                            Icons.send,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  /// 弹出键盘和输入框
  void popKeyboard() {
    setState(() {
      _autoPopInput = true;
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  /// 完成输入
  doneInput() async {
    bool retBool = await widget.doneCallback?.call(_rules, _inputValue);
    if (retBool) {
      focusNode.unfocus();
      _init();
    }
  }

  void _init() {
    _controller.text = "";
    _inputValue = "";
    _rules.clear();
    _formatter.clear();
  }
}
