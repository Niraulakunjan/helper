import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart';

class HelperDashboardScreen extends StatefulWidget {
  const HelperDashboardScreen({super.key});
  @override
  State<HelperDashboardScreen> createState() => _HelperDashboardScreenState();
}

class _HelperDashboardScreenState extends State<HelperDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BookingModel> _bookings = [];
  bool _loading = true;
  String? _error;

  static const _teal = Color(0xFF00D4AA);
  static const _purple = Color(0xFF7B61FF);
  static const _bg = Color(0xFF0A1628);
  static const _card = Color(0xFF0F2040);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bookings = await ApiService.getMyBookings();
      setState(() {
        _bookings = bookings;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    try {
      await ApiService.updateBookingStatus(bookingId, status);
      await _loadBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Booking ${status.toUpperCase()}'),
          backgroundColor: status == 'accepted' ? _teal : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted': return _teal;
      case 'rejected': return Colors.redAccent;
      case 'completed': return Colors.blueAccent;
      default: return Colors.orangeAccent;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted': return Icons.check_circle_outline;
      case 'rejected': return Icons.cancel_outlined;
      case 'completed': return Icons.task_alt;
      default: return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    // Deduplicate contacts from bookings for Messages tab
    final Map<int, UserModel> contacts = {};
    for (final b in _bookings) {
      contacts[b.user.id] = b.user;
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_purple, _teal]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Helper Panel',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(user?.username ?? '',
                style: const TextStyle(color: _purple, fontSize: 11)),
          ]),
        ]),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.white54),
            tooltip: 'Logout',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _teal,
          indicatorWeight: 3,
          labelColor: _teal,
          unselectedLabelColor: Colors.white38,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded, size: 20), text: 'Overview'),
            Tab(icon: Icon(Icons.list_alt_rounded, size: 20), text: 'Requests'),
            Tab(icon: Icon(Icons.chat_rounded, size: 20), text: 'Messages'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(auth),
          _buildRequestsTab(),
          _buildMessagesTab(auth, contacts.values.toList()),
        ],
      ),
    );
  }

  // ─── TAB 1: OVERVIEW ─────────────────────────────────────────────────────
  Widget _buildOverviewTab(AuthProvider auth) {
    final pending = _bookings.where((b) => b.status == 'pending').length;
    final accepted = _bookings.where((b) => b.status == 'accepted').length;
    final completed = _bookings.where((b) => b.status == 'completed').length;

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: _purple,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_purple, Color(0xFF3B2DB0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: _purple.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.15),
                child: Text(
                  (auth.user?.username ?? 'H')[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Welcome back,',
                      style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                  Text(auth.user?.username ?? 'Helper',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('🔧 Helper Account',
                        style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ]),
              ),
            ]),
          ),

          const SizedBox(height: 24),
          const Text('Your Stats',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          Row(children: [
            _statCard('Pending', pending, Icons.schedule_rounded, Colors.orangeAccent),
            const SizedBox(width: 12),
            _statCard('Active', accepted, Icons.check_circle_outline, _teal),
            const SizedBox(width: 12),
            _statCard('Done', completed, Icons.task_alt_rounded, Colors.blueAccent),
          ]),

          const SizedBox(height: 26),
          Row(children: [
            const Text('Pending Requests',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const Spacer(),
            if (pending > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
                ),
                child: Text('$pending new',
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
              ),
          ]),
          const SizedBox(height: 14),

          if (_loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(color: _purple),
            ))
          else if (_error != null)
            _errorWidget()
          else
            ..._buildPendingCards(),
        ]),
      ),
    );
  }

  List<Widget> _buildPendingCards() {
    final pending = _bookings.where((b) => b.status == 'pending').toList();
    if (pending.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(30),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10)),
          child: Column(children: [
            const Icon(Icons.inbox_rounded, color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            const Text('No pending requests',
                style: TextStyle(color: Colors.white38, fontSize: 15)),
          ]),
        ),
      ];
    }
    return pending.map((b) => _bookingCard(b, showActions: true)).toList();
  }

  // ─── TAB 2: REQUESTS ────────────────────────────────────────────────────
  Widget _buildRequestsTab() {
    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: _purple,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: _purple))
          : _error != null
              ? _errorWidget()
              : _bookings.isEmpty
                  ? _emptyState(Icons.list_alt_rounded, 'No bookings yet')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bookings.length,
                      itemBuilder: (_, i) {
                        final b = _bookings[i];
                        return _bookingCard(b, showActions: b.status == 'pending');
                      },
                    ),
    );
  }

  // ─── TAB 3: MESSAGES ────────────────────────────────────────────────────
  Widget _buildMessagesTab(AuthProvider auth, List<UserModel> contacts) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _purple));
    if (contacts.isEmpty) return _emptyState(Icons.chat_bubble_outline_rounded, 'No messages yet');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: contacts.length,
      itemBuilder: (_, i) {
        final contact = contacts[i];
        // Find the latest booking with this user
        final lastBooking = _bookings.lastWhere((b) => b.user.id == contact.id);
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: _purple.withOpacity(0.18),
            child: Text(contact.username[0].toUpperCase(),
                style: const TextStyle(
                    color: _purple, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          title: Text(contact.username,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _statusColor(lastBooking.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(lastBooking.status.toUpperCase(),
                  style: TextStyle(
                      color: _statusColor(lastBooking.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text(lastBooking.date.split('T')[0],
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ]),
          trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chat_rounded, color: _teal, size: 20),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                otherUser: contact,
                currentUserId: auth.user?.id ?? 0,
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────────────────────
  Widget _bookingCard(BookingModel b, {required bool showActions}) {
    final statusColor = _statusColor(b.status);
    final auth = context.read<AuthProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: _purple.withOpacity(0.18),
              child: Text(b.user.username[0].toUpperCase(),
                  style: const TextStyle(
                      color: _purple, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.user.username,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 12),
                  const SizedBox(width: 4),
                  Text(b.date.split('T')[0],
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ]),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_statusIcon(b.status), color: statusColor, size: 12),
                const SizedBox(width: 4),
                Text(b.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ),
        if (showActions)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(children: [
              Expanded(
                child: _actionBtn(
                    'Accept', _teal, Icons.check_rounded, () => _updateStatus(b.id, 'accepted')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionBtn('Reject', Colors.redAccent, Icons.close_rounded,
                    () => _updateStatus(b.id, 'rejected')),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      otherUser: b.user,
                      currentUserId: auth.user?.id ?? 0,
                    ),
                  ),
                ),
                icon: const Icon(Icons.chat_rounded, color: _purple, size: 22),
                tooltip: 'Chat',
              ),
            ]),
          ),
      ]),
    );
  }

  Widget _actionBtn(String label, Color color, IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ]),
        ),
      );

  Widget _statCard(String label, int value, IconData icon, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value.toString(),
                style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ]),
        ),
      );

  Widget _emptyState(IconData icon, String message) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: Colors.white12, size: 60),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: Colors.white38, fontSize: 15)),
        ]),
      );

  Widget _errorWidget() => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 10),
            Text(_error ?? 'Error', style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadBookings,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: _purple),
            ),
          ]),
        ),
      );
}
