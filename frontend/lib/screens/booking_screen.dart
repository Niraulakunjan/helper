import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final HelperModel helper;
  const BookingScreen({super.key, required this.helper});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _selectedDate;
  bool _loading = false;
  String? _error;
  bool _success = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (ctx, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _book() async {
    if (_selectedDate == null) { setState(() => _error = 'Please select a date'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService.createBooking(widget.helper.id, _selectedDate!.toIso8601String());
      setState(() { _success = true; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Book Service', style: TextStyle(color: Colors.white)), iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _success ? _successView() : _formView(),
      ),
    );
  }

  Widget _successView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, color: Color(0xFF00D4AA), size: 80),
        const SizedBox(height: 16),
        const Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Your booking with ${widget.helper.user.username} is pending confirmation.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  Widget _formView() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: const Color(0xFF00D4AA).withOpacity(0.2), child: Text(widget.helper.user.username[0].toUpperCase(), style: const TextStyle(color: Color(0xFF00D4AA), fontWeight: FontWeight.bold))),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.helper.user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(widget.helper.serviceName, style: const TextStyle(color: Color(0xFF00D4AA))),
              Text('NPR ${widget.helper.price.toStringAsFixed(0)} / visit', style: const TextStyle(color: Colors.white54)),
            ]),
          ],
        ),
      ),
      const SizedBox(height: 28),
      const Text('Select Date', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: _pickDate,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _selectedDate != null ? const Color(0xFF00D4AA) : Colors.white24),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFF00D4AA)),
              const SizedBox(width: 12),
              Text(
                _selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'Tap to select date',
                style: TextStyle(color: _selectedDate != null ? Colors.white : Colors.white38, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: Colors.redAccent)),
      ],
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _book,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4AA), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    ],
  );
}
