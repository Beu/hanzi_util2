
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'character_selector_page.dart';
import 'font_data.dart';
import 'unicode_data.dart';
import 'util.dart';


UnicodeData _unicodeData;
FontData _fontData;

class CharactersSelectorPage extends StatefulWidget {

    final String title;

    CharactersSelectorPage({Key key, this.title, UnicodeData unicodeData, FontData fontData}) : super(key: key) {
        // do nothing
        _unicodeData = unicodeData;
        _fontData = fontData;
    }

    @override
    _CharactersSelectorPageState createState() {
        return new _CharactersSelectorPageState();
    }
}


class _CharactersSelectorPageState extends State<CharactersSelectorPage> with SingleTickerProviderStateMixin {

    final List<Tab> tabList = <Tab>[
        Tab(
            key: Key('tab_block'),
            text: 'Unicode block',
            icon: Icon(Icons.dashboard),
        ),
        Tab(
            key: Key('tab_unicode_radical'),
            text: 'Unicode 部首',
            icon: Icon(Icons.library_books),
        ),
        Tab(
            key: Key('tab_kangxi_radical'),
            text: '康熙字典 部首',
            icon: Icon(Icons.library_books)
        ),
        Tab(
            key: Key('tab_form'),
            text: 'form search',
            icon: Icon(Icons.search)
        ),
        Tab(
            key: Key('tab_calc'),
            text: 'à la carte',
            icon: Icon(Icons.computer)
        ),
    ];

    TabController _tabController;

    TextEditingController _textEditingController = TextEditingController();
    TextEditingController _partsEditingController = TextEditingController();
    TextEditingController _readingEditingController = TextEditingController();

    TextEditingController _characterUnicodeFormController = TextEditingController();
    TextEditingController _characterUnicodeController = TextEditingController();
    TextEditingController _utf8UnicodeFormController = TextEditingController();
    TextEditingController _utf8UnicodeController = TextEditingController();
    TextEditingController _unicodeUtfFormController = TextEditingController();
    TextEditingController _unicodeUtf16Controller = TextEditingController();
    TextEditingController _unicodeUtf8Controller = TextEditingController();
    TextEditingController _unicodeController = TextEditingController();

    String _cjkNormalFontFamily = FontData.getCJKNormalFontFamily();
    String _monospaceFontFamily = FontData.getMonospaceFontFamily();

    @override
    void initState() {
        super.initState();
        _tabController = TabController(vsync: this, length: tabList.length);
        CircularProgressIndicator();
    }

    @override
    void dispose() {
        _tabController.dispose();

        _textEditingController.dispose();
        _partsEditingController.dispose();
        _readingEditingController.dispose();

        _characterUnicodeFormController.dispose();
        _characterUnicodeController.dispose();
        _utf8UnicodeFormController.dispose();
        _utf8UnicodeController.dispose();
        _unicodeUtfFormController.dispose();
        _unicodeUtf16Controller.dispose();
        _unicodeUtf8Controller.dispose();
        _unicodeController.dispose();

        super.dispose();
    }

