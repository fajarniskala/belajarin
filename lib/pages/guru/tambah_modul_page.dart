import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../../api_config.dart';

// ---> TAMBAHAN IMPORTS UNTUK NAVIGASI BAWAH <---
import 'tambah_siswa_page.dart';
import 'rekap_nilai_page.dart';
import 'upload_ebook_page.dart';

class TambahModulPage extends StatefulWidget {
  final int guruId;

  const TambahModulPage({super.key, required this.guruId});

  @override
  State<TambahModulPage> createState() => _TambahModulPageState();
}

class _TambahModulPageState extends State<TambahModulPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _orderController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedLevel;
  bool _isLoading = false;

  PlatformFile? _pickedFile;

  List<Map<String, String>> _listKategori = [];
  bool _isLoadingCategories = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pointsController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/gurucontroller/categories'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> categoryData = responseData['data'];

        if (mounted) {
          setState(() {
            _listKategori = categoryData
                .map(
                  (c) => {
                    "id": c['id'].toString(),
                    "name": c['name'].toString(),
                  },
                )
                .toList();
            _isLoadingCategories = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingCategories = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
      print("Gagal mengambil data kategori: $e");
    }
  }

  Future<void> _pilihFilePdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      print("Gagal memilih file: $e");
    }
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Harap pilih file PDF modul terlebih dahulu!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        var url = Uri.parse('${ApiConfig.baseUrl}/gurucontroller/add-module');
        var request = http.MultipartRequest('POST', url);

        request.fields['guru_id'] = widget.guruId.toString();
        request.fields['category_id'] = _selectedCategoryId ?? '';
        request.fields['title'] = _titleController.text;
        request.fields['description'] = _descController.text;
        request.fields['level'] = _selectedLevel ?? '';
        request.fields['total_points'] = _pointsController.text;
        request.fields['order_seq'] = _orderController.text;

        if (_pickedFile!.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file_pdf',
              _pickedFile!.bytes!,
              filename: _pickedFile!.name,
            ),
          );
        } else if (_pickedFile!.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file_pdf',
              _pickedFile!.path!,
              filename: _pickedFile!.name,
            ),
          );
        }

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201 || response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hore! Modul & PDF berhasil disimpan! 🌟'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
            content: Text('Error jaringan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.orange[800]),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _customInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        title: const Text(
          "Tambah Modul",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFFFFD54F),
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),

      // ======================================================================
      // BOTTOM NAVIGATION BAR (ACTIVE INDEX: 2)
      // ======================================================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF20B2AA),
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TambahSiswaPage(guruId: widget.guruId),
                ),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RekapNilaiPage(guruId: widget.guruId),
                ),
              );
            } else if (index == 4) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadEbookPage(guruId: widget.guruId),
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_add_alt_1),
              label: 'Siswa',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Modul'),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: 'Nilai',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload_file),
              label: 'E-Book',
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pilihFilePdf,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.blue.shade300,
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _pickedFile != null
                                  ? Icons.picture_as_pdf
                                  : Icons.description,
                              size: 48,
                              color: _pickedFile != null
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _pickedFile != null
                                  ? _pickedFile!.name
                                  : "Ketuk untuk pilih file PDF",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _pickedFile != null
                                  ? "${(_pickedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB"
                                  : "dari File Manager, Google Drive, dll.",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    _buildLabel("Judul Modul", Icons.menu_book),
                    TextFormField(
                      controller: _titleController,
                      decoration: _customInputDecoration("cth: Aljabar Dasar"),
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),

                    _buildLabel("Kategori Modul", Icons.category),
                    DropdownButtonFormField<String>(
                      decoration: _customInputDecoration(
                        "-- Pilih Kategori --",
                      ),
                      value: _selectedCategoryId,
                      hint: _isLoadingCategories
                          ? const Text(
                              "Memuat kategori...",
                              style: TextStyle(color: Colors.grey),
                            )
                          : const Text("-- Pilih Kategori --"),
                      items: _isLoadingCategories
                          ? []
                          : _listKategori.map((k) {
                              return DropdownMenuItem<String>(
                                value: k['id'],
                                child: Text(k['name']!),
                              );
                            }).toList(),
                      onChanged: (_isLoading || _isLoadingCategories)
                          ? null
                          : (val) {
                              setState(() => _selectedCategoryId = val);
                            },
                      validator: (v) => v == null ? "Pilih kategori" : null,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Level", Icons.stairs),
                              DropdownButtonFormField<String>(
                                decoration: _customInputDecoration("Level"),
                                value: _selectedLevel,
                                items: ["1", "2", "3", "4", "5"].map((l) {
                                  return DropdownMenuItem(
                                    value: l,
                                    child: Text("Level $l"),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedLevel = val),
                                validator: (v) => v == null ? "Pilih" : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Total Poin", Icons.stars),
                              TextFormField(
                                controller: _pointsController,
                                keyboardType: TextInputType.number,
                                decoration: _customInputDecoration("cth: 100"),
                                validator: (v) =>
                                    v!.isEmpty ? "Isi poin" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    _buildLabel(
                      "Urutan Modul (Order Seq)",
                      Icons.format_list_numbered,
                    ),
                    TextFormField(
                      controller: _orderController,
                      keyboardType: TextInputType.number,
                      decoration: _customInputDecoration(
                        "cth: 1 (Urutan tampil ke siswa)",
                      ),
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),

                    _buildLabel("Deskripsi (opsional)", Icons.edit_note),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: _customInputDecoration(
                        "Keterangan singkat materi...",
                      ),
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isLoadingCategories)
                            ? null
                            : _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF66BB6A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.cloud_upload, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Upload Modul Sekarang!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_isLoading)
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const LinearProgressIndicator(
                              backgroundColor: Color(0xFFC8E6C9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF388E3C),
                              ),
                              minHeight: 10,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Menyimpan dan mengunggah...",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
