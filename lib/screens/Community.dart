import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: CommunityListScreen()));
}

class CommunityListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Community')),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No communities found'));
          }
          List<DocumentSnapshot> groups = snapshot.data!.docs;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> groupData = groups[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  // Navigate to group chat screen with group ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupChatScreen(groupId: groups[index].id)),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          // Use AssetImage for default images
                          backgroundImage: AssetImage('assets/logo.jpg'),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(groupData['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4),
                            Text(groupData['description'], style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCommunityScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}




class CreateCommunityScreen extends StatefulWidget {
  @override
  _CreateCommunityScreenState createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final List<String> categories = ['Food', 'Healthcare', 'Public Chat', 'Other'];
  final TextEditingController _searchController = TextEditingController();
  late Future<List<DocumentSnapshot>> searchResultsFuture;
  List<Map<String, dynamic>> selectedUsers = [];

  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupDescriptionController = TextEditingController();
  TextEditingController groupLocationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    groupNameController.dispose();
    groupDescriptionController.dispose();
    groupLocationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    searchUsers(_searchController.text);
  }

  searchUsers(String query) {
    if (query.isNotEmpty) {
      setState(() {
        searchResultsFuture = FirebaseFirestore.instance
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: query)
            .where('username', isLessThan: query + 'z')
            .get()
            .then((snapshot) => snapshot.docs);
      });
    } else {
      setState(() {
        searchResultsFuture = Future.value([]);
      });
    }
  }

  Widget buildSearchResults() {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found'));
        }
        List<DocumentSnapshot> docs = snapshot.data!;
        List<Widget> userTiles = docs.map((doc) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          bool isSelected = selectedUsers.any((selectedUser) => selectedUser['id'] == doc.id);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(userData['image_url'] ?? ''),
            ),
            title: Text(userData['username'] ?? ''),
            trailing: isSelected
                ? Icon(Icons.check, color: Colors.green)
                : IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: () {
                setState(() {
                  selectedUsers.add({
                    'id': doc.id,
                    ...userData,
                  });
                });
              },
            ),
          );
        }).toList();

        return Column(
          children: [
            ListView(
              children: userTiles,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
            ),
            SizedBox(height: 24),
            Text('Selected Members:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...selectedUsers.map((user) => ListTile(
              title: Text(user['username']),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['image_url'] ?? ''),
              ),
            )),
          ],
        );
      },
    );
  }

  Widget buildSelectedMembersSection() {
    if (selectedUsers.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Selected Members:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...selectedUsers.map((user) => ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user['image_url'] ?? ''),
          ),
          title: Text(user['username']),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () => setState(() {
              selectedUsers.removeWhere((selected) => selected['id'] == user['id']);
            }),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Community'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildSectionTitle('Group Name'),
            buildTextField(hint: 'Enter Group Name', controller: groupNameController),
            buildSectionTitle('Description'),
            buildTextField(hint: 'Enter Description', controller: groupDescriptionController),
            buildSectionTitle('Category'),
            buildDropdown(categories),
            buildSectionTitle('Location'),
            buildTextField(hint: 'Enter Location', controller: groupLocationController),
            buildSectionTitle('Add Members'),
            buildTextField(hint: 'Search', withIcon: true, controller: _searchController),
            SizedBox(height: 24),
            if (_searchController.text.isNotEmpty) buildSearchResults(),
            buildSelectedMembersSection(),
            buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Future<void> createCommunity() async {
    if (groupNameController.text.isEmpty ||
        groupDescriptionController.text.isEmpty ||
        selectedUsers.isEmpty ||
        categories == null ||
        groupLocationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please fill in all the fields and select at least one member."),
      ));
      return;
    }

    try {
      DocumentReference groupDocRef = await FirebaseFirestore.instance.collection('groups').add({
        'name': groupNameController.text,
        'description': groupDescriptionController.text,
        'category': categories,
        'location': groupLocationController.text,
        'members': selectedUsers.map((user) => user['id']).toList(),
      });

      await FirebaseFirestore.instance.collection('messages').add({
        'groupId': groupDocRef.id,
        'text': 'Welcome to the group!',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Community created successfully!"),
      ));

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GroupChatScreen(groupId: groupDocRef.id)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to create community: $e"),
      ));
    }
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget buildTextField({required String hint, TextEditingController? controller, bool withIcon = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          prefixIcon: withIcon ? Icon(Icons.search, color: Colors.grey) : null,
        ),
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget buildDropdown(List<String> categories) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        items: categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (String? value) {},
      ),
    );
  }

  Widget buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(
            onPressed: createCommunity,
            child: Text('Create Community'),
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              onPrimary: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  GroupChatScreen({required this.groupId});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('groupId', isEqualTo: widget.groupId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages found'));
                }

                return ListView(
                  reverse: true,
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> messageData = document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(messageData['text']),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration.collapsed(
                hintText: "Send a message...",
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('messages').add({
          'groupId': widget.groupId,
          'text': _messageController.text,
          'timestamp': Timestamp.now(),
        });
        _messageController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to send message: $e"),
        ));
      }
    }
  }
}
