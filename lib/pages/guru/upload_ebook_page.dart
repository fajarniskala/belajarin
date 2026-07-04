import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data'; // 🔥 TAMBAHAN: Untuk membaca biner file PDF
import 'package:flutter/foundation.dart'; 
import '../../api_config.dart';

// ---> TAMBAHAN IMPORTS UNTUK NAVIGASI BAWAH <---
import 'tambah_siswa_page.dart';
import 'tambah_modul_page.dart';
import 'rekap_nilai_page.dart';

class UploadEbookPage extends StatefulWidget {
  final int guruId;

  const UploadEbookPage({Key? key, required this.guruId}) : super(key: key);

  @override
  State<UploadEbookPage> createState() => _UploadEbookPageState();
}

class _UploadEbookPageState extends State<UploadEbookPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _totalPagesController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<dynamic> _categories = [];
  String? _selectedCategory;
  String _selectedLevel = '1'; 
  FilePickerResult? _pickedFile;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/gurucontroller/categories'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = jsonDecode(response.body)['data'];
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat kategori: $e");
    }
  }

  // 🔥 FUNGSI HACK UTAMA: Membaca metadata /Count biner PDF secara Pure Dart (Bebas Error Gradle)
  int _extractPdfPageCount(Uint8List bytes) {
    try {
      // Menggunakan latin1 agar data biner aman dikonversi menjadi string tanpa memicu crash UTF-8
      final content = latin1.decode(bytes, allowInvalid: true);
      
      // Mencari pola reguler penulisan struktur /Count di dalam dokumen PDF
      final regExp = RegExp(r'/Count\s+(\d+)');
      final matches = regExp.allMatches(content);
      
      int maxPages = 0;
      for (var match in matches) {
        int current = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (current > maxPages) {
          maxPages = current; // Mengambil angka kemunculan halaman tertinggi sebagai total halaman utama
        }
      }
      return maxPages;
    } catch (e) {
      debugPrint("Gagal mengekstrak halaman PDF: $e");
      return 0;
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // Memastikan data bytes file PDF termuat sempurna[cite: 9]
    );

    if (result != null) {
      setState(() {
        _pickedFile = result;
      });

      // 🔥 HITUNG OTOMATIS: Berjalan instan tanpa plugin native luar
      if (result.files.single.bytes != null) {
        int totalHalaman = _extractPdfPageCount(result.files.single.bytes!);
        if (totalHalaman > 0) {
          setState(() {
            _totalPagesController.text = totalHalaman.toString();
          });
        }
      }
    }
  }

  Future<void> _uploadEbook() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tolong pilih file PDF terlebih dahulu!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/gurucontroller/upload-ebook'),
      );

      request.fields['guru_id'] = widget.guruId.toString();
      request.fields['title'] = _titleController.text;
      request.fields['author'] = _authorController.text;
      request.fields['total_pages'] = _totalPagesController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['level'] = _selectedLevel;
      if (_selectedCategory != null) {
        request.fields['category_id'] = _selectedCategory!;
      }

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file_pdf',
            _pickedFile!.files.single.bytes!,
            filename: _pickedFile!.files.single.name,
          ),
        );
      } else {
        String filePath = _pickedFile!.files.single.path!;
        request.files.add(await http.MultipartFile.fromPath('file_pdf', filePath));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeay! E-Book berhasil diupload 🎉'), backgroundColor: Colors.green));
          Navigator.pop(context, true); 
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $responseBody')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi error jaringan: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Upload E-Book Baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF9B59B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 4, 
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
                MaterialPageRoute(builder: (context) => TambahSiswaPage(guruId: widget.guruId)),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => TambahModulPage(guruId: widget.guruId)),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RekapNilaiPage(guruId: widget.guruId)),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.person_add_alt_1), label: 'Siswa'),
            BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Modul'),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Nilai'),
            BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'E-Book'),
          ],
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9B59B6)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("File Buku (PDF)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _pickedFile == null ? Colors.purple.shade50 : Colors.green.shade50,
                          border: Border.all(color: _pickedFile == null ? Colors.purple.shade200 : Colors.green.shade300, width: 2, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _pickedFile == null ? Icons.upload_file : Icons.check_circle,
                              size: 40,
                              color: _pickedFile == null ? const Color(0xFF9B59B6) : Colors.green,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _pickedFile == null ? "Ketuk untuk mencari PDF" : _pickedFile!.files.single.name,
                              style: TextStyle(color: _pickedFile == null ? const Color(0xFF9B59B6) : Colors.green, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField("Judul Buku", _titleController, "Misal: Kisah Sang Kancil"),
                    _buildTextField("Penulis / Pengarang", _authorController, "Nama Pengarang"),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField("Total Halaman", _totalPagesController, "Misal: 25", isNumber: true),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Level Tingkat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedLevel,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: ['1', '2', '3', '4', '5', '6'].map((lvl) {
                                  return DropdownMenuItem(value: lvl, child: Text("Level $lvl"));
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedLevel = val!),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Text("Kategori (Opsional)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: "Pilih Kategori",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _categories.map((kat) {
                        return DropdownMenuItem<String>(value: kat['id'].toString(), child: Text(kat['name']));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField("Deskripsi Singkat", _descriptionController, "Ceritakan ringkasan buku ini...", maxLines: 3),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B59B6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _uploadEbook,
                        child: const Text("Upload Sekarang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9B59B6), width: 2)),
            ),
            validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
          ),
        ],
      ),
    );
  }
}