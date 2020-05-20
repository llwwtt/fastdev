
import 'package:fastdev/generated/i18n.dart';
import 'package:fastdev/mywidgets/LineWidget.dart';
import 'package:fastdev/net/ApiInterface.dart';
import 'package:fastdev/page/main/MainProvider.dart';
import 'package:fastdev/page/main/MyApp.dart';
import 'package:fastdev/page/user/LoginPage.dart';
import 'package:fastdev/page/user/LoginProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'mywidgets/CircleWidegt.dart';
void main() => runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context)=>LoginInfo("","")),
      ChangeNotifierProvider(create: (context)=>ChatProvider(),)
    ],
      child: MyApp(),),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      showPerformanceOverlay: true,
      //国际化处理
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:LoginMain(),
    );
  }
}

