
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'font_data.dart';
import 'unicode_data.dart';
import 'util.dart';


UnicodeData _unicodeData;
FontData _fontData;

class CharacterSelectorPage extends StatefulWidget {

    final String title;
    final RadicalInfo radicalInfo;
    final bool simplified;
    final BlockInfo blockInfo;
    final String text;
    final String parts;
    final String reading;

    CharacterSelectorPage({Key key, this.title, this.radicalInfo, this.simplified, this.blockInfo, this.text, this.parts, this.reading, UnicodeData unicodeData, FontData fontData}) : super(key: key) {
        // do nothing
        // はじめより 分つが よろしく おぼゆ。 とりあへずは この source にて
        _unicodeData = unicodeData;
        _fontData = fontData;
    }

    @override
    _CharacterSelectorPageState createState() {
        if (radicalInfo != null) {
            print(radicalInfo);
        } else if (blockInfo != null) {
            print(blockInfo);
        } else if (text != null) {
            print(text);
        } else if (parts != null) {
            print(parts);
        } else if (reading != null) {
            print(reading);
        }
        return new _CharacterSelectorPageState(radicalInfo, simplified, blockInfo, text, parts, reading);
    }
}


class _CharacterSelectorPageState extends State<CharacterSelectorPage> {

    final RadicalInfo radicalInfo;
    final bool simplified;
    final BlockInfo blockInfo;
    final String text;
    final String parts;
    final String reading;

    String _monospaceFontFamily = FontData.getMonospaceFontFamily();
    String _cjkNormalFontFamily = FontData.getCJKNormalFontFamily();

    _CharacterSelectorPageState(this.radicalInfo, this.simplified, this.blockInfo, this.text, this.parts, this.reading) {
        // do nothing
    }

    @override
    void initState() {
        super.initState();
    }

    @override
    void dispose() {
        super.dispose();
    }

    UnicodeData _unicodeData;

