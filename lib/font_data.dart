import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'unicode_data.dart';


enum CJK_TYPE {
    JP, TC, SC, KR,
}

class FontData {

    static CJK_TYPE _currentCJKType = CJK_TYPE.JP;

    // Locale に 觸るゝに font の 表示 狂ふが 故 使はじ
    static const Map<CJK_TYPE, Locale> _LOCALE_MAP = {
        CJK_TYPE.JP: Locale('ja', 'JP'),
        CJK_TYPE.TC: Locale('zh', 'TW'),
        CJK_TYPE.SC: Locale('zh', 'CN'),
        CJK_TYPE.KR: Locale('ko', 'KR'),
    };

    static const Map<CJK_TYPE, String> _NOTO_SERIF_CJK_FAMILY_MAP = {
        CJK_TYPE.JP: 'Noto Serif CJK JP',
        CJK_TYPE.TC: 'Noto Serif CJK TC',
        CJK_TYPE.SC: 'Noto Serif CJK SC',
        CJK_TYPE.KR: 'Noto Serif CJK KR',
    };

    static const Map<CJK_TYPE, String> _SYMBOL_MAP = {
        CJK_TYPE.JP: '日',
        CJK_TYPE.TC: '繁',
        CJK_TYPE.SC: '简',
        CJK_TYPE.KR: '韓',
    };

    static const Map<CJK_TYPE, String> _FONT_FILE_NAME_MAP = {
        CJK_TYPE.JP: 'NotoSerifCJKjp-Regular.otf',
        CJK_TYPE.TC: 'NotoSerifCJKtc-Regular.otf',
        CJK_TYPE.SC: 'NotoSerifCJKsc-Regular.otf',
        CJK_TYPE.KR: 'NotoSerifCJKkr-Regular.otf',
    };

    final BuildContext context;

    /// constructor
    FontData(this.context) {
        // TODO
    }

    static Locale getCurrentLocale() {
        return _LOCALE_MAP[_currentCJKType];
    }

    static void switchNextLocale() {
        switch (_currentCJKType) {
            case CJK_TYPE.JP:
                _currentCJKType = CJK_TYPE.TC;
                break;
            case CJK_TYPE.TC:
                _currentCJKType = CJK_TYPE.SC;
                break;
            case CJK_TYPE.SC:
                _currentCJKType = CJK_TYPE.KR;
                break;
            case CJK_TYPE.KR:
                _currentCJKType = CJK_TYPE.JP;
                break;
        }
    }

    static String getMonospaceFontFamily() {
        return 'Monospace';
    }

    static String getCJKNormalFontFamily() {
        return _NOTO_SERIF_CJK_FAMILY_MAP[_currentCJKType];
    }

    static String getCurrentLocaleSymbol() {
        return _SYMBOL_MAP[_currentCJKType];
    }

    static Future<String> getFontFamilyFuture(BuildContext context, int codePoint) async {
        // order: NotoSerifCJK..-Regular > HanaMinA > HanaMinB
        UnicodeData unicodeData = new UnicodeData(context);
        String family = getCJKNormalFontFamily();
        BlockInfo blockInfo = await unicodeData.getBlockInfo(codePoint);
        String blockName = blockInfo.name;
        int blockFirst = max((codePoint & ~0xff), blockInfo.first);
        String line = await DefaultAssetBundle.of(context).loadString('fonts/' + _FONT_FILE_NAME_MAP[_currentCJKType].replaceFirst('otf', 'yaml')).asStream()
                .transform(LineSplitter())
                //.map((String line) => line.trimRight())
                .skipWhile((String line) => !line.startsWith("    name: $blockName"))
                .firstWhere((String line) {
                    return line.startsWith("      - {0x" + blockFirst.toRadixString(16).toUpperCase());
                });
        String flags = line.substring(line.indexOf(': ') + 2, line.length - 1);
        if (flags == '1') {
            return family;
        } else if (flags == '0') {
            // next family
        } else if (flags[codePoint - blockFirst] == '1') {
            return family;
        } else {
            // next family
        }

        line = await DefaultAssetBundle.of(context).loadString('fonts/HanaMinA.yaml').asStream()
                .transform(LineSplitter())
                //.map((String line) => line.trimRight())
                .skipWhile((String line) => !line.startsWith("    name: $blockName"))
                .firstWhere((String line) {
                   return line.startsWith('      - {0x' + blockFirst.toRadixString(16).toUpperCase());
                });
        flags = line.substring(line.indexOf(': ') + 2, line.length - 1);
        if (flags == '1') {
            return 'HanaMinA';
        } else if (flags == '0') {
            // next family
        } else if (flags[codePoint - blockFirst] == '1') {
            return 'HanaMinA';
        } else {
            // next family
        }

        line = await DefaultAssetBundle.of(context).loadString('fonts/HanaMinB.yaml', cache: true).asStream()
                .transform(LineSplitter())
                //.map((String line) => line.trimRight())
                .skipWhile((String line) => !line.startsWith("    name: $blockName"))
                .firstWhere((String line) {
                    return line.startsWith("      - {0x" + blockFirst.toRadixString(16).toUpperCase());
                });
        flags = line.substring(line.indexOf(': ') + 2, line.length - 1);
        if (flags == '1') {
            return 'HanaMinB';
        } else if (flags == '0') {
            // next family
        } else if (flags[codePoint - blockFirst] == '1') {
            return 'HanaMinB';
        } else {
            // next family
        }
        return null;
    }
}
