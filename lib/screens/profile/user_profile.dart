import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/api_service.dart';
import '../../services/session_service.dart';
import '../library/library_screen.dart';
import '../login/login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  AppUser? _user;
  int _songCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F2937),
          content: Text(text),
        ),
      );
  }

  Future<void> _loadProfile() async {
    try {
      final results = await Future.wait([
        ApiService.fetchCurrentUser(),
        ApiService.fetchSongs(),
      ]);
      final user = results[0] as AppUser;
      final songs = results[1] as List<dynamic>;

      if (!mounted) {
        return;
      }

      setState(() {
        _user = user;
        _songCount = songs.length;
        _isLoading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
      _showMessage(
        'Unable to load profile from ${ApiService.baseUrl}. Check your backend connection.',
      );
    }
  }

  Future<void> _logout() async {
    await SessionService.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openLibrary() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LibraryScreen()),
    );
  }

  ImageProvider<Object>? _buildProfileImage() {
    final path = _user?.profileImage ?? '';
    if (path.isEmpty) {
      return null;
    }

    return NetworkImage(ApiService.resolveMediaUrl(path));
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }

    return '$count';
  }

  void _showAccountSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                _buildDetailRow('Username', _user?.username ?? ''),
                _buildDetailRow('Email', _user?.email ?? ''),
                _buildDetailRow('Mobile', _user?.mobile ?? 'Not provided'),
                _buildDetailRow(
                  'Status',
                  (_user?.isActive ?? false) ? 'Active' : 'Disabled',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF6D28D9)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = _buildProfileImage();
    final displayName = _user?.name.isNotEmpty == true
        ? _user!.name
        : 'Listener';
    final subtitle = _user?.email.isNotEmpty == true
        ? _user!.email
        : 'listener@example.com';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCFCFD),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: _openLibrary,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF6D28D9),
                              size: 24,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _showAccountSheet,
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Color(0xFF6D28D9),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFE9D5FF),
                                    Color(0xFF6D28D9),
                                  ],
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x336D28D9),
                                    blurRadius: 18,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  backgroundImage: profileImage,
                                  child: profileImage == null
                                      ? Text(
                                          displayName[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF6D28D9),
                                            fontSize: 32,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: 8,
                              child: Container(
                                height: 34,
                                width: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6D28D9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.settings_suggest_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        displayName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          _buildStatCard(_formatCount(_songCount), 'SONGS'),
                          const SizedBox(width: 10),
                          _buildStatCard('0', 'FOLLOWERS'),
                          const SizedBox(width: 10),
                          _buildStatCard('0', 'FOLLOWING'),
                        ],
                      ),
                      const SizedBox(height: 34),
                      const Text(
                        'LIBRARY & ACCOUNT',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildMenuItem(
                        icon: Icons.queue_music_rounded,
                        title: 'Playlists',
                        onTap: () => _showMessage('Playlists are coming soon.'),
                      ),
                      _buildMenuItem(
                        icon: Icons.history_rounded,
                        title: 'Recently Played',
                        onTap: _openLibrary,
                      ),
                      _buildMenuItem(
                        icon: Icons.manage_accounts_outlined,
                        title: 'Account Settings',
                        onTap: _showAccountSheet,
                      ),
                      _buildMenuItem(
                        icon: Icons.shield_outlined,
                        title: 'Privacy',
                        onTap: () =>
                            _showMessage('Privacy controls are coming soon.'),
                      ),
                      const SizedBox(height: 26),
                      Center(
                        child: SizedBox(
                          width: 170,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF8FAFC),
                              foregroundColor: const Color(0xFFEF4444),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _logout,
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