    @override
    Widget build(BuildContext context) {

        _unicodeData = new UnicodeData(context);

        AppBar _appBar = AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back, size: 36.0,),
                tooltip: 'back',
                onPressed: _onBack,
            ),
            title: Text(
                '漢字之道具',
                style: TextStyle(fontFamily: _cjkNormalFontFamily),
            ),
            centerTitle: true,
            actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.settings, size: 36.0,),
                    tooltip: 'settings',
                    onPressed: () {
                        // TODO
                        Util.showNotSupported(context);
                    },
                ),
            ],
        );

        return Scaffold(

            appBar: _appBar,

            body: (radicalInfo != null) ? _buildRadicalInfoListView(radicalInfo, simplified)
                : (blockInfo != null) ? _buildBlockInfoListView(blockInfo)
                : (text != null) ? _buildTextListView(text)
                : (parts != null) ? _buildPartsListView(parts)
                : (reading != null) ? _buildReadingListView(reading)
                : new ListView(),

        );
    }

    /// Unicode 部首, 康熙字典 部首

    Widget _buildRadicalInfoListView(RadicalInfo radicalInfo, bool simplified) {
        Future<Map<int, List<CharacterInfo>>> characterInfoListMapFuture;
        if (simplified) {
            characterInfoListMapFuture = _unicodeData.getUnicodeCharacterInfoListMapWithRadicalFuture(radicalInfo);
        } else {
            characterInfoListMapFuture = _unicodeData.getKangxiCharacterInfoListMapWithRadicalFuture(radicalInfo);
        }

        return FutureBuilder(
            future: characterInfoListMapFuture,
            builder: (BuildContext context, AsyncSnapshot<Map<int, List<CharacterInfo>>> snapshot) {
                if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                }
                Map<int, List<CharacterInfo>> characterInfoListMap = snapshot.data;

                return ListView(
                    children: <Widget>[
                        Padding(
                            child: Card(
                                child: Text(
                                    '部首: ' + String.fromCharCodes([radicalInfo.codePoint]),
                                    textScaleFactor: 1.75,
                                    style: TextStyle(fontFamily: FontData.getCJKNormalFontFamily()),
                                ),
                            ),
                            padding: EdgeInsets.all(4.0),
                        )
                    ] + characterInfoListMap.keys.map((int strokes) {
                        List<CharacterInfo> characterInfoList = characterInfoListMap[strokes];
                        return Card(
                            margin: EdgeInsets.all(8.0),
                            child: Wrap(
                                children: <Widget>[
                                    Row(
                                        children: <Widget>[
                                            Text(
                                                strokes.toString() + ' 畫',
                                                textScaleFactor: 1.5,
                                                style: TextStyle(fontFamily: FontData.getCJKNormalFontFamily()),
                                            ),
                                        ],
                                    ),
                                    Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.end,
                                        children: characterInfoList.map((CharacterInfo characterInfo) {
                                            return OutlineButton(
                                                padding: EdgeInsets.all(4.0),
                                                child: Column(
                                                    children: <Widget>[
                                                        Padding(
                                                            child: FutureBuilder(
                                                                future: FontData.getFontFamilyFuture(context, characterInfo.codePoint),
                                                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                                                    if (!snapshot.hasData) {
                                                                        return CircularProgressIndicator();
                                                                    }
                                                                    return Text(
                                                                        String.fromCharCodes([characterInfo.codePoint]),
                                                                        textScaleFactor: 4.0,
                                                                        style: TextStyle(fontFamily: snapshot.data)
                                                                    );
                                                                }
                                                            ),
                                                            padding: EdgeInsets.all(4.0),
                                                        ),
                                                        Text(
                                                            'U+' + characterInfo.codePoint.toRadixString(16).toUpperCase(),
                                                            style: TextStyle(fontFamily: _monospaceFontFamily),
                                                        ),
                                                    ]
                                                ),
                                                onPressed: () {
                                                    // TODO
                                                }
                                            );
                                        }).toList()
                                    )
                                ]
                            )
                        );
                    }).toList()
                );
            }
        );
    }

    /// Unicode Block

    Widget _buildBlockInfoListView(BlockInfo blockInfo) {
        return ListView(
            children: <Widget>[
                Padding(
                    child: Card(
                        child: Text(
                            '範圍: U+' + blockInfo.first.toRadixString(16).toUpperCase() + ' - U+' + blockInfo.last.toRadixString(16).toUpperCase(),
                            textScaleFactor: 1.75,
                        ),
                    ),
                    padding: EdgeInsets.all(4.0),
                ),
            ]
            + (() {
                int first0 = blockInfo.first;
                int last0 = blockInfo.last;
                List<BlockInfo> subBlockInfoList = <BlockInfo>[];
                for (int first = max(first0 & ~0xff, first0);  first <= last0;  ) {
                    int last = min((first & ~0xff) + 0xff, last0);
                    BlockInfo subBlockInfo = new BlockInfo()
                        ..first = first
                        ..last = last
                        ..name = "";  // dummy
                    subBlockInfoList.add(subBlockInfo);
                    first = last + 1;
                }
                return subBlockInfoList;
            })().map((BlockInfo subBlockInfo) {
                return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: (() {
                            List<int> codePointList = <int>[];
                            for (int codePoint = subBlockInfo.first;  codePoint <= subBlockInfo.last;  ++codePoint) {
                                if ((codePoint & 0x0f) == 0) {
                                    codePointList.add(-1);
                                }
                                codePointList.add(codePoint);
                            }
                            return codePointList;
                        })().map((int codePoint) {
                            if (codePoint == -1) {
                                return Row();
                            }
                            return OutlineButton(
                                padding: EdgeInsets.all(4.0,),
                                child: Column(
                                    children: <Widget>[
                                        Padding(
                                            child: FutureBuilder(
                                                future: FontData.getFontFamilyFuture(context, codePoint),
                                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                                    if (!snapshot.hasData) {
                                                        return CircularProgressIndicator();
                                                    }
                                                    return Text(
                                                        String.fromCharCodes([codePoint]),
                                                        textScaleFactor: 4.0,
                                                        style: TextStyle(fontFamily: snapshot.data,),
                                                    );
                                                },
                                            ),
                                            padding: EdgeInsets.all(4.0),
                                        ),
                                        Text(
                                            'U+' + codePoint.toRadixString(16).toUpperCase(),
                                            style: TextStyle(fontFamily: _monospaceFontFamily,),
                                        ),
                                    ],
                                ),
                                onPressed: () {
                                    // TODO
                                    print("U+${codePoint.toRadixString(16).toUpperCase()}");
                                },
                            );
                        }).toList(),
                    ),
                );
            }).toList(),
        );
    }

    /// Form Search (漢字 text)

    Widget _buildTextListView(String text) {
        // TODO
        return ListView(
            padding: EdgeInsets.all(4.0),
            children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Card(
                        child: Text(
                            'text: ' + text,
                            textScaleFactor: 1.75,
                            style: TextStyle(fontFamily: _cjkNormalFontFamily),
                        ),
                    ),
                ),
                Card(
                    margin: EdgeInsets.all(8.0),
                    child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: text.runes.map((int codePoint) {
                            return OutlineButton(
                                padding: EdgeInsets.all(4.0),
                                child: Column(
                                    children: <Widget>[
                                        Padding(
                                            child: FutureBuilder(
                                                future: FontData.getFontFamilyFuture(context, codePoint),
                                                //future: _unicodeData.getCJKUIFontFamily(codePoint),
                                                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                                    if (!snapshot.hasData) {
                                                        return CircularProgressIndicator();
                                                    }
                                                    return Text(
                                                        String.fromCharCodes([codePoint]),
                                                        textScaleFactor: 4.0,
                                                        style: TextStyle(fontFamily: snapshot.data,),
                                                    );
                                                },
                                            ),
                                            padding: EdgeInsets.all(4.0),
                                        ),
                                        Text(
                                            'U+' + codePoint.toRadixString(16).toUpperCase(),
                                            style: TextStyle(fontFamily: _monospaceFontFamily,),
                                        ),
                                    ],
                                ),
                                onPressed: () {
                                    // TODO
                                },
                            );
                        }).toList(),
                    ),
                ),
            ]
        );
    }

    /// Form Search (漢字 parts)

    Widget _buildPartsListView(String parts) {
        // TODO
        return ListView(
            children: <Widget>[
                Padding(
                    child: Card(
                        child: Text(
                            'parts: ' + parts,
                            textScaleFactor: 1.75,
                        ),
                    ),
                    padding: EdgeInsets.all(4.0),
                ),
                Card(
                    margin: EdgeInsets.all(4.0),
                    child: Wrap(
                        // TODO 指定部分を 有する 漢字群
                    ),
                ),
            ],
        );
    }

    /// Form Search (漢字音)

    Widget _buildReadingListView(String reading) {
        // TODO
        return ListView(
            children: <Widget>[
                Padding(
                    child: Card(
                        child: Text(
                            'reading: ' + reading,
                            textScaleFactor: 1.75,
                        ),
                    ),
                    padding: EdgeInsets.all(4.0),
                ),
                Card(
                    margin: EdgeInsets.all(4.0),
                    child: Wrap(
                        // TODO 音
                    ),
                ),
            ],
        );
    }


    void _onBack() {
        Navigator.pop(context);
    }
}

