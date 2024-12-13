import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To load local assets

class AllMembersPage extends StatefulWidget {
  @override
  _AllMembersPageState createState() => _AllMembersPageState();
}

class _AllMembersPageState extends State<AllMembersPage> {
  // Controller for the search box
  TextEditingController _searchController = TextEditingController();

  // Method to load data from the JSON file
  Future<List<dynamic>> _loadMembers() async {
    // Load the JSON file from assets
    String data = await rootBundle.loadString('../assets/members.json');
    List<dynamic> members = json.decode(data);
    return members;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Members"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Members...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  // Update the search query
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _loadMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading members'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No members found.'));
          } else {
            // Display list of members
            var members = snapshot.data!;

            // Optionally, filter members based on the search query
            if (_searchController.text.isNotEmpty) {
              members = members.where((member) {
                return member['name']
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase());
              }).toList();
            }

            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                var member = members[index];
                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  shadowColor: Colors.grey.withOpacity(0.2),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(member['avatar_url'] ?? 'https://via.placeholder.com/150'),
                            backgroundColor: Colors.grey.shade200,
                            child: member['avatar_url']?.isEmpty ?? true
                                ? const Icon(Icons.person, size: 32, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          // Member Name
                          Text(
                            member['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
