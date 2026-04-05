import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'helper_detail_screen.dart';
import 'bookings_screen.dart';
import 'login_screen.dart';
import 'helper_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  List<ServiceModel> _services = [];
  List<HelperModel> _helpers = [];
  int? _selectedServiceId;
  final _searchCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final services = await ApiService.getServices();
      final helpers = await ApiService.getHelpers();
      setState(() { _services = services; _helpers = helpers; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _filterHelpers() async {
    setState(() => _loading = true);
    try {
      final helpers = await ApiService.getHelpers(serviceId: _selectedServiceId, location: _searchCtrl.text.trim());
      setState(() { _helpers = helpers; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Route helpers to their own dashboard
    if (auth.user?.role == 'helper') {
      return const HelperDashboardScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3347),
        elevation: 0,
        title: const Row(children: [
          Icon(Icons.home_repair_service, color: Color(0xFF00D4AA)),
          SizedBox(width: 8),
          Text('House Helper', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(
            onPressed: () async { await auth.logout(); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); },
            icon: const Icon(Icons.logout, color: Colors.white70),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [_buildDiscovery(auth), const BookingsScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        backgroundColor: const Color(0xFF1A3347),
        selectedItemColor: const Color(0xFF00D4AA),
        unselectedItemColor: Colors.white38,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'My Bookings'),
        ],
      ),
    );
  }

  Widget _buildDiscovery(AuthProvider auth) => RefreshIndicator(
    onRefresh: _loadData,
    color: const Color(0xFF00D4AA),
    child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hello, ${auth.user?.username ?? 'there'} (${auth.user?.role ?? 'no-role'}) 👋', style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const Text('Find a Helper', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by location...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF00D4AA)),
                filled: true, fillColor: Colors.white.withOpacity(0.07),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(icon: const Icon(Icons.filter_list, color: Color(0xFF00D4AA)), onPressed: _filterHelpers),
              ),
              onSubmitted: (_) => _filterHelpers(),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _services.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return _chip('All', _selectedServiceId == null, () { setState(() => _selectedServiceId = null); _filterHelpers(); });
                  }
                  final s = _services[i - 1];
                  return _chip(s.name, _selectedServiceId == s.id, () { setState(() => _selectedServiceId = s.id); _filterHelpers(); });
                },
              ),
            ),
          ]),
        )),
        if (_loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF00D4AA))))
        else if (_helpers.isEmpty)
          const SliverFillRemaining(child: Center(child: Text('No helpers found', style: TextStyle(color: Colors.white54))))
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.78),
              delegate: SliverChildBuilderDelegate((_, i) => _helperCard(_helpers[i], auth), childCount: _helpers.length),
            ),
          ),
      ],
    ),
  );

  Widget _chip(String label, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF00D4AA) : Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? const Color(0xFF00D4AA) : Colors.white24),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white54, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
    ),
  );

  Widget _helperCard(HelperModel h, AuthProvider auth) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelperDetailScreen(helper: h, currentUserId: auth.user?.id ?? 0))),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(radius: 32, backgroundColor: const Color(0xFF00D4AA).withOpacity(0.15), child: Text(h.user.username[0].toUpperCase(), style: const TextStyle(fontSize: 26, color: Color(0xFF00D4AA), fontWeight: FontWeight.bold))),
          const SizedBox(height: 10),
          Text(h.user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          Text(h.serviceName, style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 12), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 3),
            Text(h.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Text('NPR ${h.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(h.location, style: const TextStyle(color: Colors.white38, fontSize: 11), overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}
