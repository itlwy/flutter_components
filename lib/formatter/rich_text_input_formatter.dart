import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// recording attributes of rich text segments
class Rule {
  final int startIndex;
  final int endIndex;

  /// extra attribute,you can put like userId and so on
  final Map<String, dynamic> params;

  Rule(this.startIndex, this.endIndex, [this.params]);

  Rule copy([startIndex, endIndex, params]) {
    return Rule(startIndex ?? this.startIndex, endIndex ?? this.endIndex,
        params ?? Map.of(this.params ?? {}));
  }
}

typedef TriggerAtCallback = Future<Map<String, dynamic>> Function(
    List<Map<String, dynamic>> params);

typedef ValueChangedCallback = void Function(List<Rule> rules, String value);

/// it can trigger callback when you input special symbol like @person
class RichTextInputFormatter extends TextInputFormatter {
  TriggerAtCallback _triggerAtCallback;
  ValueChangedCallback _valueChangedCallback;

  TextEditingController controller;
  List<Rule> _rules;

  /// using to compare between Rules
  final String unique;

  /// text behind triggerSymbol
  final String showContent;

  /// trigger symbol,when input this ,the [_triggerAtCallback] will be called
  final String triggerSymbol;

  /// compatible with Xiaomi ,because the formatEditUpdate method will be called multiple times on Xiaomi
  bool _flag = false;

  List<Rule> get rules => _rules.map((Rule rule) => rule.copy()).toList();

  RichTextInputFormatter(
      {@required TriggerAtCallback triggerAtCallback,
        ValueChangedCallback valueChangedCallback,
        @required this.controller,
        this.triggerSymbol = "@",
        this.unique = "_id",
        this.showContent = "content"})
      : assert(triggerAtCallback != null && controller != null),
        _rules = [],
        _triggerAtCallback = triggerAtCallback,
        _valueChangedCallback = valueChangedCallback;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (_flag) {
      /// compatible with Xiaomi
      return oldValue;
    }

    /// determine whether to add or delete
    bool isAdding = oldValue.text.length < newValue.text.length;
    if (isAdding && oldValue.selection.start == oldValue.selection.end) {
      /// adding
      if (newValue.text.length - oldValue.text.length == 1 &&
          newValue.text.substring(
              newValue.selection.start - 1, newValue.selection.end) ==
              triggerSymbol) {
        /// the adding char is [triggerSymbol]
        triggerAt(newValue);
      }
    } else {
      /// delete or replace content (include directly delete and select some segment to replace)
      /// 删除或替换内容 （含直接delete、选中后输入别的字符替换）
      return checkRules(oldValue, newValue);
    }
    _valueChangedCallback?.call(rules, newValue.text);
    return newValue;
  }

  /// trigger special callback
  /// 触发[triggerSymbol]操作
  void triggerAt(TextEditingValue newValue) async {
    /// 新值的选中光标的开始位置
    int selStart = newValue.selection.start;
    List<Map<String, dynamic>> params = [];
    for (int i = 0; i < _rules.length; i++) {
      params.add(_rules[i].params);
    }

    /// 调用外部选人回调，返回具体参数
    Map<String, dynamic> retMap = await _triggerAtCallback(params);
    if (retMap != null && retMap.length > 0) {
      if (checkIfRepeat(retMap)) {
        controller.text =
            controller.text.substring(0, controller.text.length - 1);
        _valueChangedCallback?.call(rules, controller.text);
      } else {
        int startIndex = selStart - 1; // 新值的选中光标的后面一个的字符
        String newString;
        String currentText = controller.text;
        if (selStart < currentText.length) {
          /// 如果光标是在原来字符的中间
          newString =
          "${currentText.substring(0, startIndex + 1)}${retMap[showContent]} ${currentText.substring(startIndex + 1, currentText.length)}";
        } else {
          /// 如果光标是在字符串最后面
          newString = "$currentText${retMap[showContent]} ";
        }
        int endIndex = startIndex + (newString.length - currentText.length);
        controller.text = newString;

        /// 改变光标位置
        controller.selection = controller.selection.copyWith(
          baseOffset: endIndex + 1,
          extentOffset: endIndex + 1,
        );
        _rules.add(Rule(startIndex, endIndex, retMap));
        _valueChangedCallback?.call(rules, controller.text);
      }
    }
  }

  /// 检查被删除/替换的内容是否涉及到rules里的特殊segment并处理，另外作字符的处理替换
  TextEditingValue checkRules(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int startIndex = oldValue.selection.start;
    int endIndex = oldValue.selection.end;

    /// 用于迭代的时候不能删除的处理
    List<Rule> delRules = [];
    for (int i = 0; i < _rules.length; i++) {
      Rule rule = _rules[i];
      if ((startIndex >= rule.startIndex + 1 &&
          startIndex <= rule.endIndex + 1) ||
          (endIndex >= rule.startIndex + 1 && endIndex <= rule.endIndex + 1)) {
        /// 原字符串选中的光标范围 与 rule的范围相交，命中
        delRules.add(rule);

        /// 对命中的rule 的边界与原字符串选中的光标边界比较，对原来的选中要被替换/删除的光标界限 进行扩展
        /// 用来自动覆盖@user 的全部字符
        startIndex = math.min(startIndex, rule.startIndex + 1);
        endIndex = math.max(endIndex, rule.endIndex + 1);
      }
    }

    /// 清除掉不需要的rule
    for (int i = 0; i < delRules.length; i++) {
      _rules.remove(delRules[i]);
    }

    /// 对选中部分原字符串，键盘一次输入字符的替换处理，即找出新旧字符串之间的差异部分
    String newStartSelBeforeStr = newValue.text.substring(
        0, newValue.selection.start < 0 ? 0 : newValue.selection.start);
    String oldStartSelBeforeStr =
    oldValue.text.substring(0, oldValue.selection.start);
    String middleStr = "";
    if (newStartSelBeforeStr.length >= oldStartSelBeforeStr.length &&
        (oldValue.selection.end != oldValue.selection.start) &&
        newStartSelBeforeStr.compareTo(oldStartSelBeforeStr) != 0) {
      /// 此时为选中的删除时 有增加新的字符串的情况
      middleStr = newValue.text
          .substring(oldValue.selection.start, newValue.selection.end);
    } else {
      /// 此时为选中的删除时 没有增加新的字符串的情况
    }

    String leftValue =
        "${startIndex == 0 ? "" : oldValue.text.substring(0, startIndex - 1 > oldValue.text.length ? oldValue.text.length : startIndex - 1)}";
    String middleValue = "$middleStr";
    String rightValue =
        "${endIndex == oldValue.text.length ? "" : oldValue.text.substring(endIndex, oldValue.text.length)}";
    String value = "$leftValue$middleValue$rightValue";

    /// 计算最终光标位置
    final TextSelection newSelection = newValue.selection.copyWith(
      baseOffset: leftValue.length + middleValue.length,
      extentOffset: leftValue.length + middleValue.length,
    );

    /// 为了解决小米note的兼容问题
    _flag = true;
    Future.delayed(Duration(milliseconds: 10), () => _flag = false);

    _valueChangedCallback?.call(rules, value);
    return TextEditingValue(
      text: value,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }

  /// 检查此参数是否被添加过 ，用id来鉴别
  bool checkIfRepeat(Map<String, dynamic> retParam) {
    for (int i = 0; i < _rules.length; i++) {
      Rule rule = _rules[i];
      if (rule.params[unique] == retParam[unique]) {
        return true;
      }
    }
    return false;
  }

  void clear() {
    _rules.clear();
  }
}