    @override
    Widget build(BuildContext context) {

        return Scaffold(

            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back, size: 36.0),
                    tooltip: 'back',
                    onPressed: _gotoPreviousPage,
                ),
                title: Text(
                    widget.title,
                    style: TextStyle(fontFamily: _cjkNormalFontFamily),
                ),
                centerTitle: true,
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.settings, size: 36.0),
                        tooltip: 'settings',
                        onPressed: () {
                            // TODO
                            Util.showNotSupported(context);
                        },
                    ),
                ],
                bottom: TabBar(
                    tabs: tabList,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                    unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 18.0),
                    controller: _tabController,
                    isScrollable: true,
                ),
            ),

            body: TabBarView(
                controller: _tabController,
                children: tabList.map((Tab tab) {
                    if (tab.key == Key('tab_unicode_radical')) {

                        return buildUnicodeRadicalView();

                    } else if (tab.key == Key('tab_kangxi_radical')) {

                        return buildKangxiRadicalView();

                    } else if (tab.key == Key('tab_block')) {

                        return buildBlockView();

                    } else if (tab.key == Key('tab_form')) {

                        return buildFormView();

                    } else if (tab.key == Key('tab_calc')) {

                        return buildCalcView();

                    } else {

                        return Center(
                            child: Text('What?'),
                        );

                    }
                }).toList(),
            ),
        );
    }

    /// Unicode 部首

    Widget buildUnicodeRadicalView() {
        Future<Map<int, List<RadicalInfo>>> radicalInfoListWithStrokesFuture = _unicodeData.getUnicodeRadicalInfoListWithStrokesFuture();
        return FutureBuilder(
            future: radicalInfoListWithStrokesFuture,
            builder: (BuildContext context, AsyncSnapshot<Map<int, List<RadicalInfo>>> snapshot) {
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                Map<int, List<RadicalInfo>> radicalInfoListMap = snapshot.data;
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: radicalInfoListMap.length,
                    itemBuilder: (BuildContext context, int index) {
                        int strokes = index + 1;
                        return Card(
                            margin: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                            child: Wrap(
                                spacing: 4.0,
                                children: <Widget>[
                                    Row(
                                        children: <Widget>[
                                            Text(
                                                strokes.toString() + ' 畫',
                                                textScaleFactor: 1.5,
                                            ),
                                        ],
                                    ),
                                ]
                                + radicalInfoListMap[strokes].map((RadicalInfo radicalInfo) {
                                    return OutlineButton(
                                        child: Text(
                                            String.fromCharCodes([radicalInfo.codePoint]),
                                            style: TextStyle(
                                                fontFamily: _cjkNormalFontFamily,
                                                color: radicalInfo.simplified ? Colors.red : Colors.black,
                                            ),
                                            textScaleFactor: 2.0,
                                        ),
                                        onPressed: () {
                                            _gotoNextPage(radicalInfo: radicalInfo, simplified: true);
                                        },
                                    );
                                })
                                .toList(),
                            ),
                        );
                    },
                );
            },
        );
    }

    /// 康熙字典 部首

    Widget buildKangxiRadicalView() {
        Future<Map<int, List<RadicalInfo>>> radicalInfoListWithStrokesFuture = _unicodeData.getKangxiRadicalInfoListWithStrokesFuture();
        return FutureBuilder(
            future: radicalInfoListWithStrokesFuture,
            builder: (BuildContext context, AsyncSnapshot<Map<int, List<RadicalInfo>>> snapshot) {
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                Map<int, List<RadicalInfo>> radicalInfoListMap = snapshot.data;
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: radicalInfoListMap.length,
                    itemBuilder: (BuildContext context, int index) {
                        int strokes = index + 1;
                        return Card(
                            margin: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                            child: Wrap(
                                spacing: 4.0,
                                children: <Widget>[
                                    Row(
                                        children: <Widget>[
                                            Text(
                                                strokes.toString() + ' 畫',
                                                textScaleFactor: 1.5,
                                            )
                                        ],
                                    ),
                                ]
                                + radicalInfoListMap[strokes].map((RadicalInfo radicalInfo) {
                                    return OutlineButton(
                                        child: Text(
                                            String.fromCharCodes([radicalInfo.codePoint]),
                                            style: TextStyle(
                                                fontFamily: _cjkNormalFontFamily,
                                            ),
                                            textScaleFactor: 2.0,
                                        ),
                                        onPressed: () {
                                            _gotoNextPage(radicalInfo: radicalInfo, simplified: false);
                                        },
                                    );
                                })
                                .toList(),
                            ),
                        );
                    },
                );
            },
        );
    }

    /// Unicode block

    Widget buildBlockView() {
        Future<List<BlockInfo>> blockInfoListFuture = _unicodeData.getCJKUIBlockInfoListFuture();
        return FutureBuilder(
            future: blockInfoListFuture,
            builder: (BuildContext context, AsyncSnapshot<List<BlockInfo>> snapshot) {
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                List<BlockInfo> blockInfoList = snapshot.data;

                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: blockInfoList.length,
                    itemBuilder: (BuildContext context, int index) {
                        BlockInfo blockInfo = blockInfoList[index];
                        List<BlockInfo> subBlockInfoList = List<BlockInfo>();
                        int first0 = blockInfo.first;
                        int last0 = blockInfo.last;
                        for (int first = first0;  first <= last0;  ) {
                            int last = min((first & ~0x03ff) + 0x03ff, last0);
                            if ((first & 0x0fff) == 0) {
                                BlockInfo subBlockInfo = new BlockInfo()
                                    ..first = -1
                                    ..last = -1;
                                subBlockInfoList.add(subBlockInfo);
                            }
                            BlockInfo subBlockInfo = new BlockInfo()
                                ..first = first
                                ..last = last
                                ..name = "";  // dummy
                            subBlockInfoList.add(subBlockInfo);
                            first = last + 1;
                        }

                        return Card(
                            margin: EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                            child: Wrap(
                                spacing: 8.0,
                                children: <Widget>[
                                    Row(
                                        children: <Widget>[
                                            Text(
                                                blockInfoList[index].name,
                                                textScaleFactor: 1.5,
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                        ],
                                    ),
                                ]
                                + subBlockInfoList.map((BlockInfo subBlockInfo) {
                                    if (subBlockInfo.first == -1) {
                                        return Row();
                                    }
                                    return OutlineButton(
                                        padding: EdgeInsets.all(4.0),
                                        child: Text(
                                            'U+' + subBlockInfo.first.toRadixString(16).toUpperCase() + '..U+' + subBlockInfo.last.toRadixString(16).toUpperCase(),
                                            textScaleFactor: 1.5,
                                            style: TextStyle(fontFamily: _monospaceFontFamily),
                                        ),
                                        onPressed: () {
                                            _gotoNextPage(blockInfo: subBlockInfo);
                                        },
                                    );
                                }).toList(),
                            ),
                        );
                    },
                );
            },
        );
    }

    /// form search

    Widget buildFormView() {

        final TextFormField textFormField = TextFormField(
            controller: _textEditingController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'text here',
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.all(8.0),
            ),
            style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontFamily: _cjkNormalFontFamily,
            ),
            textCapitalization: TextCapitalization.none,
        );

        final TextFormField partsFormField = TextFormField(
            controller: _partsEditingController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'parts here',
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.all(8.0),
            ),
            style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontFamily: _cjkNormalFontFamily,
            ),
            textCapitalization: TextCapitalization.none,
        );

        final TextFormField readingFormField = TextFormField(
            controller: _readingEditingController,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'reading here',
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.all(8.0),
            ),
            style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontFamily: _cjkNormalFontFamily,
            ),
            textCapitalization: TextCapitalization.none,
        );

        return ListView(
            children: <Widget>[
                Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                        children: <Widget>[
                            Column(
                                children: <Widget>[
                                    Text(
                                        '漢字 text',
                                        textScaleFactor: 1.75,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: _cjkNormalFontFamily),
                                    ),
                                    Text(
                                        '(ex. 適當漢字群)',
                                        style: TextStyle(fontFamily: _cjkNormalFontFamily),
                                    ),
                                ],
                            ),
                            textFormField,
                            ButtonBar(
                                children: <Widget>[
                                    OutlineButton(
                                        child: Row(
                                            children: <Widget>[
                                                Icon(Icons.clear),
                                                Text('clear'),
                                            ],
                                        ),
                                        onPressed: () {
                                            _textEditingController.clear();
                                        },
                                    ),
                                    OutlineButton(
                                        child: Row(
                                            children: <Widget>[
                                                Icon(Icons.search),
                                                Text('search'),
                                            ],
                                        ),
                                        onPressed: () {
                                            String text = _textEditingController.text.trim();
                                            _textEditingController.text = text;
                                            if (text.isEmpty) {
                                                Util.showErrorDialog(context, "Empty!!!");
                                                return;
                                            }
                                            Future<bool> validFuture = _checkText(text);
                                            validFuture.then((bool valid) {
                                                if (valid) {
                                                    _unicodeData.getVariantCodePointListFuture(text)
                                                            .then((String newText) {
                                                                _gotoNextPage(text: newText);
                                                            });
//                                                    _gotoNextPage(text: text);
                                                } else {
                                                    Util.showErrorDialog(context, "Invalid text: " + text);
                                                }
                                            });
                                        },
                                    ),
                                ],
                            ),
                        ],
                    ),
                ),

                Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                        children: <Widget>[
                            Column(
                                children: <Widget>[
                                    Text(
                                        '漢字 parts',
                                        textScaleFactor: 1.75,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: _cjkNormalFontFamily),
                                    ),
                                    Text(
                                        '(ex. 隹又)',
                                        style: TextStyle(fontFamily: _cjkNormalFontFamily),
                                    ),
                                ],
                            ),
                            partsFormField,
                            ButtonBar(
                                children: <Widget>[
                                    OutlineButton(
                                        child: Row(
                                            children: <Widget>[
                                                Icon(Icons.clear),
                                                Text('clear'),
                                            ],
                                        ),
                                        onPressed: () {
                                            _partsEditingController.clear();
                                        },
                                    ),
                                    OutlineButton(
                                        child: Row(
                                            children: <Widget>[
                                                Icon(Icons.search),
                                                Text('search'),
                                            ],
                                        ),
                                        onPressed: () {
                                            String text = _partsEditingController.text.trim();
                                            _partsEditingController.text = text;
                                            if (text.isEmpty) {
                                                Util.showErrorDialog(context, "Empty!!!");
                                                return;
                                            }
                                            Future<bool> validFuture = _checkText(text);
                                            validFuture.then((bool valid) {
                                                //if (valid) {
                                                //    _gotoNextPage(parts: text);
                                                //}
                                                // TODO
                                                Util.showNotSupported(context);
                                            });
                                        },
                                    ),
                                ],
                            ),
                        ],
                    ),
                ),

                Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                        children: <Widget>[
                            Column(
                                children: <Widget>[
                                    Text(
                                        '漢字音',
                                        textScaleFactor: 1.75,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: _cjkNormalFontFamily),
                                    ),
                                    Text(
                                        '(ex. jīn,jin1,jin,ㄐㄧㄣ,gam1,kim,キン,コン,김)',
                                        style: TextStyle(fontFamily: _cjkNormalFontFamily),
                                    ),
                                ],
                            ),
                            readingFormField,
                            ButtonBar(
                                children: <Widget>[
                                    OutlineButton(
                                        child: Row(
                                            children: <Widget>[
                                                Icon(Icons.clear),
                                                Text('clear'),
                                            ],
                                        ),
                                        onPressed: () {
                                            _readingEditingController.clear();
                                        },
                                    ),
                                    OutlineButton(
                                        child: Row(
                                            children: <Widget>[
                                                Icon(Icons.search),
                                                Text('search'),
                                            ],
                                        ),
                                        onPressed: () {
                                            String reading = _readingEditingController.text.trim().toLowerCase();
                                            _readingEditingController.text = reading;
                                            if (reading.isEmpty) {
                                                Util.showErrorDialog(context, "Empty!!");
                                                return;
                                            }
                                            //_gotoNextPage(reading: _readingEditingController.text);
                                            // TODO
                                            Util.showNotSupported(context);
                                        },
                                    ),
                                ],
                            ),
                        ],
                    ),
                ),

            ],
        );
    }

    /// à la carte

    Widget buildCalcView() {

        return ListView(
            children: <Widget>[

                // 漢字 -> Unicode

                Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                        children: <Widget>[
                            Text(
                                '漢字 → Unicode',
                                textScaleFactor: 1.75,
                                style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextFormField(
                                controller: _characterUnicodeFormController,
                                style: TextStyle(
                                    fontFamily: _cjkNormalFontFamily,
                                    fontSize: 24.0,
                                    color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: '漢字 here!',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(8.0),
                                ),
                                textCapitalization: TextCapitalization.none,
                            ),
                            OutlineButton(
                                child: Icon(Icons.arrow_downward),
                                onPressed: () {
                                    String text = _characterUnicodeFormController.text.trim();
                                    _characterUnicodeFormController.text = text;
                                    _characterUnicodeController.clear();
                                    if (text.isEmpty) {
                                        Util.showErrorDialog(context, "Empty!!!");
                                        return;
                                    }
                                    String unicode = text.runes
                                            .map((int codePoint) => 'U+' + codePoint.toRadixString(16).toUpperCase())
                                            .join(' ');
                                    _characterUnicodeController.text = unicode;
                                },
                            ),
                            TextField(
                                controller: _characterUnicodeController,
                                enabled: true,
                                style: TextStyle(
                                    fontFamily: _monospaceFontFamily,
                                    fontSize: 24.0,
                                    color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Unicode',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(8.0),
                                ),
                            ),
                        ],
                    ),
                ),

                // Unicode -> UTF-16, UTF-8

                Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                        children: <Widget>[
                            Text(
                                'Unicode → UTF-16, UTF-8',
                                textScaleFactor: 1.75,
                                style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextFormField(
                                controller: _unicodeUtfFormController,
                                style: TextStyle(
                                    fontFamily: _monospaceFontFamily,
                                    fontSize: 24.0,
                                    color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: '20000',
                                    hintStyle: TextStyle(
                                        fontFamily: _monospaceFontFamily,
                                        fontSize: 24.0,
                                        color: Colors.grey
                                    ),
                                    prefixText: 'U+',
                                    prefixStyle: TextStyle(
                                        fontFamily: _monospaceFontFamily,
                                        fontSize: 24.0,
                                        color: Colors.grey
                                    ),
                                    contentPadding: EdgeInsets.all(8.0),
                                ),
                            ),
                            OutlineButton(
                                child: Icon(Icons.arrow_downward),
                                onPressed: () {
                                    RegExp regExp = RegExp(r"^([0-9A-F]+)$");
                                    String text = _unicodeUtfFormController.text.trim().toUpperCase();
                                    _unicodeUtfFormController.text = text;
                                    _unicodeUtf16Controller.clear();
                                    _unicodeUtf8Controller.clear();
                                    if (text.isEmpty) {
                                        Util.showErrorDialog(context, "Empty!!!");
                                        return;
                                    }
                                    if (!regExp.hasMatch(text)) {
                                        Util.showErrorDialog(context, "Invalid input: " + text);
                                        return;
                                    }
                                    int codepoint = int.parse(regExp.firstMatch(text).group(1), radix: 16);
                                    _unicodeUtf16Controller.text = Util.codePointToUtf16(codepoint)
                                            .map((int code) => 'U+' + code.toRadixString(16))
                                            .join(" ").toUpperCase();
                                    _unicodeUtf8Controller.text = Util.codePointToUtf8(codepoint)
                                            .map((int code) => code.toRadixString(16))
                                            .map((String s) => s.padLeft(2, "0"))
                                            .join(" ").toUpperCase();
                                    _unicodeController.text = String.fromCharCode(codepoint);
                                },
                            ),
                            TextField(
                                controller: _unicodeUtf16Controller,
                                enabled: true,
                                style: TextStyle(
                                    fontFamily: _monospaceFontFamily,
                                    fontSize: 24.0,
                                    color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'UTF-16',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(8.0),
                                ),
                            ),
                            TextField(
                                controller: _unicodeUtf8Controller,
                                enabled: true,
                                style: TextStyle(
                                    fontFamily: _monospaceFontFamily,
                                    fontSize: 24.0,
                                    color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'UTF-8',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(8.0),
                                ),
                            ),
                            TextField(
                                controller: _unicodeController,
                                enabled: true,
                                style: TextStyle(
                                    fontFamily: _cjkNormalFontFamily,
                                    fontSize: 24.0,
                                    color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: '漢字',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(8.0),
                                ),
                            ),
                        ],
                    ),
                ),

                // UTF-8 -> Unicode

                Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                        children: <Widget>[
                            Text(
                                'UTF-8 → Unicode',
                                textScaleFactor: 1.75,
                                style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextFormField(
                                controller: _utf8UnicodeFormController,
                                style: TextStyle(
                                    fontFamily: _monospaceFontFamily,
                                    fontSize: 24.0,
                                    color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'F0 AC BB BC',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(8.0),
                                ),
                                textCapitalization: TextCapitalization.none,
                            ),
                            OutlineButton(
                                child: Icon(Icons.arrow_downward),
                                onPressed: () {
                                    String text = _utf8UnicodeFormController.text.toUpperCase().trim();
                                    _utf8UnicodeFormController.text = text;
                                    _utf8UnicodeController.clear();
                                    if (text.isEmpty) {
                                        Util.showErrorDialog(context, "Empty!!!");
                                        return;
                                    }
                                    RegExp regExp = RegExp(r"^( ?[0-9A-F][0-9A-F])+$");
                                    // 巧く group の 値 取れず。 Java などとは 異なるか？
                                    // 或いは bug に あらずや。
                                    if (!regExp.hasMatch(text)) {
                                        Util.showErrorDialog(context, "Invalid input: " + text);
                                        return;
                                    }
                                    text = regExp.firstMatch(text).group(0).replaceAll(' ', '');
                                    List<int> octetList = [];
                                    for (int i = 0, iMax = text.length;  i < iMax;  i += 2) {
                                        octetList.add(int.parse(text.substring(i, i + 2), radix: 16));
                                    }
                                    int codePoint = Util.codePointFromUtf8(octetList);
                                    if (codePoint <= 0) {
                                        Util.showErrorDialog(context, "Invalid input2: " + text);
                                        return;
                                    }
                                    _utf8UnicodeController.text = ('U+' + codePoint.toRadixString(16).toUpperCase());
                                },
                            ),
                            TextField(
                                controller: _utf8UnicodeController,
                                enabled: true,  // これなくば GestureDetector 效かず
                                style: TextStyle(
                                    fontFamily: _monospaceFontFamily,
                                    fontSize: 24.0,
                                    color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Unicode',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    contentPadding: EdgeInsets.all(8.0),
                                ),
                            ),
                        ],
                    ),
                ),

            ],
        );
    }

    void _gotoPreviousPage() {
        Navigator.pop(context);
    }


    Future<bool> _checkText(String text) async {
        text = text.trim();
        if (text.isEmpty) {
            await Util.showErrorDialog(context, 'empty!!!');
            return false;
        }
        List<BlockInfo> blockInfoList = await _unicodeData.getCJKUIBlockInfoListFuture();
        String invalidCharacters = text.runes.toList()
                .map((int codePoint) {
                    for (BlockInfo blockInfo in blockInfoList) {
                        if (codePoint >= blockInfo.first && codePoint <= blockInfo.last) {
                            return '';
                        }
                    }
                    return String.fromCharCodes([codePoint]);
                })
                .join();
        if (invalidCharacters.isNotEmpty) {
            await Util.showErrorDialog(context, 'invalid characters: ' + invalidCharacters);
            return false;
        }
        return true;
    }


    void _gotoNextPage({RadicalInfo radicalInfo, bool simplified, BlockInfo blockInfo, String text, String parts, String reading, String code}) {
        setState(() {
            // TODO ?
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                settings: RouteSettings(name: '/select_character',),
                builder: (BuildContext context) {
                    return CharacterSelectorPage(radicalInfo: radicalInfo, simplified: simplified, blockInfo: blockInfo, text: text, parts: parts, reading: reading, unicodeData: _unicodeData, fontData: _fontData);
                },
            )
        );
    }
}
