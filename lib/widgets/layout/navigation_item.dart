import 'package:flutter/material.dart';

class NavigationItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool active;
  final Function onTap;

  const NavigationItem(
    this.title, {
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            onTap();
          },
          child: ListTile(
            selected: active,
            title: Text(title),
            leading: Icon(
              icon,
            ),
          ),
        ),
      ),
    );
  }
}
