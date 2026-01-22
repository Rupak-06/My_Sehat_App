import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/emergency_contacts_provider.dart';

// --- Emergency Contacts List ---

class EmergencyContactsWidget extends ConsumerWidget {
  const EmergencyContactsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(emergencyContactsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Emergency Contacts",
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                // Close bottom sheet if open before navigating
                Navigator.of(context).popUntil(
                    (route) => route.settings.name != 'sos_bottom_sheet');
                context.push('/emergency-contacts');
              },
              child: Text("Manage",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (contacts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.person_add_outlined,
                    size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  'No emergency contacts added',
                  style:
                      GoogleFonts.outfit(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.of(context).popUntil(
                        (route) => route.settings.name != 'sos_bottom_sheet');
                    context.push('/emergency-contacts');
                  },
                  child: const Text('Add Contacts'),
                ),
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: contacts.map((contact) {
                final colors = [
                  Colors.purple,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.pink
                ];
                final color = colors[contacts.indexOf(contact) % colors.length];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _ContactAvatar(
                    name: contact.relationship ?? contact.name,
                    color: color,
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final String name;
  final Color color;
  const _ContactAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.outfit(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    );
  }
}

// --- Nearby Hospitals List ---

class NearbyHospitalsWidget extends StatelessWidget {
  const NearbyHospitalsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nearby Hospitals",
            style:
                GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const HospitalTile(
            name: "City Hospital", distance: "1.2 km", time: "5 min"),
        const SizedBox(height: 12),
        const HospitalTile(
            name: "Global Health", distance: "2.5 km", time: "12 min"),
      ],
    );
  }
}

class HospitalTile extends StatelessWidget {
  final String name;
  final String distance;
  final String time;

  const HospitalTile(
      {super.key,
      required this.name,
      required this.distance,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.local_hospital_rounded, color: Colors.red),
        ),
        title: Text(name,
            style:
                GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Row(
          children: [
            const Icon(Icons.location_on, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text("$distance • $time",
                style:
                    GoogleFonts.outfit(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
        trailing: FilledButton.icon(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE0F7FA), // Light cyan/teal
            foregroundColor: const Color(0xFF006064), // Darker cyan/teal
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: const Icon(Icons.call, size: 18),
          label: const Text("Call"),
        ),
      ),
    );
  }
}

// --- Ambulance Tracking Card ---

class AmbulanceTrackingWidget extends StatelessWidget {
  const AmbulanceTrackingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Ambulance Tracking",
            style:
                GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Mock Map Background
              Container(color: Colors.grey[100]),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_rounded,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text("Live tracking unavailable",
                        style: GoogleFonts.outfit(color: Colors.grey)),
                  ],
                ),
              ),
              // Overlay for aesthetics
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.03)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
