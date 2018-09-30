
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';


class BlockInfo {
    int first;  // first code point in the block (included)
    int last;  // last code point in the block (included)
    String name;  // block name
}

class RadicalInfo {
    int radical;
    bool simplified;
    int codePoint0;  // code point in Kangxi Radicals block
    int codePoint;  // code point in CJK Unified Ideographs*
}

class CharacterInfo {
    int codePoint;  // code point of the character
    int radical;  // radical number (1 - 214)
    bool simplified;  // radical is simplified
    int strokes;  // strokes without radical
}

class ReadingsInfo {
    int codePoint;  // code point of the character
    String type;  // reading type
    List<String> readingList;
}

class VariantInfo {
    int codePoint;  // code point of the character
    String type;  // variant type
    int variantCodePoint;  // code point of the variant character
}


class UnicodeData {

    final BuildContext context;

    UnicodeData(this.context) {
        // do nothing
        // TODO the following is test process
        if (false) {
            () async {
                // 廣東
                Set<String> cantoneseSet = new SplayTreeSet<String>();
                await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Readings.txt').asStream()
                        .transform(const LineSplitter())
                        .map((String line) => line.trim())
                        .where((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkCantonese\t(.*)$")).hasMatch(line))
                        .map((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkCantonese\t(.*)$")).firstMatch(line))
                        .map((Match match) => match.group(2).split(" "))
                        .forEach((List<String> sList) {
                            sList.forEach((String s) {
                                cantoneseSet.add(s);
                            });
                        });
                print(cantoneseSet);
                // 韓國
                Set<String> hangulSet = new SplayTreeSet<String>();
                await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Readings.txt').asStream()
                        .transform(const LineSplitter())
                        .map((String line) => line.trim())
                        .where((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkHangul\t(.*)$")).hasMatch(line))
                        .map((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkHangul\t(.*)$")).firstMatch(line))
                        .map((Match match) => match.group(2).split(" "))
                        .forEach((List<String> sList) {
                            sList.forEach((String s) {
                                hangulSet.add(s.split(':')[0]);
                            });
                        });
                print(hangulSet);
                // 日本 (訓 混じれり)
                Set<String> japaneseSet = new SplayTreeSet<String>();
                await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Readings.txt').asStream()
                        .transform(const LineSplitter())
                        .map((String line) => line.trim())
                        .where((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkJapaneseOn\t(.*)$")).hasMatch(line))
                        .map((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkJapaneseOn\t(.*)$")).firstMatch(line))
                        .map((Match match) => match.group(2).split(" "))
                        .forEach((List<String> sList) {
                            sList.forEach((String s) {
                                japaneseSet.add(s.toLowerCase());
                            });
                        });
                print(japaneseSet);
                // 韓國
                Set<String> koreanSet = new SplayTreeSet<String>();
                await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Readings.txt').asStream()
                        .transform(const LineSplitter())
                        .map((String line) => line.trim())
                        .where((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkKorean\t(.*)$")).hasMatch(line))
                        .map((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkKorean\t(.*)$")).firstMatch(line))
                        .map((Match match) => match.group(2).split(" "))
                        .forEach((List<String> sList) {
                            sList.forEach((String s) {
                                koreanSet.add(s.toLowerCase());
                            });
                        });
                print(koreanSet);
                // 官話
                Set<String> mandarinSet = new SplayTreeSet<String>();
                await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Readings.txt').asStream()
                        .transform(const LineSplitter())
                        .map((String line) => line.trim())
                        .where((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkMandarin\t(.*)$")).hasMatch(line))
                        .map((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkMandarin\t(.*)$")).firstMatch(line))
                        .map((Match match) => match.group(2).split(" "))
                        .forEach((List<String> sList) {
                            sList.forEach((String s) {
                                mandarinSet.add(s.toLowerCase());
                            });
                        });
                print(mandarinSet);
                // 唐
                Set<String> tangSet = new SplayTreeSet<String>();
                await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Readings.txt').asStream()
                    .transform(const LineSplitter())
                    .map((String line) => line.trim())
                    .where((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkTang\t(.*)$")).hasMatch(line))
                    .map((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkTang\t(.*)$")).firstMatch(line))
                    .map((Match match) => match.group(2).split(" "))
                    .forEach((List<String> sList) {
                        sList.forEach((String s) {
                            tangSet.add(s.toLowerCase());
                        });
                    });
                print(tangSet);
                // 越南
                Set<String> vietnameseSet = new SplayTreeSet<String>();
                await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Readings.txt').asStream()
                    .transform(const LineSplitter())
                    .map((String line) => line.trim())
                    .where((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkVietnamese\t(.*)$")).hasMatch(line))
                    .map((String line) => (new RegExp(r"^U\+([0-9A-F]+)\tkVietnamese\t(.*)$")).firstMatch(line))
                    .map((Match match) => match.group(2).split(" "))
                    .forEach((List<String> sList) {
                        sList.forEach((String s) {
                            vietnameseSet.add(s.toLowerCase());
                        });
                    });
                print(vietnameseSet);
            }();
        }
    }

    Future<List<BlockInfo>> getBlockInfoListFuture() {
        RegExp regexp = RegExp(r"^([0-9A-F]+)\.\.([0-9A-F]+); (.+)$");
        return DefaultAssetBundle.of(context).loadString('assets/unicode/Blocks.txt').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .where((String line) => regexp.hasMatch(line))
                .map((String line) => regexp.firstMatch(line))
                .map((Match match) {
                    BlockInfo blockInfo = new BlockInfo()
                        ..first = int.parse(match.group(1), radix: 16)
                        ..last = int.parse(match.group(2), radix: 16)
                        ..name = match.group(3);
                    return blockInfo;
                })
                .toList();
    }

    Future<List<BlockInfo>> getCJKUIBlockInfoListFuture() async {
        RegExp regexp = RegExp(r"^([0-9A-F]+)\.\.([0-9A-F]+); (CJK Unified Ideographs.*)$");
        List<BlockInfo> blockInfoList = await DefaultAssetBundle.of(context).loadString('assets/unicode/Blocks.txt').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .where((String line) => regexp.hasMatch(line))
                .map((String line) => regexp.firstMatch(line))
                .map((Match match) {
                    BlockInfo blockInfo = new BlockInfo()
                        ..first = int.parse(match.group(1), radix: 16)
                        ..last = int.parse(match.group(2), radix: 16)
                        ..name = match.group(3);
                    return blockInfo;
                })
                .toList();
        blockInfoList.sort((BlockInfo info1, BlockInfo info2) => info1.name.compareTo(info2.name));
        return blockInfoList;
    }

    Future<List<RadicalInfo>> getRadicalInfoListFuture() {
        RegExp regexp = RegExp(r"^([0-9]+)('?); ([0-9A-F]+); ([0-9A-F]+)$");
        return DefaultAssetBundle.of(context).loadString('assets/unicode/CJKRadicals.txt').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .where((String line) => regexp.hasMatch(line))
                .map((String line) => regexp.firstMatch(line))
                .map((Match match) {
                    RadicalInfo radicalInfo = new RadicalInfo()
                        ..radical = int.parse(match.group(1))
                        ..simplified = (match.group(2) == "'")
                        ..codePoint0 = int.parse(match.group(3), radix: 16)
                        ..codePoint = int.parse(match.group(4), radix: 16);
                    return radicalInfo;
                })
                .toList();
    }


    Future<bool> _codePointInCJKUIBlock(int codePoint) async {
        List<BlockInfo> blockInfoList = await getCJKUIBlockInfoListFuture();
        for (BlockInfo blockInfo in blockInfoList) {
            if (codePoint >= blockInfo.first && codePoint <= blockInfo.last) {
                return true;
            }
        }
        return false;
    }

    int _cjkUICompareToBlock(BlockInfo o1, BlockInfo o2) {
        return o1.name.compareTo(o2.name);
    }

    Future<int> _cjkUICompareToInt(int o1, int o2) async {
        BlockInfo blockInfo1 = await _getBlockInfo(o1);
        assert(blockInfo1 != null);
        BlockInfo blockInfo2 = await _getBlockInfo(o2);
        assert(blockInfo2 != null);
        int result = _cjkUICompareToBlock(blockInfo1, blockInfo2);
        if (result != 0) {
            return result;
        }
        return o1.compareTo(o2);
    }

    Future<BlockInfo> _getBlockInfo(int codePoint) async {
        List<BlockInfo> cjkUIBlockInfoList = await getCJKUIBlockInfoListFuture();
        for (BlockInfo blockInfo in cjkUIBlockInfoList) {
            if (codePoint >= blockInfo.first && codePoint <= blockInfo.last) {
                return blockInfo;
            }
        }
        return null;
    }

    Future<BlockInfo> getBlockInfo(int codePoint) async {
        List<BlockInfo> blockInfoList = await getBlockInfoListFuture();
        for (BlockInfo blockInfo in blockInfoList) {
            if (codePoint >= blockInfo.first && codePoint <= blockInfo.last) {
                return blockInfo;
            }
        }
        return null;
    }


    Future<Map<int, List<CharacterInfo>>> getUnicodeCharacterInfoListMapWithRadicalFuture(RadicalInfo radicalInfo) async {
        Map<int, List<CharacterInfo>> characterInfoListMap = SplayTreeMap<int, List<CharacterInfo>>();
        RegExp regexp = RegExp(r"^U\+([0-9A-F]+)\tkRSUnicode\t(.*" + radicalInfo.radical.toString() + (radicalInfo.simplified ? r"'" : r"") + r"\.-?[0-9]+.*)$");
        RegExp regexp2 = RegExp(r"^" + radicalInfo.radical.toString() + (radicalInfo.simplified ? r"'" : r"") + r"\.(-?[0-9]+)$");

        List<BlockInfo> cjkUIBlockInfoList = await getCJKUIBlockInfoListFuture();

        await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_IRGSources.txt').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .where((String line) => regexp.hasMatch(line))
                .map((String line) => regexp.firstMatch(line))
                .forEach((Match match) {
                    int codePoint = int.parse(match.group(1), radix: 16);
                    for (BlockInfo cjkUIBlockInfo in cjkUIBlockInfoList) {
                        if (codePoint >= cjkUIBlockInfo.first && codePoint <= cjkUIBlockInfo.last) {
                            for (String s in match.group(2).trim().split('\t')) {
                                if (regexp2.hasMatch(s)) {
                                    Match match2 = regexp2.firstMatch(s);
                                    CharacterInfo characterInfo = new CharacterInfo()
                                        ..codePoint = codePoint
                                        ..radical = radicalInfo.radical
                                        ..simplified = radicalInfo.simplified
                                        ..strokes = int.parse(match2.group(1));
                                    if (!characterInfoListMap.containsKey(characterInfo.strokes)) {
                                        characterInfoListMap.putIfAbsent(characterInfo.strokes, () => <CharacterInfo>[characterInfo]);
                                    } else {
                                        characterInfoListMap[characterInfo.strokes].add(characterInfo);
                                    }
                                }
                            }
                            //break;
                        }
                    }
                });
        return characterInfoListMap;
    }

    Future<Map<int, List<CharacterInfo>>> getKangxiCharacterInfoListMapWithRadicalFuture(RadicalInfo radicalInfo) async {
        Map<int, List<CharacterInfo>> characterInfoListMap = SplayTreeMap<int, List<CharacterInfo>>();
        RegExp regexp = RegExp(r"^U\+([0-9A-F]+)\tkRSKangXi\t(.*" + radicalInfo.radical.toString() +  r"\.-?[0-9]+).*$");
        RegExp regexp2 = RegExp(r"^" + radicalInfo.radical.toString() + r"\.(-?[0-9]+)$");

        List<BlockInfo> cjkBlockInfoList = await getCJKUIBlockInfoListFuture();

        await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_RadicalStrokeCounts.txt').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .where((String line) => regexp.hasMatch(line))
                .map((String line) => regexp.firstMatch(line))
                .forEach((Match match) {
                    int codePoint = int.parse(match.group(1), radix: 16);
                    for (BlockInfo cjkBlockInfo in cjkBlockInfoList) {
                        if (codePoint >= cjkBlockInfo.first && codePoint <= cjkBlockInfo.last) {
                            for (String s in match.group(2).trim().split('\t')) {
                                if (regexp2.hasMatch(s)) {
                                    Match match2 = regexp2.firstMatch(s);
                                    CharacterInfo characterInfo = new CharacterInfo()
                                        ..codePoint = codePoint
                                        ..radical = radicalInfo.radical
                                        ..simplified = radicalInfo.simplified
                                        ..strokes = int.parse(match2.group(1));
                                    if (!characterInfoListMap.containsKey(characterInfo.strokes)) {
                                        characterInfoListMap.putIfAbsent(characterInfo.strokes, () => <CharacterInfo>[characterInfo]);
                                    } else {
                                        characterInfoListMap[characterInfo.strokes].add(characterInfo);
                                    }
                                }
                            }
                            //break;
                        }
                    }
                });
        return characterInfoListMap;
    }

    Future<Map<int, List<RadicalInfo>>> getUnicodeRadicalInfoListWithStrokesFuture() async {
        RegExp regexp = RegExp(r"^(?:\#strokes ([0-9]+))|(?:([0-9]+)('?); ([0-9A-F]+); ([0-9A-F]+))$");
        Map<int, List<RadicalInfo>> infoListMap = SplayTreeMap<int, List<RadicalInfo>>();
        int radicalStrokes = 0;
        await DefaultAssetBundle.of(context).loadString('assets/unicode/CJKRadicalsWithStrokes.txt').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .where((String line) => regexp.hasMatch(line))
                .map((String line) => regexp.firstMatch(line))
                .forEach((Match match) {
                    if (match.group(1) != null && match.group(1).isNotEmpty) {
                        radicalStrokes = int.parse(match.group(1));
                    } else {
                        RadicalInfo radicalInfo = new RadicalInfo()
                            ..radical = int.parse(match.group(2))
                            ..simplified = match.group(3) == "'"
                            ..codePoint0 = int.parse(match.group(4), radix: 16)
                            ..codePoint = int.parse(match.group(5), radix: 16);
                        if (infoListMap.containsKey(radicalStrokes)) {
                            infoListMap[radicalStrokes].add(radicalInfo);
                        } else {
                            infoListMap.putIfAbsent(radicalStrokes, () => <RadicalInfo>[radicalInfo]);
                        }
                    }
                });
        return infoListMap;
    }

    Future<Map<int, List<RadicalInfo>>> getKangxiRadicalInfoListWithStrokesFuture() async {
        RegExp regexp = RegExp(r"^(?:\#strokes ([0-9]+))|(?:([0-9]+); ([0-9A-F]+); ([0-9A-F]+))$");
        Map<int, List<RadicalInfo>> infoListMap = SplayTreeMap<int, List<RadicalInfo>>();
        int radicalStrokes = 0;
        await DefaultAssetBundle.of(context).loadString('assets/unicode/CJKRadicalsWithStrokes.txt').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .where((String line) => regexp.hasMatch(line))
                .map((String line) => regexp.firstMatch(line))
                .forEach((Match match) {
                    if (match.group(1) != null && match.group(1).isNotEmpty) {
                        radicalStrokes = int.parse(match.group(1));
                    } else {
                        RadicalInfo radicalInfo = new RadicalInfo()
                            ..radical = int.parse(match.group(2))
                            ..simplified = false
                            ..codePoint0 = int.parse(match.group(3), radix: 16)
                            ..codePoint = int.parse(match.group(4), radix: 16);
                        if (infoListMap.containsKey(radicalStrokes)) {
                            infoListMap[radicalStrokes].add(radicalInfo);
                        } else {
                            infoListMap.putIfAbsent(radicalStrokes, () => <RadicalInfo>[radicalInfo]);
                        }
                    }
                });
        return infoListMap;
    }

    Future<List<int>> getReadingsInfoListListFuture(String reading) async {
        RegExp regexp = RegExp(r"^U\+([0-9A-F]+)\tk(Cantonese|Hangul|JapaneseOn|Korean|Mandarin|Tang|Vietnamese)\t(.+)$");
        List<int> codePointList = List<int>();
        await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Readings.txt').asStream()
                .transform(LineSplitter())
                .map((String line) => line.trim())
                .where((String line) => regexp.hasMatch(line))
                .map((String line) => regexp.firstMatch(line))
                .forEach((Match match) {
                    List<String> readingList = match.group(3).split(" ");
                    readingList.forEach((String word) {
                        // TODO: 實は こゝに 聲調記號などを 慮れる 處理を 入れたし
                        if (word == reading) {
                            int codePoint = int.parse(match.group(1), radix: 16);
                            if (!codePointList.contains(codePoint)) {
                                codePointList.add(codePoint);
                            }
                        }
                    });
                });
        return codePointList;
    }


    Future<Set<int>> _getVariantCodePointSetFuture(int codepoint) async {
        Set<int> codePointSet = SplayTreeSet<int>();
        codePointSet.add(codepoint);

        RegExp regexp = RegExp(r"^U\+([0-9A-F]+)\tk(Simplified|Traditional|Z)Variant\tU\+([0-9A-F]+)$");
        RegExp regexp2 = RegExp(r"^U\+([0-9A-F]+)\t.*U\+([0-9A-F]+)$");

        int codePointCount;
        do {
            codePointCount = codePointSet.length;
            await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_Variants.txt').asStream()
                    .transform(LineSplitter())
                    .map((String line) => line.trim())
                    .where((String line) => regexp.hasMatch(line))
                    .map((String line) => regexp.firstMatch(line))
                    .forEach((Match match) {
                        int codePoint1 = int.parse(match.group(1), radix: 16);
                        int codePoint2 = int.parse(match.group(3), radix: 16);
                        if (codePointSet.contains(codePoint1)) {
                            codePointSet.add(codePoint2);
                        }
                        if (codePointSet.contains(codePoint2)) {
                            codePointSet.add(codePoint1);
                        }
                    });
            await DefaultAssetBundle.of(context).loadString('assets/unicode/Unihan_OtherMappings.txt').asStream()
                    .transform(LineSplitter())
                    .map((String line) => line.trim())
                    .where((String line) => regexp2.hasMatch(line))
                    .map((String line) => regexp2.firstMatch(line))
                    .forEach((Match match) {
                        int codePoint1 = int.parse(match.group(1), radix: 16);
                        int codePoint2 = int.parse(match.group(2), radix: 16);
                        if (codePointSet.contains(codePoint1)) {
                            codePointSet.add(codePoint2);
                        }
                        if (codePointSet.contains(codePoint2)) {
                            codePointSet.add(codePoint1);
                        }
                    });
        } while (codePointSet.length > codePointCount);

        return codePointSet;
    }

    Future<String> getVariantCodePointListFuture(String text) async {
        String s = "";
        List<int> codePointList = text.runes.toList();
        for (int i = 0;  i < codePointList.length;  ++i) {
            int codePoint = codePointList[i];
            Set<int> codePointSet = await _getVariantCodePointSetFuture(codePoint);
            for (int codePoint2 in codePointSet) {
                if (await _codePointInCJKUIBlock(codePoint2)) {
                    s += String.fromCharCodes([codePoint2]);
                }
            }
        }
        return s;
    }

}