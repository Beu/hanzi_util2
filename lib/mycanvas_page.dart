
import 'package:flutter/material.dart';

import 'dart:core';
import 'dart:ui';


class MyCanvasPage extends StatefulWidget {

    @override
    State createState() {
        return new _MyCanvasPageState();
    }
}

class _MyCanvasPageState extends State<MyCanvasPage> {

    @override
    Widget build(BuildContext context) {

        AppBar appBar = AppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back, size: 32.0),
                onPressed: _gotoPreviousPage,
            ),
            title: Text('hand-writing'),
            centerTitle: true,
        );

        Widget scaffold = Scaffold(

            appBar: appBar,

            body: Column(
                children: <Widget>[
                    // appBar の 高さのみ にては 溢る
                    new MyCanvas(appBar.preferredSize.height + 20),
                ],
            ),

        );

        return scaffold;
    }

    void _gotoPreviousPage() {
        Navigator.of(context).pop();
    }
}

class MyCanvas extends StatefulWidget {

    final double appBarHeight;

    MyCanvas(this.appBarHeight) {
        // TODO?
    }

    @override
    State createState() {
        return new _MyCanvasState(appBarHeight);
    }
}


/// logical renderBoxSize [0.0...1000.0]
const double _RENDER_BOX_SIZE = 1000.0;

/// physical pixel position to logical position
Offset _physicalToLogical(Offset point, double renderBoxSize) {
    return point * _RENDER_BOX_SIZE / renderBoxSize;
}

/// logical position to physical pixel position
Offset _logicalToPhysical(Offset point, double renderBoxSize) {
    return point * renderBoxSize / _RENDER_BOX_SIZE;
}


class _MyCanvasState extends State<MyCanvas> {

    List<List<Offset>> _polylineList;

    final double appBarHeight;

    _MyCanvasState(this.appBarHeight) {
        // TODO?
    }

    @override
    void initState() {
        super.initState();
        _polylineList = [];
    }

    @override
    void dispose() {
        _polylineList.clear();
        super.dispose();
    }

    double _renderBoxSize;

    @override
    Widget build(BuildContext context) {

        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        if (screenWidth < screenHeight) {
            _renderBoxSize = screenWidth;
        } else {
            //_renderBoxSize = screenHeight - 80.0;
            // TODO: this value 80 is about the height of AppBar
            // 恐らくは 機種により 左右せむ
            // 例外が 捕へられず
            _renderBoxSize = screenHeight - appBarHeight;
            print("appBarHeight: " + appBarHeight.toString());
        }

        return Flex(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            direction: (screenWidth < screenHeight) ? Axis.vertical : Axis.horizontal,
            children: <Widget>[
                GestureDetector(
                    child: CustomPaint(
                        size: Size(_renderBoxSize, _renderBoxSize),
                        painter: new MyPainter(_polylineList),
                    ),
                    onVerticalDragStart: _onDragStart,
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: _onDragEnd,
                    excludeFromSemantics: true,
                ),
                Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Flex(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        direction: (screenWidth < screenHeight) ? Axis.horizontal : Axis.vertical,
                        children: <Widget>[
                            OutlineButton(
                                child: Row(
                                    children: <Widget>[
                                        Icon(Icons.clear),
                                        Text(' clear'),
                                    ],
                                ),
                                onPressed: _onClear,
                            ),
                            OutlineButton(
                                child: Row(
                                    children: <Widget>[
                                        Icon(Icons.backspace),
                                        Text(' remove'),
                                    ],
                                ),
                                onPressed: _onRemove,
                            ),
                            OutlineButton(
                                child: Row(
                                    children: <Widget>[
                                        Icon(Icons.save),
                                        Text(' save'),
                                    ],
                                ),
                                onPressed: _onSave,
                            ),
                        ],
                    ),
                ),
            ],
        );
    }

    void _onDragStart(DragStartDetails details) {
        setState(() {
            Offset point = details.globalPosition;
            RenderBox renderBox = context.findRenderObject();
            Offset localPoint = renderBox.globalToLocal(point);
            _polylineList.add(<Offset>[_physicalToLogical(localPoint, _renderBoxSize)]);
        });
    }
    void _onDragUpdate(DragUpdateDetails details) {
        setState(() {
            Offset point = details.globalPosition;
            RenderBox renderBox = context.findRenderObject();
            Offset localPoint = renderBox.globalToLocal(point);
            if (localPoint.dx >= 0 && localPoint.dx <= _renderBoxSize
                    && localPoint.dy >= 0 && localPoint.dy <= _renderBoxSize) {
                _polylineList.last.add(_physicalToLogical(localPoint, _renderBoxSize));
            }
        });
    }
    void _onDragEnd(DragEndDetails details) {
        setState(() {});
    }

    void _onRemove() {
        setState(() {
            if (_polylineList.length > 0) {
                _polylineList.removeLast();
            }
        });
    }
    void _onClear() {
        setState(() {
            _polylineList.clear();
        });
    }
    void _onSave() {
        setState(() {
        });
    }
}

class MyPainter extends CustomPainter {

    List<List<Offset>> polylineList;

    MyPainter(List<List<Offset>> _polylineList) {
        polylineList = _polylineList;
    }

    @override
    void paint(Canvas canvas, Size size) {

        Paint paint = Paint()
            ..color = Color.fromARGB(255, 0, 64, 0)
            ..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), paint);

        // draw axises

        paint = Paint()
            ..color = Colors.grey
            ..strokeCap = StrokeCap.square
            ..strokeWidth = 1.0;

        double one = size.width;
        double half = size.width / 2.0;
        canvas.drawLine(Offset(half, 0.0), Offset(half, one), paint);
        canvas.drawLine(Offset(0.0, half), Offset(one, half), paint);
        canvas.drawLine(Offset(0.0, 0.0), Offset(one, 0.0), paint);
        canvas.drawLine(Offset(one, 0.0), Offset(one, one), paint);
        canvas.drawLine(Offset(one, one), Offset(0.0, one), paint);
        canvas.drawLine(Offset(0.0, one), Offset(0.0, 0.0), paint);

        // draw polylines

        paint = Paint()
            ..color = Colors.white
            ..strokeCap = StrokeCap.round
            ..strokeWidth = 4.0;
        for (int i = 0;  i < polylineList.length;  ++i) {
            List<Offset> polyline = polylineList[i];
            for (int j = 1;  j < polyline.length;  ++j) {
                canvas.drawLine(_logicalToPhysical(polyline[j - 1], size.width), _logicalToPhysical(polyline[j], size.height), paint);
            }
            {
                TextSpan span = TextSpan(
                    text: (i + 1).toString(),
                    style: TextStyle(color: Colors.white70, fontSize: 16.0)
                );
                TextPainter tp = TextPainter(
                    text: span,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr
                );
                tp.layout();
                tp.paint(canvas, _logicalToPhysical(polylineList[i][0], size.width));
            }
        }
    }

    @override
    bool shouldRepaint(CustomPainter oldDelegate) {
        return true;
    }
}

