import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eldergit/classes/newsclass.dart';
import 'package:eldergit/screens/addnews.dart';
import 'package:eldergit/screens/newsdetail.dart';



class ViewNewsScreen extends StatefulWidget {
  @override
  _ViewNewsScreenState createState() => _ViewNewsScreenState();
}

class _ViewNewsScreenState extends State<ViewNewsScreen> {
  final Stream<List<NewsItem>> _newsStream = FirebaseFirestore.instance
      .collection('news')
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => NewsItem.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
      .toList());

  bool _isCharityWorker = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _deleteNews(String newsId) async {
    await FirebaseFirestore.instance.collection('news').doc(newsId).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('News deleted successfully')));
  }

  Future<void> _checkUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final isCharityWorker = userData.data()?['userType'] == "Charity Worker";
      setState(() {
        _isCharityWorker = isCharityWorker;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View News'),
      ),
      body: StreamBuilder<List<NewsItem>>(
        stream: _newsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No news available'));
          }
          final newsItems = snapshot.data!;
          return ListView.builder(
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              final item = newsItems[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(newsItem: item),
                  ));
                },
                child: Card(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.imageUrl.isNotEmpty)
                        Image.network(item.imageUrl, width: double.infinity, height: 200, fit: BoxFit.cover),
                      ListTile(
                        title: Text(item.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Text(item.content),
                        trailing: _isCharityWorker ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditNewsScreen(newsItem: item)));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteNews(item.id),
                            ),
                          ],
                        ) : SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _isCharityWorker ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditNewsScreen()));
        },
        child: Icon(Icons.add),
      ) : null,
    );
  }
}
