// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/services/auth_service.dart';
import 'package:snapshare_mobile/services/storage_service.dart';
import 'package:snapshare_mobile/services/user_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';
import 'package:snapshare_mobile/utils/utils.dart';

class EditUserScreen extends StatefulWidget {
  static const String routeName = '/edit-user';
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  User? user;
  Uint8List? _file;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  bool _isLoading = false;
  bool _isSubmiting = false;

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    setState(() {
      _isLoading = true;
    });

    AuthService authService = AuthService();

    try {
      user = await authService.getUserData(context);
    } catch (e) {
      // print(e);
      showSnackBar(context, e.toString());
    }

    _nameController = TextEditingController(text: user!.name);
    _descriptionController = TextEditingController(text: user!.description);
    // print(user!.name);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    // _nameController.dispose();
    // _descriptionController.dispose();
  }

  _submit({
    required String name,
    required String description,
    required String image,
  }) async {
    setState(() {
      _isSubmiting = true;
    });

    String avatarImageUrl = image;

    try {
      if (_file != null) {
        avatarImageUrl = await _storageService.uploadImageToStorage(
          folderName: 'images',
          file: _file!,
        );
      }

      User? udpatedUser = await _userService.updateUserByUserId(
        context: context,
        name: name,
        description: description,
        image: avatarImageUrl,
        userId: user!.id,
      );
    } catch (e) {
      // print(e);
      showSnackBar(context, e.toString());
    }

    setState(() {
      _file = null;
      _isSubmiting = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Edit User'),
        actions: [
          IconButton(
            onPressed: () async {
              await _submit(
                name: _nameController.text,
                description: _descriptionController.text,
                image: user!.image,
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _isSubmiting
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
                      child: _file != null
                          ? Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: MemoryImage(_file!),
                                  fit: BoxFit.fill,
                                  alignment: FractionalOffset.topCenter,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.network(
                                user!.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 5, left: 20, right: 20, bottom: 20),
                    child: Column(
                      children: [
                        const Text('Update Image'),
                        IconButton(
                          icon: const Icon(Icons.upload),
                          onPressed: () => _selectImage(context),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelStyle: TextStyle(
                                  fontSize: 28,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                labelText: 'Name',
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
}
