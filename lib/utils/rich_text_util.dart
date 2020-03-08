import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef ActionCallback = void Function(Map<String, dynamic> rule);

class RichTextUtil {
  /// 生成带@人的特殊富文本，其他情况通用
  static RichText buildRichText(
      {BuildContext context,
      Map<String, dynamic> paramMap,
      TextStyle markStyle,
      ActionCallback actionCallback}) {
    if (paramMap == null || paramMap.length == 0) {
      return RichText(
        text: TextSpan(text: ""),
      );
    }
    List<TextSpan> children = [];
    String text = paramMap['contentText'];
    List<Map<String, dynamic>> rules = paramMap['rules'];
    rules.sort((left, right) => left['startIndex'] - right['startIndex']);
    int nextStartIndex = 0;
    for (int i = 0; i < rules.length; i++) {
      Map<String, dynamic> rule = rules[i];
      int startIndex = rule['startIndex'];
      int endIndex = rule['endIndex'];
      String colorStr = rule['color'];
      Color color;
      if (colorStr != null && colorStr != "") {
        color = ADColor(colorStr);
      }
//      String router = rule['router'];
      if (startIndex > nextStartIndex) {
        children
            .add(TextSpan(text: text.substring(nextStartIndex, startIndex)));
      }
      children.add(TextSpan(
          text: text.substring(startIndex, endIndex + 1),
          style: markStyle ?? TextStyle(color: color ?? Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => actionCallback?.call(rule)));
      nextStartIndex = endIndex + 1;
    }
    if (nextStartIndex < text.length) {
      /// 后面还有最后一段普通的文本
      children.add(TextSpan(text: text.substring(nextStartIndex, text.length)));
    }

    return RichText(
      text: TextSpan(
          style: TextStyle(fontSize: 18, color: Colors.black),
          children: children),
      textDirection: TextDirection.ltr,
    );
  }

  /// 颜色创建方法
  /// - [colorString] 颜色值
  /// - [alpha] 透明度(默认1，0-1)
  ///
  /// 可以输入多种格式的颜色代码，如: 0x000000,0xff000000,#000000
  static Color ADColor(String colorString, {double alpha = 1.0}) {
    String colorStr = colorString;
    // colorString未带0xff前缀并且长度为6
    if (!colorStr.startsWith('0xff') && colorStr.length == 6) {
      colorStr = '0xff' + colorStr;
    }
    // colorString为8位，如0x000000
    if (colorStr.startsWith('0x') && colorStr.length == 8) {
      colorStr = colorStr.replaceRange(0, 2, '0xff');
    }
    // colorString为7位，如#000000
    if (colorStr.startsWith('#') && colorStr.length == 7) {
      colorStr = colorStr.replaceRange(0, 1, '0xff');
    }
    // 先分别获取色值的RGB通道
    Color color = Color(int.parse(colorStr));
    int red = color.red;
    int green = color.green;
    int blue = color.blue;
    // 通过fromRGBO返回带透明度和RGB值的颜色
    return Color.fromRGBO(red, green, blue, alpha);
  }
}
