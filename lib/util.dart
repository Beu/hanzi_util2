
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:core';


class Util {

    static Future<Null> showNotSupported(BuildContext context) {
        return showDialog<Null>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('warning'),
                    content: Wrap(
                        children: <Widget>[
                            Icon(Icons.warning, size: 48.0,),
                            Text(' Not Supported (yet)!')
                        ],
                    ),
                    actions: <Widget>[
                        OutlineButton(
                            child: Text('OK'),
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                        ),
                    ],
                );
            },
        );
    }

    static Future<Null> showErrorDialog(BuildContext context, String message) {
        return showDialog<Null>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('error'),
                    content: Wrap(
                        children: <Widget>[
                            Icon(Icons.error, size: 48.0,),
                            Text(' ' + message),
                        ],
                    ),
                    actions: <Widget>[
                        OutlineButton(
                            child: Text('OK'),
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                        ),
                    ],
                );
            },
        );
    }

    static Future<Null> showInfoDialog(BuildContext context, String message) {
        return showDialog<Null>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text('information'),
                    content: Wrap(
                        children: <Widget>[
                            Icon(Icons.info, size: 48.0,),
                            Text(' ' + message),
                        ],
                    ),
                    actions: <Widget>[
                        OutlineButton(
                            child: Text('OK'),
                            onPressed: () {
                                Navigator.of(context).pop();
                            },
                        ),
                    ],
                );
            },
        );
    }

    static int codePointFromSurrogatePair(int high, int low) {
        assert (high >= 0xd800);
        assert (low >= 0xdc00);
        return 0x10000 + ((high - 0xd800) << 10) + (low - 0xdc00);
    }

    static List<int> codePointToUtf16(int codePoint) {
        if (codePoint <= 0xffff) {
            return <int>[codePoint];
        } else {
            codePoint -= 0x10000;
            return <int>[0xd800 + (codePoint >> 10), 0xdc00 + (codePoint & 0x03ff)];
        }
    }

    static int codePointFromUtf8(List<int> codes) {
        if (codes[0] >= 0xf0 && codes[0] <= 0xf7) {
            if (codes.length != 4) {
                // error
                return -1;
            }
            return ((codes[0] & 0x07) << 18) | ((codes[1] & 0x3f) << 12) | ((codes[2] & 0x3f) << 6) | (codes[3] & 0x3f);
        } else if (codes[0] >= 0xe0 && codes[0] <= 0xef) {
            if (codes.length != 3) {
                // error
                return -1;
            }
            return ((codes[0] & 0x0f) << 12) | ((codes[1] & 0x3f) << 6) | (codes[2] & 0x3f);
        } else if (codes[0] >= 0xc2 && codes[0] <= 0xdf) {
            if (codes.length != 2) {
                // error
                return -1;
            }
            return ((codes[0] & 0x1f) << 6) | (codes[1] & 0x3f);
        } else if (codes[0] >= 0x00 && codes[0] <= 0x7f) {
            if (codes.length != 1) {
                // error
                return -1;
            }
            return codes[0];
        } else {
            // error
            return -1;
        }
    }

    static List<int> codePointToUtf8(int codePoint) {
        if (codePoint <= 0x7f) {
            return <int>[codePoint];
        }
        if (codePoint <= 0x07ff) {
            return <int>[
                0xc0 + (codePoint >> 7),
                0x80 + (codePoint & 0x3f)
            ];
        }
        if (codePoint <= 0xffff) {
            return <int>[
                0xe0 + (codePoint >> 12),
                0x80 + ((codePoint >> 6) & 0x3f),
                0x80 + (codePoint & 0x3f)
            ];
        }
        if (codePoint <= 0x1fffff) {
            return <int>[
                0xf0 + (codePoint >> 19),
                0x80 + ((codePoint >> 12) & 0x3f),
                0x80 + ((codePoint >> 6) & 0x3f),
                0x80 + (codePoint & 0x3f)
            ];
        }
        return null;
    }
}
