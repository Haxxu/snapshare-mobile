// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/screens/screens.dart';
import 'package:snapshare_mobile/services/post_service.dart';
import 'package:snapshare_mobile/services/storage_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';
import 'package:snapshare_mobile/utils/utils.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final PostService _postService = PostService();
  Uint8List? _file;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() async {
    super.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<AuthManager>(context).user;

    return _file == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: () => _selectImage(context),
                ),
                const Text('Upload Image'),
              ],
            ),
          )
        : Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => clearImage(),
              ),
              title: const Text('Create new Post'),
              actions: [
                TextButton(
                  onPressed: () => _submit(
                    title: _titleController.text,
                    description: _descriptionController.text,
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _isLoading
                      ? const LinearProgressIndicator()
                      : const Padding(
                          padding: EdgeInsets.only(top: 0),
                        ),
                  const Divider(),
                  SizedBox(
                    // width: 45,
                    // height: 45,
                    child: AspectRatio(
                      aspectRatio: 487 / 451,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(_file!),
                            fit: BoxFit.fill,
                            alignment: FractionalOffset.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user!.image),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(user.account),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _titleController,

                              decoration: const InputDecoration(
                                labelStyle: TextStyle(
                                  fontSize: 28,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelText: 'Title',
                                hintText: 'Write a title...',
                                border: InputBorder.none,
                              ),
                              // maxLines: 8,
                            ),
                            const Divider(),
                            TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelStyle: TextStyle(
                                  fontSize: 23,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelText: 'Description',
                                hintText: 'Write a description...',
                                border: InputBorder.none,
                              ),
                              // maxLines: 4,
                            ),
                            const Divider(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _submit({required String title, required String description}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String postImageUrl = await StorageService()
          .uploadImageToStorage(folderName: 'images', file: _file!);

      await _postService.createNewPost(
        context: context,
        title: title,
        description: description,
        image: postImageUrl,
      );
    } catch (e) {
      // print(e);
      showSnackBar(context, e.toString());
    }

    setState(() {
      _isLoading = false;
      _titleController.clear();
      _descriptionController.clear();
      _file = null;
    });
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Create a post'),
        children: [
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Take a photo'),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.camera);
              setState(() {
                _file = file;
              });
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Choose from gallery'),
            onPressed: () async {
              Navigator.of(context).pop();
              Uint8List? file = await pickImage(ImageSource.gallery);
              setState(() {
                _file = file;
              });
            },
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(20),
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
              print('Cancel');
            },
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      _file = null;
    });
  }
}
