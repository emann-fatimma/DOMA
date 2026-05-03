// // lib/screens/payment/safepay_webview_screen.dart
//
// import 'package:flutter/material.dart';
// // import 'package:webview_flutter/webview_flutter.dart';
//
// class SafepayWebViewScreen extends StatefulWidget {
//   final String checkoutUrl;
//   final VoidCallback onPaymentSuccess;  // ← add this
//   final VoidCallback onPaymentCancel;   // ← add this
//
//   const SafepayWebViewScreen({
//     required this.checkoutUrl,
//     required this.onPaymentSuccess,
//     required this.onPaymentCancel,
//     super.key,
//   });
//
//   @override
//   State<SafepayWebViewScreen> createState() => _SafepayWebViewScreenState();
// }
//
// class _SafepayWebViewScreenState extends State<SafepayWebViewScreen> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (_) => setState(() => _isLoading = true),
//           onPageFinished: (_) => setState(() => _isLoading = false),
//           onNavigationRequest: (request) {
//             final url = request.url;
//
//             if (url.startsWith('doma://payment/success')) {
//               Navigator.pop(context); // close WebView
//               widget.onPaymentSuccess(); // ← trigger success callback
//               return NavigationDecision.prevent;
//             }
//
//             if (url.startsWith('doma://payment/cancel')) {
//               Navigator.pop(context); // close WebView
//               widget.onPaymentCancel(); // ← trigger cancel callback
//               return NavigationDecision.prevent;
//             }
//
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse(widget.checkoutUrl));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Checkout'),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () {
//             Navigator.pop(context);
//             widget.onPaymentCancel();
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: _controller),
//           if (_isLoading)
//             const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }