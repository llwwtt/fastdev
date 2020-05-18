import 'dart:math';

import 'package:flutter/material.dart';
class PieData{
  String name;// 名称
  Color color;// 颜色
  num percentage;//百分比
  var price;//成交额

}
class CircleView extends CustomPainter{
  //中间文字
  var text='111';
  bool isChange=false;
  //当前选中的扇形
  var currentSelect=0;
  //画笔
  Paint _mPaint;
  Paint TextPaint;
  // 扇形大小
  int mWidth, mHeight;
  // 圆半径
  num mRadius, mInnerRadius,mBigRadius;
  // 扇形起始弧度（Andorid中是角度）
  num mStartAngle = 0;
  // 矩形（扇形绘制的区域）
  Rect mOval,mBigOval;
// 扇形 数据
  List<PieData> mData;
  PieData pieData;
  CircleView(this.mData,this.pieData,this.currentSelect,this.isChange);
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    // 初始化各类工具等
    _mPaint = new Paint();
    TextPaint = new Paint();
    mHeight=100;mWidth=100;

    /// 生成纵轴文字的TextPainter
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    // 文字画笔 风格定义
    TextPainter _newVerticalAxisTextPainter(String text) {
      return textPainter
        ..text = TextSpan(
          text: text,
          style: new TextStyle(
            color: Colors.black,
            fontSize: 10.0,
          ),
        );
    }

    // 正常半径
    mRadius = 50.0;
    //加大半径  用来绘制被选中的扇形区域
    mBigRadius=55.0;
    //內园半径
    mInnerRadius = mRadius * 0.50;
    // 未选中的扇形绘制的矩形区域
    mOval = Rect.fromLTRB(-mRadius, -mRadius, mRadius, mRadius);
    // 选中的扇形绘制的矩形区域
    mBigOval = Rect.fromLTRB(-mBigRadius, -mBigRadius, mBigRadius,
        mBigRadius);
    //当没有数据时 直接返回
    if (mData.length == null || mData.length <= 0) {
      return;
    }

    ///绘制逻辑与Android差不多
    canvas.save();
    // 将坐标点移动到View的中心
    canvas.translate(50.0, 50.0);
    // 1. 画扇形
    num startAngle = 0.0;
    for (int i = 0; i < mData.length; i++) {
      PieData p = mData[i];
      double hudu=p.percentage;
      //计算当前偏移量（单位为弧度）
      double sweepAngle = 2*pi*hudu;
      //画笔的颜色
      _mPaint..color = p.color;
      if(currentSelect>=0 && i==currentSelect){
        //如果当前为所选中的扇形 则将其半径加大  突出显示
        canvas.drawArc(mBigOval, startAngle, sweepAngle, true, _mPaint);
      }else{
        // 绘制没被选中的扇形  正常半径
        canvas.drawArc(mOval, startAngle, sweepAngle, true, _mPaint);
      }
      //计算每次开始绘制的弧度
      startAngle += sweepAngle ;
    }

//    canvas.drawRect(mOval, _mPaint);  // 矩形区域

    // 2.画内圆
    _mPaint..color = Colors.white;
    canvas.drawCircle(Offset.zero, mInnerRadius, _mPaint);

    canvas.restore();

    //当前百分比值
    double percentage = pieData.percentage*100;
    // 绘制文字内容
    var texts ='${percentage}%';
    var tp = _newVerticalAxisTextPainter(texts)..layout();

    // Text的绘制起始点 = 可用宽度 - 文字宽度 - 左边距
    var textLeft = 35.0;
    tp.paint(canvas, Offset(textLeft, 50.0 - tp.height / 2));



  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}