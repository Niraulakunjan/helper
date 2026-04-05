import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final UserModel otherUser;
  final int currentUserId;

  const ChatScreen({super.key, required this.otherUser, required this.currentUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late WebSocketChannel _channel;
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  bool _loadingHistory = true;
  bool _isOtherOnline = false;
  bool _isOtherTyping = false;
  bool _isSendingType = false;

  Timer? _typingTimer;

  // Animated dots controller
  late AnimationController _dotsController;
  late Animation<double> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _dotsAnimation = Tween<double>(begin: 0, end: 1).animate(_dotsController);
    _loadHistory();
    _connectWS();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await ApiService.getChatHistory(widget.otherUser.id);
      if (!mounted) return;
      setState(() {
        _messages.addAll(history.map((m) => {
          'content': m.content,
          'sender_id': m.sender.id,
          'timestamp': m.timestamp,
        }));
        _loadingHistory = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  void _connectWS() {
    final ids = [widget.currentUserId, widget.otherUser.id]..sort();
    final url = 'ws://127.0.0.1:8000/ws/chat/${ids[0]}/${ids[1]}/';
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.stream.listen((data) {
      if (!mounted) return;
      final msg = jsonDecode(data as String);
      final type = msg['type'] ?? 'message';

      switch (type) {
        case 'message':
          setState(() => _messages.add({'content': msg['message'], 'sender_id': msg['sender_id'], 'timestamp': msg['timestamp']}));
          _scrollToBottom();
          break;

        case 'typing':
          if (msg['sender_id'] != widget.currentUserId) {
            setState(() => _isOtherTyping = msg['is_typing'] == true);
            if (_isOtherTyping) _scrollToBottom();
          }
          break;

        case 'presence':
          if (msg['user_id'] == widget.otherUser.id) {
            setState(() => _isOtherOnline = msg['status'] == 'online');
          }
          break;
      }
    }, onDone: () {
      if (mounted) setState(() => _isOtherOnline = false);
    });

    // Ask for the other user's current presence
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _channel.sink.add(jsonEncode({'type': 'check_presence', 'other_id': widget.otherUser.id}));
      }
    });
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _channel.sink.add(jsonEncode({
      'type': 'message',
      'message': text,
      'sender_id': widget.currentUserId,
      'receiver_id': widget.otherUser.id,
    }));
    _msgCtrl.clear();
    _sendStopTyping();
  }

  void _onTextChanged(String value) {
    if (value.isNotEmpty && !_isSendingType) {
      _isSendingType = true;
      _channel.sink.add(jsonEncode({'type': 'typing', 'sender_id': widget.currentUserId}));
    }
    // Debounce stop_typing: send it 1.5s after user stops typing
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), _sendStopTyping);
  }

  void _sendStopTyping() {
    if (_isSendingType) {
      _isSendingType = false;
      _channel.sink.add(jsonEncode({'type': 'stop_typing', 'sender_id': widget.currentUserId}));
    }
    _typingTimer?.cancel();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _dotsController.dispose();
    _channel.sink.close();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_isOtherTyping) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A3347),
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF00D4AA).withAlpha(40),
                child: Text(
                  widget.otherUser.username[0].toUpperCase(),
                  style: const TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 11, height: 11,
                  decoration: BoxDecoration(
                    color: _isOtherOnline ? const Color(0xFF25D366) : Colors.grey.shade600,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1A3347), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUser.username, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isOtherTyping
                    ? const Text('typing...', key: ValueKey('typing'), style: TextStyle(color: Color(0xFF25D366), fontSize: 12))
                    : Text(
                        _isOtherOnline ? 'online' : 'offline',
                        key: ValueKey(_isOtherOnline),
                        style: TextStyle(color: _isOtherOnline ? const Color(0xFF25D366) : Colors.grey, fontSize: 12),
                      ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.videocam_outlined, color: Colors.white70), onPressed: () {}),
        IconButton(icon: const Icon(Icons.call_outlined, color: Colors.white70), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert, color: Colors.white70), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)));
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white.withAlpha(40)),
          const SizedBox(height: 12),
          const Text('No messages yet\nSay hello! 👋', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38)),
        ]),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg = _messages[i];
        final isMe = msg['sender_id'] == widget.currentUserId;
        final showDate = i == 0 || _isDifferentDay(_messages[i - 1]['timestamp'], msg['timestamp']);
        return Column(
          children: [
            if (showDate) _buildDateDivider(msg['timestamp']),
            _buildBubble(msg['content'], msg['timestamp'], isMe),
          ],
        );
      },
    );
  }

  Widget _buildDateDivider(String? timestamp) {
    String label = 'Today';
    if (timestamp != null) {
      try {
        final dt = DateTime.parse(timestamp).toLocal();
        final now = DateTime.now();
        if (dt.day != now.day || dt.month != now.month || dt.year != now.year) {
          label = '${dt.day}/${dt.month}/${dt.year}';
        }
      } catch (_) {}
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(child: Divider(color: Colors.white12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ),
        Expanded(child: Divider(color: Colors.white12)),
      ]),
    );
  }

  Widget _buildBubble(String content, String? timestamp, bool isMe) {
    String timeStr = '';
    if (timestamp != null) {
      try {
        final dt = DateTime.parse(timestamp).toLocal();
        timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF005C4B) : const Color(0xFF1F2C34),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(content, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.3)),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(timeStr, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 14, color: Color(0xFF34B7F1)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C34),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4), bottomRight: Radius.circular(16),
          ),
        ),
        child: AnimatedBuilder(
          animation: _dotsAnimation,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final delay = i / 3;
              final t = (_dotsAnimation.value - delay).clamp(0.0, 1.0);
              final opacity = (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.3, 1.0);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4AA).withAlpha((opacity * 255).toInt()),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3347),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 8)],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.white54, size: 26), onPressed: () {}),
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                maxLines: 5, minLines: 1,
                onChanged: _onTextChanged,
                decoration: InputDecoration(
                  hintText: 'Message',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF2A3942),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: IconButton(icon: const Icon(Icons.attach_file, color: Colors.white38), onPressed: () {}),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 6),
            ListenableBuilder(
              listenable: _msgCtrl,
              builder: (_, __) {
                final hasText = _msgCtrl.text.trim().isNotEmpty;
                return GestureDetector(
                  onTap: hasText ? _sendMessage : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: hasText ? const Color(0xFF00D4AA) : const Color(0xFF2A3942),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasText ? Icons.send_rounded : Icons.mic,
                      color: hasText ? Colors.white : Colors.white54,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _isDifferentDay(String? a, String? b) {
    if (a == null || b == null) return false;
    try {
      final da = DateTime.parse(a).toLocal();
      final db = DateTime.parse(b).toLocal();
      return da.day != db.day || da.month != db.month || da.year != db.year;
    } catch (_) {
      return false;
    }
  }
}
