import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  const MyListTile({super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 35.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black,
        ),
        onTap: onTap,
        title: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),),
      ),
    );
  }
}