// ============================================================
// screens/spin/spin_screen.dart
// Halaman utama spin wheel — selaras dengan dashboard.html + spin.js
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/spin_provider.dart';
import '../../widgets/wheel_painter.dart';
import '../../widgets/app_button.dart';
import '../../config/app_theme.dart';

class SpinScreen extends StatefulWidget {
  const SpinScreen({super.key});

  @override
  State<SpinScreen> createState() => _SpinScreenState();
}

class _SpinScreenState extends State<SpinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  final _inputCtrl = TextEditingController();
  double _baseAngle = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  // ── Mulai spin ───────────────────────────────────────────────
  void _startSpin() {
    final prov = context.read<SpinProvider>();
    if (prov.isSpinning || prov.options.length < 2) {
      _showSnack(prov.options.length < 2
          ? 'Tambahkan minimal 2 pilihan!'
          : 'Sedang berputar...');
      return;
    }

    final totalRotation = (math.pi * 2) * (5 + math.Random().nextDouble() * 5);
    final duration = Duration(
        milliseconds: (4000 + math.Random().nextDouble() * 1000).toInt());

    _ctrl.reset();
    _ctrl.duration = duration;

    _anim = Tween<double>(begin: 0, end: totalRotation).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart),
    );

    prov.isSpinning = true;
    prov.winnerIndex = null;
    prov.notifyListeners();

    _ctrl.forward();
  }

  // ── Selesai spin ─────────────────────────────────────────────
  void _onSpinDone() {
    final prov = context.read<SpinProvider>();
    final options = prov.options;
    if (options.isEmpty) return;

    final arc = (math.pi * 2) / options.length;
    final finalAngle = _baseAngle + _anim.value;

    // Normalisasi sudut — pointer di kanan (angle=0)
    final normalized =
        ((finalAngle % (math.pi * 2)) + math.pi * 2) % (math.pi * 2);
    final pointerAngle = (math.pi * 2 - normalized) % (math.pi * 2);
    final winnerIndex = pointerAngle ~/ arc % options.length;

    _baseAngle = finalAngle % (math.pi * 2);

    prov.onSpinComplete(winnerIndex);
    _showResultDialog(options[winnerIndex]);
  }

  // ── Dialog hasil ─────────────────────────────────────────────
  void _showResultDialog(String result) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 12),
              const Text(
                'Hasil Spin!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF4D96FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF4D96FF).withOpacity(0.3)),
                ),
                child: Text(
                  result,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4D96FF),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tutup'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Spin Lagi'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _startSpin();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Tambah opsi ──────────────────────────────────────────────
  void _addOption() {
    final prov = context.read<SpinProvider>();
    final text = _inputCtrl.text.trim();
    if (!prov.addOption(text)) {
      if (text.isEmpty) {
        _showSnack('Masukkan teks pilihan dulu!');
      } else if (prov.options.length >= SpinProvider.maxOptions) {
        _showSnack('Maksimal ${SpinProvider.maxOptions} pilihan!');
      } else {
        _showSnack('Pilihan sudah ada!');
      }
      return;
    }
    _inputCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpinProvider>(
      builder: (context, prov, _) {
        // Hitung sudut saat animasi berjalan
        final angle = _ctrl.isAnimating
            ? _baseAngle + (_anim.value)
            : _baseAngle;

        return Scaffold(
          appBar: AppBar(
            title: const Text('🎯 SpinWheel'),
            actions: [
              // Repeat last spin
              if (prov.history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.replay),
                  tooltip: 'Ulangi spin terakhir',
                  onPressed: prov.isSpinning
                      ? null
                      : () {
                          prov.repeatLastSpin();
                          _showSnack(
                              'Opsi dari spin terakhir dimuat!');
                        },
                ),
              // Sound toggle
              IconButton(
                icon: Icon(prov.soundEnabled
                    ? Icons.volume_up
                    : Icons.volume_off),
                tooltip: 'Sound',
                onPressed: prov.toggleSound,
              ),
            ],
          ),
          body: Column(
            children: [
              // ── RODA ─────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Roda + pointer
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _ctrl,
                          builder: (_, __) => Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: CustomPaint(
                                  painter: WheelPainter(
                                    options: prov.options,
                                    angle: angle,
                                    highlightIndex: prov.winnerIndex,
                                  ),
                                ),
                              ),
                              // Pointer kanan
                              Positioned(
                                right: 0,
                                child: SizedBox(
                                  width: 28,
                                  height: 20,
                                  child: CustomPaint(
                                    painter: WheelPointerPainter(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Tombol SPIN ──────────────────────────
                      AppButton(
                        label: prov.isSpinning
                            ? '🌀 Berputar...'
                            : '🎰 PUTAR!',
                        onPressed: prov.isSpinning ? null : _startSpin,
                        isLoading: false,
                        color: prov.isSpinning
                            ? Colors.grey
                            : const Color(0xFF4D96FF),
                      ),
                    ],
                  ),
                ),
              ),

              // ── PANEL BAWAH: Input + Daftar Opsi ─────────────
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Input field
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Ketik pilihan...',
                                prefixIcon: Icon(Icons.add_circle_outline),
                                isDense: true,
                              ),
                              onSubmitted: (_) => _addOption(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _addOption,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(52, 52),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),

                    // Info jumlah opsi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            '${prov.options.length}/${SpinProvider.maxOptions} pilihan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                          const Spacer(),
                          if (prov.options.isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline,
                                  size: 16),
                              label: const Text('Hapus Semua'),
                              onPressed: prov.clearOptions,
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          if (prov.favorites.isNotEmpty)
                            TextButton.icon(
                              icon: const Icon(Icons.favorite, size: 16),
                              label: const Text('Load Favorit'),
                              onPressed: prov.loadFavoritesToOptions,
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.only(left: 8),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Daftar opsi
                    SizedBox(
                      height: 180,
                      child: prov.options.isEmpty
                          ? Center(
                              child: Text(
                                '🎯 Belum ada pilihan.\nTambahkan di atas!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: prov.options.length,
                              itemBuilder: (_, i) {
                                final opt = prov.options[i];
                                final color = AppTheme.wheelColors[
                                    i % AppTheme.wheelColors.length];
                                final isWinner = i == prov.winnerIndex;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isWinner
                                        ? color.withOpacity(0.2)
                                        : color.withOpacity(0.08),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                    border: Border.all(
                                        color: color.withOpacity(
                                            isWinner ? 0.6 : 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          opt,
                                          style: TextStyle(
                                            fontWeight: isWinner
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      // Favorit
                                      GestureDetector(
                                        onTap: () =>
                                            prov.toggleFavorite(opt),
                                        child: Icon(
                                          prov.isFavorite(opt)
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 18,
                                          color: prov.isFavorite(opt)
                                              ? Colors.pinkAccent
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Hapus
                                      GestureDetector(
                                        onTap: () =>
                                            prov.removeOption(i),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
