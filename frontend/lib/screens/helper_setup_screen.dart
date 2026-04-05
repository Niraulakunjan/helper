import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'helper_dashboard_screen.dart';

class HelperSetupScreen extends StatefulWidget {
  const HelperSetupScreen({super.key});
  @override
  State<HelperSetupScreen> createState() => _HelperSetupScreenState();
}

class _HelperSetupScreenState extends State<HelperSetupScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF0A1628);
  static const _card = Color(0xFF0F2040);
  static const _teal = Color(0xFF00D4AA);
  static const _purple = Color(0xFF7B61FF);

  int _step = 0; // 0=category, 1=price, 2=location
  List<ServiceModel> _services = [];
  bool _loadingServices = true;
  ServiceModel? _selected;
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Common icons for services based on name
  IconData _serviceIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('plumb')) return Icons.plumbing;
    if (n.contains('clean')) return Icons.cleaning_services_rounded;
    if (n.contains('electr')) return Icons.electrical_services;
    if (n.contains('paint')) return Icons.format_paint;
    if (n.contains('garden') || n.contains('lawn')) return Icons.grass;
    if (n.contains('carpen') || n.contains('wood')) return Icons.handyman;
    if (n.contains('cook') || n.contains('chef')) return Icons.restaurant;
    if (n.contains('security') || n.contains('guard')) return Icons.security;
    if (n.contains('drive') || n.contains('transport')) return Icons.drive_eta;
    return Icons.build_rounded;
  }

  Color _serviceColor(int index) {
    const colors = [
      Color(0xFF00D4AA), Color(0xFF7B61FF), Color(0xFFFF6B6B),
      Color(0xFFFFB347), Color(0xFF4FC3F7), Color(0xFFAB47BC),
      Color(0xFF66BB6A), Color(0xFFEF5350),
    ];
    return colors[index % colors.length];
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _loadServices();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final s = await ApiService.getServices();
      setState(() { _services = s; _loadingServices = false; });
    } catch (_) {
      setState(() => _loadingServices = false);
    }
  }

  void _nextStep() {
    if (_step == 0 && _selected == null) {
      _showError('Please select a service category');
      return;
    }
    if (_step == 1) {
      final v = double.tryParse(_priceCtrl.text.trim());
      if (v == null || v <= 0) {
        _showError('Enter a valid price');
        return;
      }
    }
    setState(() => _error = null);
    _animCtrl.reset();
    _animCtrl.forward();
    setState(() => _step++);
  }

  void _showError(String msg) => setState(() => _error = msg);

  Future<void> _submit() async {
    final loc = _locationCtrl.text.trim();
    if (loc.isEmpty) { _showError('Enter your location'); return; }
    setState(() { _submitting = true; _error = null; });
    try {
      await ApiService.registerHelper(
        serviceId: _selected!.id,
        price: double.parse(_priceCtrl.text.trim()),
        location: loc,
      );
      if (mounted) {
        await context.read<AuthProvider>().markHelperProfileCreated();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HelperDashboardScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildProgressBar(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: _buildCurrentStep(),
              ),
            ),
          ),
          _buildBottomBar(),
        ]),
      ),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        color: _card,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_purple, _teal]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Helper Setup',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${_step + 1}/3',
                style: const TextStyle(color: Colors.white38, fontSize: 14)),
          ]),
          const SizedBox(height: 10),
          Text(
            _step == 0
                ? 'What service do you offer?'
                : _step == 1
                    ? 'Set your hourly rate'
                    : 'Where do you work?',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ]),
      );

  Widget _buildProgressBar() {
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(children: List.generate(3, (i) {
        final done = i < _step;
        final active = i == _step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: done
                  ? _teal
                  : active
                      ? _purple
                      : Colors.white10,
            ),
          ),
        );
      })),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _buildCategoryStep();
      case 1: return _buildPriceStep();
      case 2: return _buildLocationStep();
      default: return const SizedBox();
    }
  }

  // ── STEP 1: Category ────────────────────────────────────────────────────
  Widget _buildCategoryStep() {
    if (_loadingServices) {
      return const Center(child: CircularProgressIndicator(color: _teal));
    }
    if (_services.isEmpty) {
      return const Center(
          child: Text('No services found.\nAsk admin to add services.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 15)));
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Choose your category',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('Customers will find you by this',
            style: TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: _services.length,
            itemBuilder: (_, i) {
              final s = _services[i];
              final color = _serviceColor(i);
              final isSelected = _selected?.id == s.id;
              return GestureDetector(
                onTap: () => setState(() { _selected = s; _error = null; }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? color : Colors.white.withOpacity(0.08),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_serviceIcon(s.name), color: isSelected ? color : Colors.white38, size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(s.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? color : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        )),
                    if (isSelected) ...[
                      const SizedBox(height: 6),
                      Icon(Icons.check_circle, color: color, size: 16),
                    ]
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  // ── STEP 2: Price ───────────────────────────────────────────────────────
  Widget _buildPriceStep() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Selected service chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _teal.withOpacity(0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_serviceIcon(_selected?.name ?? ''), color: _teal, size: 16),
              const SizedBox(width: 8),
              Text(_selected?.name ?? '', style: const TextStyle(color: _teal, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 28),
          const Text('Set your rate',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('How much do you charge per hour?',
              style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 32),

          // Price input
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _purple.withOpacity(0.3)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: _purple.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  border: Border(right: BorderSide(color: _purple.withOpacity(0.2))),
                ),
                child: const Text('NPR', style: TextStyle(color: _purple, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white24),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('/hr', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14)),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Suggested prices
          const Text('Suggested rates', style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [500, 800, 1000, 1500, 2000].map((v) {
              return GestureDetector(
                onTap: () => setState(() { _priceCtrl.text = v.toString(); _error = null; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text('NPR $v',
                      style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ),
              );
            }).toList(),
          ),
        ]),
      );

  // ── STEP 3: Location ────────────────────────────────────────────────────
  Widget _buildLocationStep() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _teal.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_serviceIcon(_selected?.name ?? ''), color: _teal, size: 14),
                const SizedBox(width: 6),
                Text(_selected?.name ?? '', style: const TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _purple.withOpacity(0.3)),
              ),
              child: Text('NPR ${_priceCtrl.text}/hr',
                  style: const TextStyle(color: _purple, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 28),
          const Text('Set your location',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Where are you available to work?',
              style: TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 28),

          // Location input
          Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _teal.withOpacity(0.3)),
            ),
            child: TextField(
              controller: _locationCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'e.g. Kathmandu, Baneshwor',
                hintStyle: const TextStyle(color: Colors.white24),
                prefixIcon: const Icon(Icons.location_on_rounded, color: _teal),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
          ),
          const SizedBox(height: 20),

          // Quick-pick locations
          const Text('Popular areas', style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Kathmandu', 'Lalitpur', 'Bhaktapur', 'Pokhara', 'Chitwan', 'Biratnagar']
                .map((loc) => GestureDetector(
                      onTap: () => setState(() { _locationCtrl.text = loc; _error = null; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.place, color: Colors.white38, size: 14),
                          const SizedBox(width: 4),
                          Text(loc, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                        ]),
                      ),
                    ))
                .toList(),
          ),
        ]),
      );

  Widget _buildBottomBar() => Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: _card,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
              ]),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : (_step < 2 ? _nextStep : _submit),
              style: ElevatedButton.styleFrom(
                backgroundColor: _step < 2 ? _purple : _teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                        _step < 2 ? 'Continue' : 'Complete Setup',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Icon(_step < 2 ? Icons.arrow_forward_rounded : Icons.check_rounded,
                          color: Colors.white, size: 18),
                    ]),
            ),
          ),
        ]),
      );
}
