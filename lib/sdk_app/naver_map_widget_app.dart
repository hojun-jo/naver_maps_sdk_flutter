part of 'naver_maps_sdk_flutter_app.dart';

class NaverMapWidget extends StatelessWidget {
  final MapOptions? mapOptions;
  final NaverMapManager naverMapManager;
  final bool showLoading;

  const NaverMapWidget({
    super.key,
    required this.naverMapManager,
    this.mapOptions,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    naverMapManager.onTapLink = (url) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SafeArea(
            child: Scaffold(body: _InAppWebViewPage(url: url)),
          ),
        ),
      );
    };

    return FutureBuilder<void>(
      future: naverMapManager.onPageFinished,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return showLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        naverMapManager._initializeNaverMap(mapOptions);

        return WebViewWidget(controller: naverMapManager._controller);
      },
    );
  }
}

class _InAppWebViewPage extends StatefulWidget {
  final String url;
  
  const _InAppWebViewPage({required this.url});

  @override
  State<_InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<_InAppWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            debugPrint('InAppWebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    try {
      _controller.loadHtmlString('<!doctype html><html><body></body></html>');
    } catch (e) {
      debugPrint('InAppWebView dispose error: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
