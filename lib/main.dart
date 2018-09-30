
import 'package:flutter/material.dart';

import 'dart:core';

import 'characters_selector_page.dart';
import 'font_data.dart';
import 'unicode_data.dart';
import 'mycanvas_page.dart';


/// entry point of this program
void main() {
    runApp(new MyApp());
}


class MyApp extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: '漢字之道具',
            theme: ThemeData(
                primarySwatch: Colors.grey,
            ),
            home: MyHomePage(title: '漢字之道具'),
            // ほゞ つかはず
            //localizationsDelegates: [
            //    GlobalMaterialLocalizations.delegate,
            //    GlobalWidgetsLocalizations.delegate,
            //],
            // ほゞ つかはず
            //supportedLocales: [
            //    Locale('ja', 'JP'),
            //    Locale('zh', 'CN'),
            //    Locale('zh', 'TW'),
            //    Locale('ko', 'KR'),
            //],
        );
    }
}


class MyHomePage extends StatefulWidget {

    final String title;

    MyHomePage({Key key, this.title}) : super(key: key) {
        // do nothing
    }

    @override
    _MyHomePageState createState() {
        return new _MyHomePageState();
    }
}


class _MyHomePageState extends State<MyHomePage> {

    UnicodeData _unicodeData;
    FontData _fontData;

    @override
    Widget build(BuildContext context) {

        _unicodeData = new UnicodeData(context);
        _fontData = new FontData(context);

        return Scaffold(

            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.info/*menu*/, size: 36.0,),
                    tooltip: 'test',
                    onPressed: () {
                        // TODO
                        // for test of hand-writing
                        Navigator.push(
                            this.context,
                            MaterialPageRoute<Null>(
                                settings: RouteSettings(name: '/mycanvas_page',),
                                builder: (BuildContext context) {
                                    return new MyCanvasPage();
                                },
                            )
                        );
                    },
                ),
                title: Text(
                    widget.title,
                    style: TextStyle(
                        fontFamily: FontData.getCJKNormalFontFamily(),
                    ),
                ),
                centerTitle: true,
            ),

            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                            '漢字之蟲',
                            style: TextStyle(fontFamily: FontData.getCJKNormalFontFamily()),
                            textScaleFactor: 3.0,
                        ),
                        Text(
                            '蒼頡 ＼(^o^)／',
                            style: TextStyle(fontFamily: FontData.getCJKNormalFontFamily()),
                            textScaleFactor: 2.0,
                        ),
                        OutlineButton(
                            child: Text(
                                FontData.getCurrentLocaleSymbol(),
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                    fontFamily: FontData.getCJKNormalFontFamily(),
                                ),
                            ),
                            onPressed: () {
                                setState(() {
                                    FontData.switchNextLocale();
                                });
                            },
                        )
                    ],
                ),
            ),

            floatingActionButton: FloatingActionButton(
                onPressed: _gotoNextPage,
                tooltip: 'goto main page',
                child: Icon(Icons.arrow_forward, size: 36.0,),
            ),
        );
    }

    void _gotoNextPage() {
        setState(() {
            // TODO ?
        });
        Navigator.push(
            this.context,
            MaterialPageRoute<Null>(
                settings: RouteSettings(name: '/select_characters',),
                builder: (BuildContext context) {
                    return CharactersSelectorPage(title: widget.title, unicodeData: _unicodeData, fontData: _fontData);
                },
            )
        );
    }
}
