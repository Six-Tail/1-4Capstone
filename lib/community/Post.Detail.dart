import 'package:flutter/material.dart';

class PostDetail extends StatefulWidget {
  final Map<String, dynamic> post;

  PostDetail({required this.post});

  @override
  _PostDetailState createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  void _addComment(String comment) {
    setState(() {
      widget.post['comments'].add(comment);
    });
  }

  void _toggleLike() {
    setState(() {
      widget.post['likes']++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.post['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(widget.post['content']),
            SizedBox(height: 20),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.thumb_up),
                  onPressed: _toggleLike,
                ),
                Text(widget.post['likes'].toString()),
                SizedBox(width: 16),
                Icon(Icons.comment),
                Text(widget.post['comments'].length.toString()),
              ],
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.post['comments'].length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.post['comments'][index]),
                  );
                },
              ),
            ),
            TextField(
              decoration: InputDecoration(labelText: '댓글을 입력하세요'),
              onSubmitted: _addComment,
            ),
          ],
        ),
      ),
    );
  }
}
