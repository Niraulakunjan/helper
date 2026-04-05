import 'package:flutter/material.dart';
import '../models/models.dart';
import 'chat_screen.dart';
import 'booking_screen.dart';

class HelperDetailScreen extends StatelessWidget {
  final HelperModel helper;
  final int currentUserId;

  const HelperDetailScreen({super.key, required this.helper, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(helper.user.username, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 52,
                backgroundColor: const Color(0xFF00D4AA).withOpacity(0.2),
                child: Text(helper.user.username[0].toUpperCase(), style: const TextStyle(fontSize: 42, color: Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Center(child: Text(helper.user.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
            Center(child: Text(helper.serviceName, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 16))),
            const SizedBox(height: 24),
            _infoCard([
              _info(Icons.star, 'Rating', '${helper.rating.toStringAsFixed(1)} / 5.0'),
              _info(Icons.location_on, 'Location', helper.location),
              _info(Icons.attach_money, 'Price', 'NPR ${helper.price.toStringAsFixed(0)} / visit'),
              _info(Icons.phone, 'Phone', helper.user.phone.isNotEmpty ? helper.user.phone : 'N/A'),
            ]),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingScreen(helper: helper))),
                    icon: const Icon(Icons.calendar_today, color: Colors.white),
                    label: const Text('Book Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4AA),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(otherUser: helper.user, currentUserId: currentUserId))),
                    icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF00D4AA)),
                    label: const Text('Chat', style: TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00D4AA)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(children: children),
  );

  Widget _info(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF00D4AA), size: 20),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ],
    ),
  );
}
