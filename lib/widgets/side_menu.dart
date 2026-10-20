// ============================================================
// lib/widgets/side_menu.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onFeaturesTap;
  final VoidCallback onContactTap;
  final VoidCallback onReviewTap;
  final int currentIndex;

  const SideMenu({
    super.key,
    required this.onMenuTap,
    required this.onFeaturesTap,
    required this.onContactTap,
    required this.onReviewTap,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(AppConfig.secondaryColorHex),
      child: Column(
        children: [
          // ── Header del menú ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 28),
            decoration: const BoxDecoration(
              color: Color(AppConfig.primaryColorHex),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.directions_car, color: Colors.white, size: 36),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppConfig.companyName,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppConfig.slogan,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Ítems del menú ───────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _MenuItem(
                  icon: Icons.home_rounded,
                  label: 'Inicio',
                  index: 0,
                  currentIndex: currentIndex,
                  onTap: onMenuTap,
                ),
                _MenuItem(
                  icon: Icons.star_rounded,
                  label: 'Características',
                  index: 1,
                  currentIndex: currentIndex,
                  onTap: onFeaturesTap,
                ),
                _MenuItem(
                  icon: Icons.phone_rounded,
                  label: 'Contactar',
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onContactTap,
                ),
                const Divider(color: Colors.white24, height: 32),
                // Review → abre Google
                _MenuItem(
                  icon: Icons.rate_review_rounded,
                  label: 'Dejar Reseña',
                  index: 3,
                  currentIndex: currentIndex,
                  onTap: onReviewTap,
                  isExternal: true,
                ),
              ],
            ),
          ),

          // ── Footer ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '© ${DateTime.now().year} ${AppConfig.companyName}',
              style: GoogleFonts.poppins(
                color: Colors.white38,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;
  final bool isExternal;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.isExternal = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(AppConfig.primaryColorHex).withAlpha(40)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(
                color: const Color(AppConfig.primaryColorHex).withAlpha(80))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(
            icon,
            color: isActive
                ? const Color(AppConfig.primaryColorHex)
                : Colors.white60,
            size: 22,
          ),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.white : Colors.white70,
              fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          trailing: isExternal
              ? const Icon(Icons.open_in_new,
                  color: Colors.white38, size: 16)
              : null,
          onTap: onTap,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
