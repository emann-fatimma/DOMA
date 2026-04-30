import 'package:flutter/material.dart';
import '../services/rag_service.dart';
import '../models/product_model.dart'; // ChatMessage & RagProduct live here
import '../widgets/rag/chat_bubble.dart';
import '../widgets/rag/empty_state.dart';

class RagSearchScreen extends StatefulWidget {
  const RagSearchScreen({super.key});

  @override
  State<RagSearchScreen> createState() => _RagSearchScreenState();
}

class _RagSearchScreenState extends State<RagSearchScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _ragService = RagService();

  List<ChatMessage> _messages = [];
  List<Map<String, dynamic>> _history = [];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty || _loading) return;

    _controller.clear();

    setState(() {
      _loading = true;
      _error = null;
      _messages = [..._messages, ChatMessage(role: 'user', content: query)];
    });

    _scrollToBottom();

    try {
      final result = await _ragService.generate(
        prompt: query,
        history: _history,
      );

      _history = [
        ..._history,
        {'role': 'user', 'content': query},
        {'role': 'assistant', 'content': result['result']},
      ];

      setState(() {
        _messages = [
          ..._messages,
          ChatMessage(
            role: 'assistant',
            content: result['result'] as String,
            products: result['products'] as List<RagProduct>, // ✅ RagProduct
          ),
        ];
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to connect to Genie. Please try again.';
      });
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F0E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a3126)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'DOMA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Color(0xFFBB4E2C),
              ),
            ),
            Text(
              'Curate your space.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1a3126),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFBB4E2C),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: _messages.isEmpty
                ? const RagEmptyState()
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _LoadingBubble();
                      }
                      return ChatBubble(message: _messages[index]);
                    },
                  ),
          ),
          _ChatInputBar(
            controller: _controller,
            loading: _loading,
            onSubmit: _search,
          ),
        ],
      ),
    );
  }
}

class _LoadingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: const Color(0xFFF2F0E5)),
          ),
          child: Row(children: List.generate(3, (i) => _Dot(delay: i * 150))),
        ),
      ],
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(
      begin: 0.0,
      end: -6.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        transform: Matrix4.translationValues(0, _anim.value, 0),
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Color(0xFFBB4E2C),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSubmit;

  const _ChatInputBar({
    required this.controller,
    required this.loading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF2F0E5))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !loading,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: loading
                    ? 'Waiting for Genie...'
                    : 'Describe the furniture you are looking for...',
                hintStyle: TextStyle(
                  color: const Color(0xFF1a3126).withOpacity(0.3),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF9F8F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFE4E0D0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFE4E0D0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Color(0xFFBB4E2C)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: loading ? null : onSubmit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: loading
                    ? const Color(0xFFBB4E2C).withOpacity(0.5)
                    : const Color(0xFFBB4E2C),
                borderRadius: BorderRadius.circular(30),
              ),
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'SEARCH',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
