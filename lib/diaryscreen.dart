import 'package:flutter/material.dart';
import 'diaryentry.dart';
import 'databasehelper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Diary'),
        backgroundColor: const Color.fromARGB(255, 188, 161, 231),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Write something new !\n\nToday is ${DateTime.now().toLocal().toString().split(' ')[0]}",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  height: 220,
                  width: 380,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, // border color
                      width: 1.5, // border thickness
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    color: const Color.fromARGB(215,218,213,246,), // rounded corners
                  ),
                  child: Center(
                    child: imageFile != null
                        ? Image.file(imageFile!, fit: BoxFit.cover)
                        : Icon(
                            Icons.add_a_photo_rounded,
                            size: 50,
                            color: const Color.fromARGB(148, 81, 79, 89),
                          ),
                  ),
                ),
                SizedBox(height: 10),

                ElevatedButton(onPressed: pickImage, child: Text("Pick Image")),

                SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  width: 380,
                  child: TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                      errorStyle: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title cannot be empty';
                      }
                      return null;
                    },
                    minLines: 1,
                    maxLines: 2,
                  ),
                ),
                SizedBox(
                  height: 150,
                  width: 380,
                  child: TextFormField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Diary Text',
                      border: OutlineInputBorder(),
                      errorStyle: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Notes cannot be empty';
                      }
                      return null;
                    },
                    minLines: 5,
                    maxLines: 10,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(onPressed: saveDiary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 214, 207, 234),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ), child: Text('Save Diary')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Pick image from gallery
  Future<void> pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
      });
    }
  }

  //Save diary entry to database
  Future<void> saveDiary() async {
    DateTime now = DateTime.now();
    String date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ";

    if (formKey.currentState!.validate()) {
      final newEntry = DiaryEntry(
        title: titleController.text,
        notes: notesController.text,
        date: date,
        imagePath: imageFile?.path,
      );
      await dbHelper.insertDiary(newEntry);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diary Entry Saved')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context); //Close dialog
    }
  }
}
