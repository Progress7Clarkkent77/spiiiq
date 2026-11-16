import 'package:flutter/material.dart';

class SpiiiqFooter extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPolicy;
  final VoidCallback onRooms;
  final VoidCallback onAddPost;
  final VoidCallback onGames;
  final VoidCallback onProfile;

  const SpiiiqFooter({
    super.key,
    required this.isDark,
    required this.onPolicy,
    required this.onRooms,
    required this.onAddPost,
    required this.onGames,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _FooterItem(
                icon: Icons.policy_outlined,
                label: 'Policy',
                isDark: isDark,
                onTap: onPolicy,
              ),
              _FooterItem(
                icon: Icons.forum_outlined,
                label: 'Rooms',
                isDark: isDark,
                onTap: onRooms,
              ),
              _AddPostItem(isDark: isDark, onTap: onAddPost),
              _FooterItem(
                icon: Icons.emoji_events_outlined,
                label: 'Play',
                isDark: isDark,
                onTap: onGames,
              ),
              _FooterItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isDark: isDark,
                onTap: onProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _FooterItem({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPostItem extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _AddPostItem({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white : Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Add Post',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
