import 'dart:async';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  final String callPartnerName;
  final String callPartnerImage;
  final bool isDoctorSide;

  const VideoCallScreen({
    super.key,
    required this.callPartnerName,
    required this.callPartnerImage,
    this.isDoctorSide = false,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isCalling = true;
  int _secondsElapsed = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate connection after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isCalling = false;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111729), // Premium dark theme for video feed
      body: Stack(
        children: [
          // Background Video feed (simulated)
          Positioned.fill(
            child: _isCalling
                ? _buildCallingScreen()
                : (_isCameraOff
                    ? _buildVideoPlaceholder(widget.callPartnerName, widget.callPartnerImage, isPartner: true)
                    : _buildMockVideoFeed(widget.callPartnerImage)),
          ),

          // Outgoing Self Camera View (Picture in Picture overlay)
          if (!_isCalling)
            Positioned(
              top: 50,
              right: 20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _isCameraOff
                    ? const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white38, size: 24),
                      )
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              widget.isDoctorSide
                                  ? 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=2070&auto=format&fit=crop'
                                  : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.person, color: Colors.white30, size: 30),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'أنت',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

          // Header Overlay (Partner Info & Duration)
          Positioned(
            top: 50,
            left: 20,
            child: _isCalling
                ? const SizedBox.shrink()
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_secondsElapsed),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Call Controls Bar (Bottom)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isCalling)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      widget.callPartnerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Cairo',
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mute Button
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      isActive: _isMuted,
                      color: Colors.white.withOpacity(0.12),
                      onTap: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    // Hangup Button (Red)
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isCalling ? 'تم إلغاء الاتصال' : 'انتهت الاستشارة الطبية عبر مكالمة الفيديو بنجاح',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                            backgroundColor: const Color(0xFF1565C0),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent,
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Camera Toggle Button
                    _buildControlButton(
                      icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                      isActive: _isCameraOff,
                      color: Colors.white.withOpacity(0.12),
                      onTap: () {
                        setState(() {
                          _isCameraOff = !_isCameraOff;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF111729) : Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCallingScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Calling Avatar with Pulsing Effect
          _buildPulsingAvatar(widget.callPartnerImage),
          const SizedBox(height: 32),
          Text(
            widget.callPartnerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isDoctorSide ? 'اتصال بالمريض...' : 'اتصال بالطبيب...',
            style: const TextStyle(
              color: Color(0xFF26C6DA),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const Spacer(),
          const Text(
            'يرجى التأكد من استقرار الإنترنت وجودة الكاميرا والصوت',
            style: TextStyle(
              color: Colors.white30,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildPulsingAvatar(String image) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated pulsing rings
          ...List.generate(3, (index) {
            return AnimatedContainer(
              duration: const Duration(seconds: 2),
              width: 140.0 + (index * 20),
              height: 140.0 + (index * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF26C6DA).withOpacity(0.05),
              ),
            );
          }),
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(image),
            backgroundColor: const Color(0xFF1E293B),
            child: image.isEmpty
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMockVideoFeed(String image) {
    // Beautiful interactive telehealth workspace image
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0F172A),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            image.isNotEmpty ? image : 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=2070&auto=format&fit=crop',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.person, color: Colors.white24, size: 80),
            ),
          ),
          // Subtle premium scanner effect overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder(String name, String image, {required bool isPartner}) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 54,
            backgroundImage: NetworkImage(image),
            backgroundColor: const Color(0xFF1E293B),
          ),
          const SizedBox(height: 20),
          Text(
            '$name (الكاميرا مغلقة)',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
