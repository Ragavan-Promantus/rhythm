import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';

class CommonAppBar extends StatelessWidget {
  const CommonAppBar({
    required this.title,
    required this.user,
    required this.onAvatarTap,
    this.subtitle,
    this.leading,
    this.centerTitle = false,
    super.key,
  });

  final String title;
  final AppUser? user;
  final VoidCallback onAvatarTap;
  final String? subtitle;
  final Widget? leading;
  final bool centerTitle;

  ImageProvider<Object>? _buildProfileImage() {
    final path = user?.profileImage ?? '';
    if (path.isEmpty) {
      return null;
    }

    return NetworkImage(ApiService.resolveMediaUrl(path));
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = _buildProfileImage();
    const titleGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
    );

    return Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Expanded(
          child: Column(
            crossAxisAlignment: centerTitle
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => titleGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
                child: Text(
                  title,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.9,
                  ),
                ),
              ),
              if ((subtitle ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  textAlign: centerTitle ? TextAlign.center : TextAlign.start,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (leading != null && centerTitle) const SizedBox(width: 8),
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 21,
              backgroundColor: const Color(0xFFF8FAFC),
              backgroundImage: profileImage,
              child: profileImage == null
                  ? const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF64748B),
                      size: 22,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
