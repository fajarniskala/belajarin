import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api_config.dart';

class ManajemenAchievementPage extends StatefulWidget {
  const ManajemenAchievementPage({Key? key}) : super(key: key);

  @override
  State<ManajemenAchievementPage> createState() =>
      _ManajemenAchievementPageState();
}

class _ManajemenAchievementPageState extends State<ManajemenAchievementPage> {
  List<dynamic> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/achievements'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _achievements = jsonDecode(response.body)['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processCrudAction(
    String endpoint,
    Map<String, String> body,
    String successMsg,
  ) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/dashboard/$endpoint'),
        body: body,
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: Colors.green),
        );
        _fetchAchievements();
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aksi gagal diproses"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showFormDialog({Map<String, dynamic>? item}) {
    final bool isUpdate = item != null;
    final titleController = TextEditingController(
      text: isUpdate ? item['title'] : '',
    );
    final descController = TextEditingController(
      text: isUpdate ? item['description'] : '',
    );
    final condController = TextEditingController(
      text: isUpdate ? item['required_condition'] : '',
    );
    final rewardController = TextEditingController(
      text: isUpdate ? item['points_reward'].toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isUpdate ? "Ubah Detail Achievement" : "Tambah Lencana Baru",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lencana / Title',
                ),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Logika',
                ),
              ),
              TextField(
                controller: condController,
                decoration: const InputDecoration(
                  labelText: 'Kondisi Syarat (misal finish_ebook:5)',
                ),
              ),
              TextField(
                controller: rewardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Reward Bonus Poin',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {
              Navigator.pop(context);
              final Map<String, String> bodyData = {
                'title': titleController.text,
                'description': descController.text,
                'required_condition': condController.text,
                'points_reward': rewardController.text,
              };
              if (isUpdate) bodyData['id'] = item['id'].toString();

              _processCrudAction(
                isUpdate ? 'updateAchievement' : 'addAchievement',
                bodyData,
                isUpdate
                    ? 'Lencana sukses diperbarui!'
                    : 'Lencana baru berhasil dirilis!',
              );
            },
            child: const Text(
              "Simpan Data",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        title: const Text(
          "Manajemen Master Achievement",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showFormDialog(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _achievements.isEmpty
          ? const Center(
              child: Text("Sistem gamifikasi belum memiliki lencana."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final item = _achievements[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withOpacity(0.1),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: Colors.purple,
                      ),
                    ),
                    title: Text(
                      item['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          item['description'] ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Syarat: ${item['required_condition']}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "+${item['points_reward']} Poin",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () => _showFormDialog(item: item),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _processCrudAction(
                            'deleteAchievement',
                            {'id': item['id'].toString()},
                            'Achievement berhasil dihapus dari sistem.',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
