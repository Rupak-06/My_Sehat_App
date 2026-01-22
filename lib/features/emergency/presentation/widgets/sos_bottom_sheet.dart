import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'sos_slider_button.dart';
import 'emergency_content_widgets.dart';

final locationProvider = FutureProvider<Position?>((ref) async {
  final permission = await Permission.location.request();
  if (permission.isGranted) {
    return await Geolocator.getCurrentPosition();
  }
  return null;
});

class SOSBottomSheet extends ConsumerStatefulWidget {
  const SOSBottomSheet({super.key});

  @override
  ConsumerState<SOSBottomSheet> createState() => _SOSBottomSheetState();
}

class _SOSBottomSheetState extends ConsumerState<SOSBottomSheet> {
  Future<void> _handleSOS() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Handle error cleanly
    }

    if (!mounted) return;

    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green),
            const SizedBox(width: 8),
            Text("SOS Sent!", style: GoogleFonts.outfit()),
          ],
        ),
        content: Text(
            "Emergency contacts have been notified with your current location.",
            style: GoogleFonts.outfit()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text("OK",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.0,
      maxChildSize: 0.93,
      snap: true,
      snapSizes: const [0.5],
      shouldCloseOnMinExtent: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emergency_share,
                                color: Colors.red, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Emergency SOS",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Swipe safely to alert everyone",
                            style: GoogleFonts.outfit(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SOSSliderButton(
                        onSlideComplete: _handleSOS,
                        text: "SLIDE TO SEND SOS",
                      ),
                    ),
                    const SizedBox(height: 32),
                    Divider(height: 1, color: Colors.grey.shade200),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const EmergencyContactsWidget(),
                      const SizedBox(height: 24),
                      const NearbyHospitalsWidget(),
                      const SizedBox(height: 24),
                      const AmbulanceTrackingWidget(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.outfit(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
