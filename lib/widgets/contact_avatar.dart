import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/initials_helper.dart';

class ContactAvatar extends StatelessWidget {
  final String name;
  final double size;
  final int? type;

  const ContactAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    final initials = initialsFromName(name);
    final bgColor = AppColors.colorForName(name);
    final textColor = AppColors.textColorForBackground(bgColor);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class NodeAvatar extends StatelessWidget {
  final String name;
  final int type;
  final double size;

  const NodeAvatar({
    super.key,
    required this.name,
    required this.type,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final initials = initialsFromName(name);
    final bgColor = AppColors.colorForName(name);
    final textColor = AppColors.textColorForBackground(bgColor);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: bgColor,
      child: Text(
        initials,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
