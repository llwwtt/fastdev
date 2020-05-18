import 'dart:ui';

import 'package:flutter/cupertino.dart';


class LineWidgetPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomPaint(
      painter: LineWidget(),
    );
  }

}

class LineWidget extends CustomPainter{
  Paint _mPaint;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    _mPaint = new Paint();
    _mPaint.color=Color(0xff000000);

//    canvas.drawLine(Offset(10, 10), Offset(250, 250), _mPaint);
//    canvas.drawPoints(PointMode.points, [Offset(10, 10),Offset(20, 50),Offset(500, 50)], _mPaint);
//    canvas.drawPoints(
//        PointMode.polygon,
//        [Offset(200, 200), Offset(250, 250), Offset(50, 200), Offset(100, 250)],
//        _mPaint);
//    Path path =Path();
//    path.moveTo(100, 200);
//    path.lineTo(200, 250);
//    path.lineTo(250, 100);
//    path.lineTo(200, 300);
//    canvas.clipPath(path);
    Rect rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), radius: 140);
    canvas.drawArc(rect, 0, 10, true, _mPaint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}
