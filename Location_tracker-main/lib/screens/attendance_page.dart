import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'all_members_page.dart';
import '../models/member.dart';
import 'page1.dart';
import 'page2.dart';
import 'showMap.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = _loadMembers();
  }

  Future<List<Member>> _loadMembers() async {
    String jsonString = await rootBundle.loadString('assets/members.json');
    List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Member.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3DC2),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'ATTENDANCE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // All Members Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.03,
            ),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(
                  Icons.group_outlined,
                  color: Color(0xFF5C3DC2),
                  size: 24,
                ),
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AllMembersPage()),
                    );
                  },
                  child: const Text(
                    'All Members',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: Color(0xFF5C3DC2),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Date Selector
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {},
                ),
                Text(
                  DateFormat('EEE, MMM d yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: const Color(0xFF1A1F36),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Member List
          Expanded(
            child: FutureBuilder<List<Member>>(
              future: _membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No members found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final Member member = snapshot.data![index];
                    return _buildMemberTile(member, screenWidth);
                  },
                );
              },
            ),
          ),
          // Bottom Navigation Container
          Container(
            color: const Color(0xFF5C3DC2),
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MembersMapPage()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, color: Colors.white, size: 24),
                  SizedBox(width: screenWidth * 0.02),
                  const Text(
                    'View Members Map',
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
        ],
      ),
    );
  }

  Widget _buildMemberTile(Member member, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: screenWidth * 0.08,
            backgroundImage: NetworkImage(member.avatarUrl),
          ),
          SizedBox(width: screenWidth * 0.03),
          // Member Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1F36),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (member.loginTime != null)
                      _buildStatusIcon(
                          Icons.arrow_upward, member.loginTime!, Colors.green),
                    if (member.logoutTime != null)
                      _buildStatusIcon(
                          Icons.arrow_downward, member.logoutTime!, Colors.red),
                    if (member.status == "WORKING")
                      _buildStatusChip('WORKING', Colors.green),
                    if (member.status == "NOT LOGGED IN YET")
                      _buildStatusChip('NOT LOGGED IN YET', Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          // Right Icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExpandableMapPage(member: member)),
                  );
                },
                color: const Color(0xFF5C3DC2),
              ),
              IconButton(
                icon: const Icon(Icons.location_on_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GoogleMapScreen(member: member)),
                  );
                },
                color: const Color(0xFF5C3DC2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: -0.785398, // 45 degrees
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}