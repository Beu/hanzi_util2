import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui' as ui;

// TemplateManager は一旦 挫折せむ。

const String GETPIC_URL = 'https://www.beu.jp/getpic.php';

class ClippingInfo {
    int codePoint;
    String fileName;
    int x0, y0;
    int x1, y1;
    String description;
}


class TemplateManager {

    BuildContext _context;

    TemplateManager(BuildContext context) {
        _context = context;
    }

    String _getUrl(ClippingInfo clippingInfo) {
        return GETPIC_URL + "?name=${clippingInfo.fileName}"
                + "&trim=${clippingInfo.x0},${clippingInfo.y0},${clippingInfo.x1},${clippingInfo.y1}";
    }

    Future<List<ClippingInfo>> getClipInfoListFuture(int codePoint) async {
        List<ClippingInfo> clipInfoList = <ClippingInfo>[];
        await DefaultAssetBundle.of(_context).loadString('assets/coe21-zinbun/getpicture2.data.tsv').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .forEach((String line) {
                    List<String> itemList = line.split("\t");
                    int _codePoint = int.parse(itemList[0], radix: 16);
                    if (_codePoint == codePoint) {
                        ClippingInfo clippingInfo = new ClippingInfo()
                            ..codePoint = int.parse(itemList[0], radix: 16)
                            ..fileName = itemList[1]
                            ..x0 = int.parse(itemList[2])
                            ..y0 = int.parse(itemList[3])
                            ..x1 = int.parse(itemList[4])
                            ..y1 = int.parse(itemList[5])
                            ..description = itemList[6];
                        clipInfoList.add(clippingInfo);

                        () async {
                            await http.get(_getUrl(clippingInfo))
                                .then((http.Response response) {
                                    if (response.statusCode / 100 == 2) {
                                        Uint8List byteList = response.bodyBytes;
                                        print("bodyBytes: ${byteList.lengthInBytes.toString()}");
                                        Future<ui.Codec> codecFuture = ui.instantiateImageCodec(byteList);
                                        codecFuture.then((ui.Codec codec) {
                                            Future<ui.FrameInfo> frameInfoFuture = codec.getNextFrame();
                                            frameInfoFuture.then((ui.FrameInfo frameInfo) {
                                                ui.Image image = frameInfo.image;
                                                print("${image.width.toString()}, ${image.height.toString()}");
                                            });
                                        });
                                    }
                            });
                        }();
                    }
                });
        return clipInfoList;
    }

    void drawClippingImage(ClippingInfo clippingInfo, ui.Canvas canvas, ui.Size size) async {
        http.Response response = await http.get(_getUrl(clippingInfo));
        if (response.statusCode == 200) {
            Uint8List byteList = response.bodyBytes;
            Image image = Image.memory(byteList);
            print("image.width: " + image.width.toString());
            print("image.height: " + image.height.toString());

            Rect sourceRect = Rect.fromLTRB(clippingInfo.x0.toDouble(), clippingInfo.y0.toDouble(), clippingInfo.x1.toDouble(), clippingInfo.y1.toDouble());
            //Rect targetRect = sourceRect.width < sourceRect.height ?
            // size.width : sourceRect.width = ? : sourceRect.height?
            double scaleFactor = (sourceRect.height * size.width < sourceRect.width * size.height)
                    ? size.width / sourceRect.width
                    : size.height / sourceRect.height;
        }
    }
}