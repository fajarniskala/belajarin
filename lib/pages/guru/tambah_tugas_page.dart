import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart'; // Menggunakan konfigurasi URL global

class TambahTugasPage extends StatefulWidget {
  final int guruId;

  const TambahTugasPage({super.key, required this.guruId});

  @override
  State<TambahTugasPage> createState() => _TambahTugasPageState();
}

class _TambahTugasPageState extends State<TambahTugasPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String? _selectedModuleId;
  DateTime? _selectedDueDate;

  bool _isLoading = false;
  bool _isLoadingModules = true;
  List<Map<String, dynamic>> _listModul = [];

  @override
  void initState() {
    super.initState();
    _fetchGuruModules();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- Ambil daftar modul guru dari database ---
  Future<void> _fetchGuruModules() async {
    print("Mencoba mengambil modul untuk guruId: ${widget.guruId}");
    print(
      "URL API: ${ApiConfig.baseUrl}/dashboard/guru-modules/${widget.guruId}",
    );

    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/gurucontroller/guru-modules/${widget.guruId}',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> moduleData = responseData['data'];

        if (mounted) {
          setState(() {
            _listModul = moduleData
                .map(
                  (m) => {
                    "id": m['id'].toString(),
                    "title": m['title'].toString(),
                  },
                )
                .toList();
            _isLoadingModules = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingModules = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingModules = false);
      print("Gagal memuat modul: $e");
    }
  }

  // --- Fungsi memunculkan Kalender (Date Picker) ---
  Future<void> _pickDueDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  // --- Kirim Data ke API ---
  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedModuleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap pilih Modul terlebih dahulu!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final dataTugasBaru = {
        "module_id": _selectedModuleId,
        "guru_id": widget.guruId.toString(),
        "title": _titleController.text,
        "description": _descController.text.isEmpty
            ? null
            : _descController.text,
        "due_date": _selectedDueDate
            ?.toIso8601String(), // Mengirim format tanggal ISO
      };

      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/gurucontroller/add-task'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(dataTugasBaru),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tugas baru berhasil diterbitkan! 📝'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(
            context,
            true,
          ); // Kembali ke dashboard dengan status sukses
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan jaringan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _customInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF20B2AA)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Buat Tugas Baru",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF20B2AA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Formulir Tugas Siswa",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 1. DROPDOWN PILIH MODUL (Dinamis & Type Safe)
                const Text(
                  "Pilih Modul Terkait",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: _customInputDecoration(
                    "Pilih Modul",
                    Icons.menu_book,
                  ),
                  hint: _isLoadingModules
                      ? const Text("Memuat modul Anda...")
                      : const Text("-- Pilih Modul Belajar --"),
                  value: _selectedModuleId,
                  items: _isLoadingModules
                      ? <DropdownMenuItem<String>>[]
                      : _listModul.map((m) {
                          return DropdownMenuItem<String>(
                            value: m['id'].toString(),
                            child: Text(m['title'].toString()),
                          );
                        }).toList(),
                  onChanged: (val) => setState(() => _selectedModuleId = val),
                  validator: (v) => v == null ? "Modul harus dipilih" : null,
                ),

                const SizedBox(height: 20),

                // 2. INPUT JUDUL TUGAS
                const Text(
                  "Judul Tugas",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _customInputDecoration(
                    "cth: Latihan Soal Pecahan Bab 1",
                    Icons.assignment,
                  ),
                  validator: (v) =>
                      v!.isEmpty ? "Judul tugas tidak boleh kosong" : null,
                ),

                const SizedBox(height: 20),

                // 3. DATE PICKER DEADLINE (Batas Waktu)
                const Text(
                  "Batas Waktu Pengumpulan (Opsional)",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDueDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDueDate == null
                              ? "Ketuk untuk set tanggal deadline"
                              : "${_selectedDueDate!.day}-${_selectedDueDate!.month}-${_selectedDueDate!.year}",
                          style: TextStyle(
                            color: _selectedDueDate == null
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_month,
                          color: Color(0xFF20B2AA),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 4. DESKRIPSI / INSTRUKSI SOAL (Fixed Syntax)
                const Text(
                  "Instruksi / Pertanyaan Tugas",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Tuliskan instruksi pengerjaan tugas di sini...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Sesuai sintaks perbaikan
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // TOMBOL SUBMIT
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Terbitkan Tugas Sekarang",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
