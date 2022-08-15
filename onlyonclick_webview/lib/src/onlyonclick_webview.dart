import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:async';
import 'dart:collection';


class OnlyOnClickWebViewWidget extends StatefulWidget {

  final String url;
  final String title;
  final Widget? drawerWidget;
  final Color appBarColor;
  final Color textColor;
  final Color iconColor;
  final Color loaderColor;
  final bool hideWebPageElements;

  const OnlyOnClickWebViewWidget({required this.url, required this.title, this.drawerWidget, required this.hideWebPageElements, this.appBarColor = const Color(0xff094317), this.textColor = Colors.white, this.iconColor = Colors.white , this.loaderColor = const Color(0xff094317), Key? key}) : super(key: key);

  @override
  State<OnlyOnClickWebViewWidget> createState() => _OnlyOnClickWebViewWidgetState();
}

class _OnlyOnClickWebViewWidgetState extends State<OnlyOnClickWebViewWidget> {

  late InAppWebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 3),
            () {
          isLoading = true;
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: widget.drawerWidget == null ? const Text('') : Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.menu_open),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }
          ),
          title: Text(widget.title,
            style: TextStyle(
                color: widget.textColor
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xff094317),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: widget.iconColor,
                  ),
                  onPressed: () {
                    _controller.goBack();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: widget.iconColor,
                  ),
                  onPressed: () {
                    _controller.reload();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: widget.iconColor,
                  ),
                  onPressed: () {
                    _controller.clearCache();
                    _controller.evaluateJavascript(
                        source: """<script>
                      document.cookie.split(';').forEach(
                        function(c) {
                          document.cookie = c.replace(/^ +/, ').replace(/=.*/, '=;expires=' + new Date().toUTCString() + ';path=/');
                        }
                      );
                      </script>""");
                    _controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.url)));
                  },
                )
              ],
            ),
          ),
        ),
        drawer: widget.drawerWidget ?? const Text(''),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                  url: Uri.parse(widget.url)
              ),
              initialUserScripts: UnmodifiableListView<UserScript>(
                  [
                    widget.hideWebPageElements == true ?
                    UserScript(
                        source: """
                        document.getElementsByTagName('header')[0].style.display = 'none';
                        document.getElementsByTagName('footer')[0].style.display = 'none';
                        slider = document.getElementById('slider-70');
                        if (slider){
                          slider.style.display = 'none';
                        }
                        var banner = document.getElementsByClassName('page-title')[0];
                        if (banner){
                          banner.style.display = 'none';
                        }
                        """,
                        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END
                    ) : UserScript(
                        source: "",
                        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START
                    ),
                  ]
              ),
              onWebViewCreated: (InAppWebViewController controller) {
                _controller = controller;
              },
              onLoadStart: (InAppWebViewController controller, Uri? uri) {
                isLoading = true;
                setState(() {
                });
              },

              onLoadStop: (InAppWebViewController controller, Uri? uri) {
                widget.hideWebPageElements == true ? _controller.evaluateJavascript(
                    source: """ 
                                <script>
                                  document.getElementsByTagName('header')[0].style.display = 'none';
                                  document.getElementsByTagName('footer')[0].style.display = 'none';
                                  slider = document.getElementById('slider-70');
                                  if (slider){
                                    slider.style.display = 'none';
                                  }
                                  var banner = document.getElementsByClassName('page-title')[0];
                                  if (banner){
                                    banner.style.display = 'none';
                                  }
                                </script>
                             """
                ) : '';
                Future.delayed(
                    const Duration(seconds: 3),
                        () {
                      isLoading = false;
                      setState(() {});
                    }
                );
              },
            ),
            isLoading == true ? loadingAnimationWebView() : const SizedBox()
          ],
        )
    );
  }

  Widget loadingAnimationWebView() {
    isLoading = true;
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: LoadingAnimationWidget.inkDrop(
            color: widget.loaderColor,
            size: 60.0
        ),
      ),
    );
  }
}