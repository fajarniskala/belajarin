import 'package:flutter/material.dart';

// ✅ Fix: void main() dan class AplikasiRiwayatBaca dihapus,
//         karena entry point ada di main.dart

class HalamanRiwayat extends StatelessWidget {
  const HalamanRiwayat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buatHeaderMerah(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buatKartuBuku(
                    ikon: '🦁',
                    warnaIkon: Colors.orange,
                    judul: 'Si Kancil dan Buaya',
                    status: 'Mulai: 20 Mei 2026',
                    persentase: 0.3,
                    warnaProgress: Colors.blue,
                    teksBawah: 'Hal. 24/80 • 30% • 45 menit',
                  ),
                  const SizedBox(height: 12),
                  _buatKartuBuku(
                    ikon: '🐠',
                    warnaIkon: Colors.blue,
                    judul: 'Dunia Bawah Laut',
                    status: 'Selesai: 19 Mei 2026',
                    persentase: 1.0,
                    warnaProgress: Colors.green,
                    teksBawah: '✅ 64/64 hal • 110 menit',
                    teksBawahWarna: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buatKartuSesi(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buatHeaderMerah() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B6B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.bar_chart, color: Colors.white, size: 36),
              SizedBox(width: 8),
              Text(
                'Riwayat Baca Andi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Total: 2j 35m • Rata-rata 31 hal/hari',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buatKartuBuku({
    required String ikon,
    required Color warnaIkon,
    required String judul,
    required String status,
    required double persentase,
    required Color warnaProgress,
    required String teksBawah,
    Color? teksBawahWarna,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: warnaIkon,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(ikon, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: persentase,
                    child: Container(
                      decoration: BoxDecoration(
                        color: warnaProgress,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  teksBawah,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: teksBawahWarna ?? warnaProgress,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buatKartuSesi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.calendar_month, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Sesi Bacaan — Si Kancil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buatItemSesi('22 Mei, 14:30', 'Hal. 18–24', '25 menit'),
          const SizedBox(height: 12),
          _buatItemSesi('21 Mei, 20:00', 'Hal. 10–18', '20 menit'),
          const SizedBox(height: 12),
          _buatItemSesi('20 Mei, 16:00', 'Hal. 1–10', '30 menit'),
        ],
      ),
    );
  }

  Widget _buatItemSesi(String waktu, String halaman, String durasi) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 10, color: Colors.blueAccent),
        const SizedBox(width: 12),
        Text(
          waktu,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          ' — $halaman — $durasi',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
      ],
    );
  }
}