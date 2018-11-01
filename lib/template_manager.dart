import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';

import 'dart:async';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'util.dart';

// TemplateManager は一旦 挫折せむ。

const String GETPIC_URL = 'https://www.beu.jp/getpic.php';
const String GETPICINFO_URL = 'https://www.beu.jp/getpicinfo.php';

class ClippingInfo {
    int codePoint;
    String fileName;
    int x0, y0;
    int x1, y1;
    String note;
}


class TemplateManager {

    BuildContext _context;

    TemplateManager(BuildContext context) {
        _context = context;
    }

    String _getPictureUrl(ClippingInfo clippingInfo) {
        return GETPIC_URL + "?name=${clippingInfo.fileName}"
                + "&trim=${clippingInfo.x0},${clippingInfo.y0},${clippingInfo.x1},${clippingInfo.y1}";
    }

    List<String> _getPictureInfoUrls(int codePoint) {
        return <String>[
            GETPICINFO_URL + "?name=coe21-zinbun&code=${codePoint.toRadixString(16).toUpperCase()}",
            GETPICINFO_URL + "?name=daishogwen&code=${codePoint.toRadixString(16).toUpperCase()}"
        ];
    }

    Future<List<ClippingInfo>> getClipInfoListFuture(int codePoint) async {
        List<ClippingInfo> clipInfoList = <ClippingInfo>[];
        _getPictureInfoUrls(codePoint)
                .forEach((String url) async {
                    await http.get(url)
                            .then((http.Response response) {
                                if (response.statusCode / 100 == 2) {
                                    response.body.split("\n")
                                            .map((String line) => line.trim())
                                            .forEach((String line) {
                                                List<String> itemList = line.split("\t");
                                                ClippingInfo clippingInfo = new ClippingInfo()
                                                    ..codePoint = int.parse(itemList[0].substring(2), radix: 16)
                                                    ..fileName = itemList[1]
                                                    ..x0 = int.parse(itemList[2])
                                                    ..y0 = int.parse(itemList[3])
                                                    ..x1 = int.parse(itemList[4])
                                                    ..y1 = int.parse(itemList[5])
                                                    ..note = itemList[6];
                                                clipInfoList.add(clippingInfo);
                                            });
                                } else {
                                    Util.showErrorDialog(_context, response.reasonPhrase);
                                }
                            });
                });
        return clipInfoList;
    }

    void drawClippingImage(ClippingInfo clippingInfo, ui.Canvas canvas, ui.Size canvasSize) async {
        assert(canvasSize.width == canvasSize.height);
        http.Response response = await http.get(_getPictureUrl(clippingInfo));
        if (response.statusCode / 100 == 2) {
            Uint8List byteList = response.bodyBytes;

            ui.Image image = await decodeImageFromList(byteList);
            print("image.width: " + image.width.toString());
            print("image.height: " + image.height.toString());
            assert(image.width == clippingInfo.x1 - clippingInfo.x0 && image.height == clippingInfo.y1 - clippingInfo.y0);

            Rect sourceRect = Rect.fromLTRB(0, 0, image.width.toDouble(), image.height.toDouble());
            double scaleFactor = (sourceRect.height * canvasSize.width < sourceRect.width * canvasSize.height)
                    ? canvasSize.width / sourceRect.width
                    : canvasSize.height / sourceRect.height;
            Paint paint = Paint()
                ..blendMode = BlendMode.src;
            canvas.drawImageRect(image, sourceRect, Rect.fromLTWH((canvasSize.width - scaleFactor * sourceRect.width) / 2.0, (canvasSize.height - scaleFactor * sourceRect.height) / 2.0, scaleFactor * sourceRect.width, scaleFactor * sourceRect.height), paint);
        } else {
            Util.showErrorDialog(_context, response.reasonPhrase);
        }
    }
}