import 'package:flutter/material.dart';

ListTile buildListTile(BuildContext context, String title, Widget page) {
  return ListTile(
    title: Text(title),
    trailing: Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    },
  );
}
