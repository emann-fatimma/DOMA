import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import '../constants.dart';

class ARScreen extends StatefulWidget {
  final String productId;
  final String productName;

  const ARScreen({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  _ARState _state = _ARState.loadingModel;
  String _statusMessage = "Loading 3D model from server...";


  @override
  void initState() {
    super.initState();
    // Unity may have already loaded this model before the screen opened.
    // Send a status check once Unity's message handler is ready (brief warmup).
    Future.delayed(const Duration(milliseconds: 800), _checkModelStatus);

    // Timeout: if no response after 30 s, show an error so the user isn't
    // stuck on a spinner forever.
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _state == _ARState.loadingModel) {
        setState(() {
          _statusMessage =
              "Still loading... Check your connection or try again.";
        });
      }
    });
  }

  void _checkModelStatus() {
    if (!mounted) return;
    sendToUnity('ARMessageHandler', 'CheckProductStatus', widget.productId);
  }

  void _onUnityMessage(String message) {
    debugPrint('Unity: $message');

    if (message == 'MODEL_READY:${widget.productId}') {
      if (_state == _ARState.placed) return;
      setState(() {
        _state = _ARState.modelReady;
        _statusMessage =
            "Model loaded! Point your phone at a flat surface and tap to place.";
      });
      _sendProductToUnity();
    } else if (message == 'MODEL_LOADING:${widget.productId}') {
      // Unity confirmed it's still loading — nothing to do, keep showing spinner
    } else if (message == 'MODEL_FAILED:${widget.productId}') {
      setState(() {
        _state = _ARState.error;
        _statusMessage = "Failed to load 3D model. Check your connection.";
      });
    } else if (message.startsWith('SPAWNING:')) {
      setState(() {
        _state = _ARState.placed;
        _statusMessage = "Tap a detected surface to place the object.";
      });
    }
  }

  void _sendProductToUnity() {
    sendToUnity('ARMessageHandler', 'LoadProductById', widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Unity AR View
          EmbedUnity(onMessageFromUnity: _onUnityMessage),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.productName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator — shown while GLB downloads
          if (_state == _ARState.loadingModel)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Loading 3D model...",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Status message at bottom
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ARState {
  loadingModel,
  modelReady,
  placed,
  error,
}
