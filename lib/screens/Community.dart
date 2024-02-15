import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';


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
              showSearch(context: context, delegate: GroupSearchDelegate());
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
              bool isMember = (groupData['members'] as List).contains(FirebaseAuth.instance.currentUser!.uid);

              return GestureDetector(
                onTap: () {
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage('assets/logo.jpg'),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(groupData['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Members: ${groupData['members'].length}'),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (isMember) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Already Joined"),
                                    content: Text("You are already a member of this group."),
                                    actions: [
                                      TextButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              FirebaseFirestore.instance.collection('groups').doc(groups[index].id).update({
                                'members': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
                              }).then((value) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Joined Successfully"),
                                      content: Text("You have successfully joined this group."),
                                      actions: [
                                        TextButton(
                                          child: Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }).catchError((error) {
                                print('Error joining group: $error');
                              });
                            }
                          },
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



class GroupSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .where('name', isEqualTo: query) // Filter groups by name
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No groups found'));
        }
        List<DocumentSnapshot> groups = snapshot.data!.docs;
        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> groupData = groups[index].data() as Map<String, dynamic>;
            // Build UI for each group
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(groupData['image_url'] ?? ''), // Assuming 'image_url' field contains image URL
              ),
              title: Text(groupData['name']),
              subtitle: Text('Members: ${groupData['members'].length}'),
              // Implement onTap to navigate to group details or chat screen
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupChatScreen(groupId: groups[index].id)),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(); // Implement suggestions as the user types
  }
}





class CreateCommunityScreen extends StatefulWidget {
  @override
  _CreateCommunityScreenState createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final List<String> categories = [
    'Food',
    'Healthcare',
    'Public Chat',
    'Other'
  ];
  final TextEditingController _searchController = TextEditingController();
  late Future<List<DocumentSnapshot>> searchResultsFuture = Future.value(
      []); // Initialize here
  List<Map<String, dynamic>> selectedUsers = [];

  TextEditingController groupNameController = TextEditingController();
  TextEditingController groupDescriptionController = TextEditingController();
  TextEditingController groupLocationController = TextEditingController();
  String? selectedCategory; // Variable to store the selected category

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
          bool isSelected = selectedUsers.any((
              selectedUser) => selectedUser['id'] == doc.id);
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
            Text('Selected Members:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...selectedUsers.map((user) =>
                ListTile(
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
        ...selectedUsers.map((user) =>
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user['image_url'] ?? ''),
              ),
              title: Text(user['username']),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () =>
                    setState(() {
                      selectedUsers.removeWhere((selected) =>
                      selected['id'] == user['id']);
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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: groupNameController,
              decoration: InputDecoration(labelText: 'Community Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: groupDescriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: groupLocationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 16),
            // Category selection dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16),
            buildSelectedMembersSection(),
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search members'),
            ),
            SizedBox(height: 16),
            buildSearchResults(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Create the new community
                String groupId = '';
                try {
                  DocumentReference groupRef = await FirebaseFirestore.instance
                      .collection('groups').add({
                    'name': groupNameController.text,
                    'description': groupDescriptionController.text,
                    'location': groupLocationController.text,
                    'category': selectedCategory,
                    'members': selectedUsers.map((user) => user['id']).toList(),
                  });
                  groupId = groupRef.id;
                } catch (e) {
                  print('Error creating group: $e');
                }
                if (groupId.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        GroupChatScreen(groupId: groupId)),
                  );
                }
              },
              child: Text('Create Community'),
            ),
          ],
        ),
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

  String _groupName = ''; // Variable to store the group name

  @override
  void initState() {
    super.initState();
    // Fetch the group name when the screen is initialized
    _fetchGroupName();
  }

  // Method to fetch the group name from Firestore
  Future<void> _fetchGroupName() async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();
      if (groupSnapshot.exists) {
        Map<String, dynamic> groupData = groupSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _groupName = groupData['name'] ?? ''; // Assign the group name to the variable
        });
      }
    } catch (e) {
      print('Error fetching group name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_groupName), // Use the group name as the app bar title
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
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No messages found'));
                }

                List<DocumentSnapshot> documents = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                    documents[index].data() as Map<String, dynamic>;

                    // Determine if the message is sent by the current user
                    final bool isCurrentUser =
                        messageData['senderId'] == FirebaseAuth.instance.currentUser?.uid;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          messageData['image_url'] ?? '',
                        ),
                      ),
                      title: Container(
                        alignment: isCurrentUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? Colors.blue[100] // Your message bubble color
                                : Colors.grey[300], // Other user's message bubble color
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isCurrentUser) Text(messageData['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text(
                                messageData['text'],
                                style: TextStyle(fontSize: 16),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Send a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.0),
              onTap: _sendMessage,
              child: Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to fetch user's photo URL from Firestore
  Future<String> _getUserPhotoUrl(String userId) async {
    String photoUrl = ''; // Default photo URL

    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
        userSnapshot.data() as Map<String, dynamic>;
        // Assuming the field name for the image URL is 'image'
        photoUrl = userData['image_url'] ?? ''; // Get image URL from user data
      }
    } catch (e) {
      print('Error fetching user photo URL: $e');
    }

    return photoUrl;
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser; // Get current user
      if (user != null) {
        // Fetch user's photo URL from Firestore
        String pictureUrl = await _getUserPhotoUrl(user.uid);

        await FirebaseFirestore.instance.collection('messages').add({
          'groupId': widget.groupId,
          'text': _messageController.text,
          'senderId': user.uid, // Include sender's ID in the message
          'username': user.displayName ?? 'Unknown',
          // Use display name from Firebase Authentication
          'image_url': pictureUrl,
          'timestamp': Timestamp.now(),
        });
        _messageController.clear();
      }
    }
  }
}


