import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snapshare_mobile/features/user/user_screen.dart';
import 'package:snapshare_mobile/models/post.dart';
import 'package:snapshare_mobile/models/user.dart';
import 'package:snapshare_mobile/services/search_service.dart';
import 'package:snapshare_mobile/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  List<User> users = [];
  List<Post> posts = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
    _searchController.dispose();
  }

  fetchSearchedData() async {
    setState(() {
      _isLoading = true;
    });
    List results = await _searchService.search(
        context: context, search: _searchController.text);

    users = results[0];
    posts = results[1];
    setState(() {
      _isLoading = false;
    });
  }

  _onSearchChanged(String query) async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 650), () {
      if (query.trim() != '') {
        fetchSearchedData();
      } else {
        users = [];
        posts = [];
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search for user, posts',
          ),
          onChanged: _onSearchChanged,
          // onFieldSubmitted: (String _) {
          //   fetchSearchedData();
          // },
        ),
      ),
      body: _isLoading
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserScreen(userId: users[index].id),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        users[index].image,
                      ),
                    ),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          users[index].account,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          users[index].name,
                          style: const TextStyle(
                            fontSize: 15,
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
