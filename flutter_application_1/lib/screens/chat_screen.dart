import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/models.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:flutter_application_1/screens/video_call_screen.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Doctor doctor;

  const ChatScreen({super.key, required this.doctor});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppProvider>().markConversationAsRead(widget.doctor.id);
      _jumpToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _formatTime(DateTime dateTime) {
    return intl.DateFormat('hh:mm a', 'ar').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final messages = provider.getMessagesForDoctor(widget.doctor.id);
        WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.doctor.name,
                  style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.videocam_rounded, color: Color(0xFF1565C0)),
                tooltip: 'مكالمة فيديو أونلاين',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCallScreen(
                        callPartnerName: widget.doctor.name,
                        callPartnerImage: widget.doctor.imageUrl,
                        isDoctorSide: false,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.phone_rounded, color: Color(0xFF1565C0)),
                tooltip: 'مكالمة صوتية أونلاين',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoCallScreen(
                        callPartnerName: widget.doctor.name,
                        callPartnerImage: widget.doctor.imageUrl,
                        isDoctorSide: false,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Align(
                      alignment: message.isFromUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: message.isFromUser
                              ? const Color(0xFF1565C0)
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(14),
                            topRight: const Radius.circular(14),
                            bottomLeft: Radius.circular(message.isFromUser ? 14 : 4),
                            bottomRight: Radius.circular(message.isFromUser ? 4 : 14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message.text,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color:
                                    message.isFromUser ? Colors.white : const Color(0xFF1A1A2E),
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.sentAt),
                              style: TextStyle(
                                color: message.isFromUser
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.grey.shade500,
                                fontFamily: 'Cairo',
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            provider.sendMessageToDoctor(
                              doctor: widget.doctor,
                              text: _controller.text,
                            );
                            _controller.clear();
                            provider.markConversationAsRead(widget.doctor.id);
                          },
                          icon: const Icon(Icons.send_rounded, color: Color(0xFF1565C0)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: 'اكتب رسالتك...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontFamily: 'Cairo',
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F9FC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) {
                              provider.sendMessageToDoctor(
                                doctor: widget.doctor,
                                text: _controller.text,
                              );
                              _controller.clear();
                              provider.markConversationAsRead(widget.doctor.id);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
