import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});
  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  late Future<List<BookingModel>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = ApiService.getMyBookings();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return Colors.greenAccent;
      case 'rejected': return Colors.redAccent;
      case 'completed': return const Color(0xFF00D4AA);
      default: return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BookingModel>>(
      future: _bookingsFuture,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA)));
        if (snap.hasError) return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.redAccent)));
        final bookings = snap.data!;
        if (bookings.isEmpty) return const Center(child: Text('No bookings yet', style: TextStyle(color: Colors.white54)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (_, i) {
            final b = bookings[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: const Color(0xFF00D4AA).withOpacity(0.15), child: Text(b.helper.user.username[0].toUpperCase(), style: const TextStyle(color: Color(0xFF00D4AA)))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.helper.user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(b.helper.serviceName, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    Text(b.date.split('T')[0], style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _statusColor(b.status).withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(b.status.toUpperCase(), style: TextStyle(color: _statusColor(b.status), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
