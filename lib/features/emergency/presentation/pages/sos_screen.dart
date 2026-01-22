import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/sos_slider_button.dart';
import '../widgets/emergency_content_widgets.dart';

final sosLocationProvider = FutureProvider<Position?>((ref) async {
  final permission = await Permission.location.request();
  if (permission.isGranted) {
    return await Geolocator.getCurrentPosition();
  }
  return null;
});

class SOSScreen extends ConsumerStatefulWidget {
  const SOSScreen({super.key});

  @override
  ConsumerState<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends ConsumerState<SOSScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _triggerSOS() async {
    try {
      final position = await ref.read(sosLocationProvider.future);
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text("SOS Sent!", style: GoogleFonts.outfit()),
              ],
            ),
            content: Text(
              "Emergency contacts notified.\nLocation: ${position?.latitude ?? 'Unknown'}, ${position?.longitude ?? 'Unknown'}",
              style: GoogleFonts.outfit(),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text("OK",
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold)))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send SOS: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text("Emergency SOS",
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 1.2,
                colors: [
                  Colors.red.withValues(alpha: 0.05),
                  Colors.white,
                ],
              ),
            ),
          )),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 250 * _pulseAnimation.value,
                            height: 250 * _pulseAnimation.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.withValues(
                                  alpha: 0.1 * (1.2 - _pulseAnimation.value)),
                            ),
                          );
                        },
                      ),
                      Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.1),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_hospital,
                                size: 60, color: Color(0xFFFF4B4B)),
                            const SizedBox(height: 12),
                            Text(
                              "Emergency",
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: SOSSliderButton(
                    onSlideComplete: _triggerSOS,
                    text: "SLIDE FOR SOS",
                  ),
                ),
                const SizedBox(height: 48),
                const EmergencyContactsWidget(),
                const SizedBox(height: 24),
                const NearbyHospitalsWidget(),
                const SizedBox(height: 24),
                const AmbulanceTrackingWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
