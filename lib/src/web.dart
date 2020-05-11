import 'dart:html' as html;
import 'dart:ui' as ui;
import 'dart:js' as js;

import 'package:flutter/material.dart';

import 'impl.dart';

class EasyWebView extends StatefulWidget implements EasyWebViewImpl {
  const EasyWebView({
    Key key,
    @required this.src,
    this.height,
    this.width,
    this.webAllowFullScreen = true,
    this.isHtml = false,
    this.isMarkdown = false,
    this.convertToWidets = false,
    this.headers = const {},
    this.widgetsTextSelectable = false,
  })  : assert((isHtml && isMarkdown) == false),
        super(key: key);

  @override
  _EasyWebViewState createState() => _EasyWebViewState();

  @override
  final num height;

  @override
  final String src;

  @override
  final num width;

  @override
  final bool webAllowFullScreen;

  @override
  final bool isMarkdown;

  @override
  final bool isHtml;

  @override
  final bool convertToWidets;

  @override
  final Map<String, String> headers;

  @override
  final bool widgetsTextSelectable;
}

class _EasyWebViewState extends State<EasyWebView> {
  @override
  void didUpdateWidget(EasyWebView oldWidget) {
    if (oldWidget.height != widget.height) {
      if (mounted) setState(() {});
    }
    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }
    if (oldWidget.src != widget.src) {
      if (mounted) setState(() {});
    }
    if (oldWidget.headers != widget.headers) {
      if (mounted) setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return OptionalSizedChild(
      width: widget?.width,
      height: widget?.height,
      builder: (w, h) {
        String src = widget.src;
        if (widget.convertToWidets) {
          if (EasyWebViewImpl.isUrl(src)) {
            return RemoteMarkdown(
              src: src,
              headers: widget.headers,
              isSelectable: widget.widgetsTextSelectable,
            );
          }
          String _markdown = '';
          if (widget.isMarkdown) {
            _markdown = src;
          }
          if (widget.isHtml) {
            src = EasyWebViewImpl.wrapHtml(src);
            _markdown = EasyWebViewImpl.html2Md(src);
          }
          return LocalMarkdown(
            data: _markdown,
            isSelectable: widget.widgetsTextSelectable,
          );
        }
        _setup(src, w, h);
        _addEvent();
        return AbsorbPointer(
          child: RepaintBoundary(
            child: HtmlElementView(
              key: widget?.key,
              viewType: 'iframe-$src',
            ),
          ),
        );
      },
    );
  }
 
  static final _iframeElementMap = Map<Key, html.IFrameElement>();

  void _setup(String src, num width, num height) {
    final src = widget.src;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('iframe-$src', (int viewId) {
      if (_iframeElementMap[widget.key] == null) {
        _iframeElementMap[widget.key] = html.IFrameElement();
      }
      final element = _iframeElementMap[widget.key]
        ..style.border = '0'
         ..id = 'EasyWebView'
        ..allow = 'microphone *;camera *'
        ..allowFullscreen = widget.webAllowFullScreen
        ..height = height.toInt().toString()
        ..width = width.toInt().toString();
      if (src != null) {
        String _src = src;
        if (widget.isMarkdown) {
          _src = "data:text/html;charset=utf-8," +
              Uri.encodeComponent(EasyWebViewImpl.md2Html(src));
        }
        if (widget.isHtml) {
          _src = "data:text/html;charset=utf-8," +
              Uri.encodeComponent(EasyWebViewImpl.wrapHtml(src));
        }
        element..src = _src;
      }
      return element;
    });
  }
}


void _addEvent(){
    print("--------------_addEvent--------");
    html.window.addEventListener('message', (event) {
      print('====message===$event');
      var element = html.document.getElementsByTagName('flt-platform-view')[0]
          as html.HtmlElement;
      var iFrame = element.shadowRoot.getElementById('EasyWebView')
          as html.IFrameElement;
      var iFrameJsObj = new js.JsObject.fromBrowserObject(iFrame);
      var iFreameWinJsObj =
          new js.JsObject.fromBrowserObject(iFrameJsObj['contentWindow']);
      
      var button = iFreameWinJsObj.document.getElementsByClassName('toolbox-icon');
      
      print("button"$button);
      
      //print('====iFreameWinJsObj===$iFreameWinJsObj');
      // iFreameWinJsObj.callMethod('init');
      // iFreameWinJsObj.callMethod(widget.resData);
     // iFreameWinJsObj.callMethod(widget.methodName, [widget.resData]);
      //iFrame.contentWindow.postMessage('message', '*');
    });
  }
