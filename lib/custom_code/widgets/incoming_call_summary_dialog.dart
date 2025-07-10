// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

// Custom imports
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:timezone/timezone.dart' as tz;

/// A dialog that displays a summary of an incoming call.
class IncomingCallSummaryDialog extends StatefulWidget {
  const IncomingCallSummaryDialog({
    Key? key,
    required this.callerName,
    required this.callerNumber,
    required this.callTime,
    required this.callDate,
    required this.callType,
    required this.callSid,
  }) : super(key: key);

  final String callerName;
  final String callerNumber;
  final String callTime;
  final String callDate;
  final String callType;
  final String callSid;

  @override
  _IncomingCallSummaryDialogState createState() => _IncomingCallSummaryDialogState();
}

class _IncomingCallSummaryDialogState extends State<IncomingCallSummaryDialog> {
  // Call duration information
  String _callDuration = 'Calculating...';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Call status info
  Color _statusColor = Colors.blue;
  IconData _statusIcon = Icons.call_end;
  String _statusText = 'Call Ended';

  @override
  void initState() {
    super.initState();
    _fetchCallDetails();
    _determineCallStatus();
  }

  // Determine call status, icon and color
  void _determineCallStatus() {
    // Default values for an incoming call
    _statusColor = Colors.blue;
    _statusIcon = Icons.call_received;
    _statusText = 'Incoming Call';

    // You can enhance this logic based on your actual call status data
    if (widget.callType.toLowerCase().contains('missed')) {
      _statusColor = Colors.orange;
      _statusIcon = Icons.phone_missed;
      _statusText = 'Missed Call';
    } else if (widget.callType.toLowerCase().contains('reject')) {
      _statusColor = Colors.red;
      _statusIcon = Icons.call_end;
      _statusText = 'Rejected Call';
    } else if (widget.callType.toLowerCase().contains('completed')) {
      _statusColor = Colors.green;
      _statusIcon = Icons.check;
      _statusText = 'Call Completed';
    } else if (widget.callType.toLowerCase().contains('transferred')) {
      _statusColor = Colors.orange;
      _statusIcon = Icons.swap_calls;
      _statusText = 'Call Transferred';
    }
  }

  // Fetch additional call details if available
  Future<void> _fetchCallDetails() async {
    if (widget.callSid.isEmpty) {
      setState(() {
        _callDuration = 'Unknown';
        _isLoading = false;
      });
      return;
    }

    try {
      // Set a timeout for fetching call details
      final result = await Future.delayed(
        const Duration(seconds: 2),
        () => '00:32'  // Mock duration for now, would be replaced with actual API call
      );

      if (mounted) {
        setState(() {
          _callDuration = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load call details: $e';
          _isLoading = false;
          _callDuration = 'Unknown';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      backgroundColor: Colors.white,
      child: Container(
        width: 400, // Fixed width for more spacious dialog
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Close button in top-right corner
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, size: 24),
                padding: EdgeInsets.all(12),
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false to indicate close
                },
              ),
            ),

            // Header with title
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                'Call Summary ICS Dialog',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),

            // Status box with dynamic colors and status
            Container(
              width: double.infinity,
              color: _statusColor.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 28),
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _statusIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Call details
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caller name
                  callInfoRow(
                    'Caller:',
                    widget.callerName,
                  ),
                  Divider(height: 24, color: Colors.grey[300]),

                  // Phone number if available
                  if (widget.callerNumber.isNotEmpty) ...[
                    callInfoRow(
                      'Phone Number:',
                      widget.callerNumber,
                    ),
                    Divider(height: 24, color: Colors.grey[300]),
                  ],

                  // Call duration
                  callInfoRow(
                    'Duration:',
                    _isLoading ? 'Calculating...' : _callDuration,
                  ),
                  Divider(height: 24, color: Colors.grey[300]),

                  // Call date
                  callInfoRow(
                    'Date:',
                    widget.callDate,
                  ),
                  Divider(height: 24, color: Colors.grey[300]),

                  // Call time
                  callInfoRow(
                    'Time:',
                    widget.callTime,
                  ),
                  Divider(height: 24, color: Colors.grey[300]),
                ],
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Call back button
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.call, color: Colors.white),
                      label: Text('Call Back'),
                      onPressed: () {
                        Navigator.of(context).pop(true); // Return true to indicate call back
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Close button
                  Expanded(
                    child: OutlinedButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop(false); // Return false to indicate close
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building call info rows
  Widget callInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120, // Fixed width for labels
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
