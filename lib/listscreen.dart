import 'package:flutter/material.dart';
import 'databasehelper.dart';
import 'diaryentry.dart';
import 'diaryscreen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<DiaryEntry> diaries = [];
  final DatabaseHelper dbHelper = DatabaseHelper();
  File? imageFile;

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
  }

  Future<void> _loadDiaryEntries() async {
    final entries = await DatabaseHelper().getAllDiaries();
    setState(() {
      diaries = entries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Screen'),
        backgroundColor: const Color.fromARGB(255, 188, 161, 231),
      ),
      body: diaries.isEmpty
          ? const Center(
              child: Text(
                'No any diary entries yet.\nAdd one now!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(207, 109, 93, 135),
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "Welcome back! What's on your mind today?",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: diaries.length,
                    itemBuilder: (context, index) {
                      final diary = diaries[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: diary.imagePath == null
                              ? const Icon(
                                  Icons.book,
                                  size: 50,
                                  color: Color.fromARGB(255, 176, 174, 181),
                                )
                              : Image.file(
                                  File(diary.imagePath!),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                          title: Text(
                            diary.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(diary.date),
                          onTap: () {
                            showDetailDialog(diary);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

      // Floating Add Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DiaryScreen()),
          );
          _loadDiaryEntries(); // refresh after returning
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Show details dialog for selected diary
  void showDetailDialog(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Expanded(child: Text(entry.title)),
              SizedBox(width: 180),
              IconButton(
                onPressed: () => editEntryDialog(entry),
                icon: Icon(
                  Icons.edit,
                  size: 20,
                  color: const Color.fromARGB(255, 119, 119, 119),
                ),
              ),
              IconButton(
                onPressed: () => deleteDialog(entry.id!),
                icon: Icon(Icons.delete, size: 20, color: Colors.redAccent),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                entry.imagePath != null
                    ? Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Image.file(
                          File(entry.imagePath!),
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 10),
                Text(
                  "Date: ${entry.date}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(entry.notes),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  //update dialog
  void editEntryDialog(DiaryEntry entry) {
    TextEditingController titleController = TextEditingController(
      text: entry.title,
    );
    TextEditingController notesController = TextEditingController(
      text: entry.notes,
    ); // read-only

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    const Text(
                      "Edit Diary Entry",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // TITLE INPUT
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(137, 108, 107, 107),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 233, 231, 241),
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    // NOTES INPUT
                    TextField(
                      controller: notesController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Notes",
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(137, 108, 107, 107),
                        ),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: const Color.fromARGB(255, 233, 231, 241),
                        prefixIcon: const Icon(Icons.edit_note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // DATE (READ ONLY)
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Date",
                        filled: true,
                        fillColor: Color.fromARGB(255, 233, 231, 241),
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // IMAGE PREVIEW (if available)
                    if (entry.imagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(entry.imagePath!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Replace Image Button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text("Replace Image"),
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setState(() {
                            entry.imagePath = picked.path;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // ACTION BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                          child: const Text("Cancel"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E3B8E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Update"),
                          onPressed: () async {
                            if (titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Title cannot be empty."),
                                ),
                              );
                              return;
                            }

                            // Update entry values
                            entry.title = titleController.text.trim();
                            entry.notes = notesController.text.trim();

                            await DatabaseHelper().updateDiary(entry);

                            if (context.mounted) Navigator.pop(context);

                            loadData();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  //load data
  void loadData() async {
    final data = await DatabaseHelper().getAllDiaries();
    setState(() {
      diaries = data;
    });
  }

  //delete entry
  void deleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 18),

                // Title
                const Text(
                  "Delete Diary Entry?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                // Description
                Text(
                  "This action cannot be undone.\nAre you sure you want to remove this diary entry?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          await DatabaseHelper().deleteDiary(id);

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Diary entry deleted successfully",
                                ),
                              ),
                            );
                          }

                          loadData(); // refresh list
                        },
                        child: const Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
