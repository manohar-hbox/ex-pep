import 'package:flutter/material.dart';
import 'dart:async'; // Add Timer import
import 'package:flutter_localizations/flutter_localizations.dart'; // Add for MaterialLocalizations

class DraggableCallDialog extends StatefulWidget {
  final String callerName;
  final String callerNumber;
  final bool isActive;
  final bool isMuted;
  final Function() onAccept;
  final Function() onReject;
  final Function() onHangup;
  final Function() onToggleMute;

  const DraggableCallDialog({
    Key? key,
    required this.callerName,
    required this.callerNumber,
    this.isActive = false,
    this.isMuted = false,
    required this.onAccept,
    required this.onReject,
    required this.onHangup,
    required this.onToggleMute,
  }) : super(key: key);

  @override
  State<DraggableCallDialog> createState() => _DraggableCallDialogState();
}

class _DraggableCallDialogState extends State<DraggableCallDialog> {
  Offset position = Offset(20, 50);
  bool isMinimized = false;
  String callDuration = "00:00";
  late DateTime callStartTime;
  Timer? callTimer; // Make nullable to avoid late initialization issues

  @override
  void initState() {
    super.initState();
    if (widget.isActive) {
      callStartTime = DateTime.now();
      _startCallTimer();
    }
  }

  void _startCallTimer() {
    callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) { // Check if widget is still mounted
        final duration = DateTime.now().difference(callStartTime);
        final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
        final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
        setState(() {
          callDuration = "$minutes:$seconds";
        });
      }
    });
  }

  @override
  void dispose() {
    callTimer?.cancel(); // Cancel timer if it exists
    super.dispose();
  }

  @override
  void didUpdateWidget(DraggableCallDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      callStartTime = DateTime.now();
      _startCallTimer();
    } else if (oldWidget.isActive && !widget.isActive && callTimer != null) {
      callTimer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position = Offset(
              position.dx + details.delta.dx,
              position.dy + details.delta.dy,
            );
          });
        },
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: isMinimized ? 80 : 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: isMinimized
                ? _buildMinimizedView()
                : widget.isActive
                    ? _buildActiveCallView()
                    : _buildIncomingCallView(),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimizedView() {
    return InkWell(
      onTap: () => setState(() => isMinimized = false),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: widget.isActive ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              child: Icon(
                widget.isActive ? Icons.call : Icons.call_received,
                color: widget.isActive ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            SizedBox(height: 5),
            Text(
              widget.isActive ? callDuration : "Call",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingCallView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader("Incoming Call"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.orange.withOpacity(0.2),
                child: Icon(
                  Icons.call_received,
                  color: Colors.orange,
                  size: 35,
                ),
              ),
              SizedBox(height: 15),
              Text(
                widget.callerName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                widget.callerNumber,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(
                    onTap: widget.onReject,
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: "Reject",
                  ),
                  _buildCallButton(
                    onTap: widget.onAccept,
                    icon: Icons.call,
                    color: Colors.green,
                    label: "Accept",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCallView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader("Active Call"),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.green.withOpacity(0.2),
                child: Icon(
                  Icons.call,
                  color: Colors.green,
                  size: 35,
                ),
              ),
              SizedBox(height: 15),
              Text(
                widget.callerName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                callDuration,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(
                    onTap: widget.onToggleMute,
                    icon: widget.isMuted ? Icons.mic_off : Icons.mic,
                    color: widget.isMuted ? Colors.orange : Colors.grey,
                    label: widget.isMuted ? "Unmute" : "Mute",
                  ),
                  _buildCallButton(
                    onTap: widget.onHangup,
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: "End",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () => setState(() => isMinimized = true),
                child: Icon(Icons.minimize, size: 20),
              ),
              SizedBox(width: 10),
              InkWell(
                onTap: () {
                  if (widget.isActive) {
                    widget.onHangup();
                  } else {
                    widget.onReject();
                  }
                },
                child: Icon(Icons.close, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class DraggableCallOverlay extends StatefulWidget {
  final String callerName;
  final String callerNumber;
  final bool isActive;
  final bool isMuted;
  final Function() onAccept;
  final Function() onReject;
  final Function() onHangup;
  final Function() onToggleMute;

  const DraggableCallOverlay({
    Key? key,
    required this.callerName,
    required this.callerNumber,
    this.isActive = false,
    this.isMuted = false,
    required this.onAccept,
    required this.onReject,
    required this.onHangup,
    required this.onToggleMute,
  }) : super(key: key);

  @override
  State<DraggableCallOverlay> createState() => _DraggableCallOverlayState();
}

class _DraggableCallOverlayState extends State<DraggableCallOverlay> {
  @override
  Widget build(BuildContext context) {
    // Use Directionality and LocalizationsDelegate to provide required localizations
    // This fixes the "No MaterialLocalizations found" error
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: const Locale('en', 'US'),
        delegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DraggableCallDialog(
                callerName: widget.callerName,
                callerNumber: widget.callerNumber,
                isActive: widget.isActive,
                isMuted: widget.isMuted,
                onAccept: widget.onAccept,
                onReject: widget.onReject,
                onHangup: widget.onHangup,
                onToggleMute: widget.onToggleMute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

