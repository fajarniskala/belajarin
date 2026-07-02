import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../api_config.dart';

class KerjakanTugasPage extends StatefulWidget {
  final int studentId;
  final int taskId;
  final String taskTitle;

  const KerjakanTugasPage({
    super.key,
    required this.studentId,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<KerjakanTugasPage> createState() => _KerjakanTugasPageState();
}

class _KerjakanTugasPageState extends State<KerjakanTugasPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textSubmissionController =
      TextEditingController();

  PlatformFile? _pickedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null) {
        setState(() => _pickedFile = result.files.first);
      }
    } catch (e) {
      print("Error pick file: $e");
    }
  }

  Future<void> _submitTugas() async {
    if (_textSubmissionController.text.isEmpty && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi jawaban teks ATAU upload file!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var url = Uri.parse('${ApiConfig.baseUrl_siswa}/siswa/submit-task');
      var request = http.MultipartRequest('POST', url);

      request.fields['task_id'] = widget.taskId.toString();
      request.fields['student_id'] = widget.studentId.toString();
      request.fields['text_submission'] = _textSubmissionController.text;

      if (_pickedFile != null) {
        if (_pickedFile!.bytes != null) {
          // Web
          request.files.add(
            http.MultipartFile.fromBytes(
              'file_submission',
              _pickedFile!.bytes!,
              filename: _pickedFile!.name,
            ),
          );
        } else if (_pickedFile!.path != null) {
          // Android/iOS
          request.files.add(
            await http.MultipartFile.fromPath(
              'file_submission',
              _pickedFile!.path!,
              filename: _pickedFile!.name,
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hore! Jawaban berhasil dikirim! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kumpulkan Tugas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[400],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.taskTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan ketik jawabanmu di bawah ini, atau unggah file foto/PDF jika menjawab di buku tulis.",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),
              const Text(
                "Jawaban Teks",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _textSubmissionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Ketik jawabanmu di sini...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                "Upload File (Opsional)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickFile,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _pickedFile != null
                            ? Icons.check_circle
                            : Icons.upload_file,
                        size: 40,
                        color: _pickedFile != null ? Colors.green : Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pickedFile != null
                            ? _pickedFile!.name
                            : "Pilih File PDF/Foto",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTugas,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Kirim Jawaban",
                          style: TextStyle(
                            fontSize: 18,
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
    );
  }
}
