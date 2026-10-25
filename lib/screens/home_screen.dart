// ============================================================
// lib/screens/home_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../config/app_config.dart';
import '../models/job_image.dart';
import '../services/supabase_service.dart';
import '../widgets/job_carousel.dart';
import '../widgets/side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // GlobalKeys para scroll suave a secciones
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  List<JobImage> _jobImages = [];
  bool _isLoading = true;
  int _menuIndex = 0;

  // ── Características / Servicios ─────────────────────────
  static const List<_Feature> _features = [
    _Feature(
      icon: Icons.tire_repair_rounded,
      title: 'Cambio de Llanta',
      description: 'Cambio rápido y seguro en carretera. Llanta desinflada, te ayudamos.',
    ),
    _Feature(
      icon: Icons.battery_charging_full_rounded,
      title: 'Paso de Corriente',
      description: 'Batería descargada? Te auxiliamos con corriente y te ponemos en marcha.',
    ),
    _Feature(
      icon: Icons.vpn_key_rounded,
      title: 'Cerrajería Vehicular',
      description: 'Apertura de vehículos sin daño. Llaves perdidas o encerradas dentro.',
    ),
    _Feature(
      icon: Icons.local_gas_station_rounded,
      title: 'Suministro de Gasolina',
      description: 'Te quedaste sin combustible. Te llevamos gasolina hasta donde estás.',
    ),
    _Feature(
      icon: Icons.headset_mic_rounded,
      title: 'Atención rápida y confiable',
      description:
          'Disponibles todos los días del año. Llámanos cuando nos necesites.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadImages() async {
    final images = await SupabaseService.fetchJobImages();
    if (mounted) {
      setState(() {
        _jobImages = images;
        _isLoading = false;
      });

      // Pre-cargar imágenes en la memoria de Flutter Web para evitar
      // parpadeos y que se queden en negro al deslizar el carrusel repetidamente
      for (final img in images) {
        if (mounted) {
          precacheImage(NetworkImage(img.imageUrl), context).catchError((_) {});
        }
      }
    }
  }

  void _scrollToKey(GlobalKey key, int menuIndex) {
    Navigator.of(context).pop(); // cierra drawer
    setState(() => _menuIndex = menuIndex);
    final context_ = key.currentContext;
    if (context_ != null) {
      Scrollable.ensureVisible(
        context_,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _openGoogleReview() async {
    Navigator.of(context).pop();
    final uri = Uri.parse(AppConfig.googleReviewUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el enlace de reseñas'),
          ),
        );
      }
    }
  }

  Future<void> _callPhone() async {
    final uri = Uri.parse('tel:${AppConfig.phoneNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp([String? serviceName]) async {
    // El número debe ir con el código de país pero sin el '+' (Ej: 50581695674)
    const String number = '50581695674';
    final String message = serviceName != null
        ? 'Hola Asistencia Vehicular Nic, necesito asistencia para *$serviceName* por favor.'
        : 'Hola Asistencia Vehicular Nic, necesito asistencia vehicular.';
    final uri = Uri.parse(
        'https://wa.me/$number?text=${Uri.encodeComponent(message)}');

    try {
      // webOnlyWindowName: '_blank' fuerza a que se abra en una nueva pestaña
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } catch (e) {
      debugPrint('Error al abrir WhatsApp: $e');
    }
  }

  Future<void> _openEmail() async {
    final uri = Uri.parse('mailto:${AppConfig.email}');

    try {
      // Al ejecutar esto, el navegador del usuario abrirá su cliente de correo predeterminado
      await launchUrl(uri);
    } catch (e) {
      debugPrint('Error al abrir el correo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF121212),
      drawer: SideMenu(
        currentIndex: _menuIndex,
        onMenuTap: () => _scrollToKey(_heroKey, 0),
        onFeaturesTap: () => _scrollToKey(_featuresKey, 1),
        onContactTap: () => _scrollToKey(_contactKey, 2),
        onReviewTap: _openGoogleReview,
      ),

      // ── AppBar ───────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: Color.fromARGB(255, 246, 249, 245),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'Menú',
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/logocircular.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.directions_car,
                  color: Color(AppConfig.primaryColorHex),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                AppConfig.companyName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (MediaQuery.of(context).size.width > 550) ...[
            TextButton.icon(
              onPressed: _callPhone,
              icon: const Icon(
                Icons.phone,
                color: Color(AppConfig.primaryColorHex),
                size: 18,
              ),
              label: Text(
                AppConfig.phoneNumber,
                style: GoogleFonts.poppins(
                  color: const Color(AppConfig.primaryColorHex),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ] else if (MediaQuery.of(context).size.width > 370) ...[
            IconButton(
              onPressed: _callPhone,
              icon: const Icon(
                Icons.phone,
                color: Color(AppConfig.primaryColorHex),
                size: 20,
              ),
              tooltip: 'Llamar a ${AppConfig.phoneNumber}',
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),

      // ── Body ─────────────────────────────────────────────
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ── SECCIÓN HERO ─────────────────────────────
            _HeroSection(key: _heroKey),

            // ── CARRUSEL DE TRABAJOS ─────────────────────
            _CarouselSection(
              isLoading: _isLoading,
              jobImages: _jobImages,
              onRefresh: _loadImages,
            ),

            // ── CARACTERÍSTICAS ──────────────────────────
            _FeaturesSection(
              key: _featuresKey,
              features: _features,
              scrollController: _scrollController,
              onServiceTap: (service) => _openWhatsApp(service),
            ),

            // ── CONTACTO ─────────────────────────────────
            _ContactSection(
              key: _contactKey,
              onCall: _callPhone,
              onWhatsApp: _openWhatsApp,
              onEmail: _openEmail,
              onReview: _openGoogleReview,
            ),

            // ── FOOTER ──────────────────────────────────
            _Footer(),
          ],
        ),
      ),

      // ── FAB WhatsApp ─────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWhatsApp,
        backgroundColor: const Color.fromARGB(255, 2, 7, 2),
        icon: const FaIcon(
          FontAwesomeIcons.whatsapp,
          color: Color.fromARGB(255, 12, 145, 12),
        ),
        label: Text(
          'WhatsApp',
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 5, 209, 5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECCIÓN: HERO
// ============================================================
class _HeroSection extends StatelessWidget {
  const _HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleFontSize = width < 450 ? 28.0 : (width < 700 ? 34.0 : 42.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: width < 500 ? 16 : 32,
        vertical: width < 500 ? 40 : 64,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          //colores del fondo degradado de la sección hero
          colors: [
            Color.fromARGB(255, 10, 75, 130),
            Color.fromARGB(255, 232, 108, 0),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
                width: width < 500 ? 110 : 130,
                height: width < 500 ? 110 : 130,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(AppConfig.primaryColorHex).withAlpha(30),
                  border: Border.all(
                    color: const Color(AppConfig.primaryColorHex)
                        .withAlpha(140),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(AppConfig.primaryColorHex)
                          .withAlpha(60),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    '/assets/images/logocircular.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_shipping_rounded,
                      color: Color(AppConfig.primaryColorHex),
                      size: 60,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.7, 0.7)),

          const SizedBox(height: 28),

          Text(
                AppConfig.companyName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.3),

          const SizedBox(height: 12),

          Text(
            AppConfig.slogan,
            style: GoogleFonts.poppins(color: Colors.white60, fontSize: 16),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

          const SizedBox(height: 32),

          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              _HeroChip(
                icon: Icons.access_time_rounded,
                label: AppConfig.schedule,
              ),
              _HeroChip(
                icon: Icons.verified_rounded,
                label: 'Asistencia inmediata',
              ),
            ],
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _HeroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(AppConfig.primaryColorHex), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECCIÓN: CARRUSEL
// ============================================================
class _CarouselSection extends StatelessWidget {
  final bool isLoading;
  final List<JobImage> jobImages;
  final VoidCallback onRefresh;

  const _CarouselSection({
    required this.isLoading,
    required this.jobImages,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const _SectionTitle(
            title: 'Nuestros Trabajos',
            subtitle: 'Mira algunos de nuestros servicios realizados',
          ),
          const SizedBox(height: 32),
          if (isLoading)
            const SizedBox(
              height: 340,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(AppConfig.primaryColorHex),
                ),
              ),
            )
          else
            JobCarousel(images: jobImages),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white54,
              size: 16,
            ),
            label: Text(
              'Actualizar',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECCIÓN: CARACTERÍSTICAS
// ============================================================
class _FeaturesSection extends StatelessWidget {
  final List<_Feature> features;
  final ScrollController? scrollController;
  final void Function(String serviceName)? onServiceTap;

  const _FeaturesSection({
    super.key,
    required this.features,
    this.scrollController,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          const _SectionTitle(
            title: 'Nuestros Servicios',
            subtitle: '¿En qué te podemos ayudar hoy?',
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800
                  ? 3
                  : (constraints.maxWidth > 550 ? 2 : 1);
              final childAspectRatio = constraints.maxWidth > 800
                  ? 1.15
                  : (constraints.maxWidth > 550 ? 1.05 : 1.35);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _FeatureCard(
                    feature: features[index],
                    index: index,
                    scrollController: scrollController,
                    onTap: onServiceTap,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;

  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;
  final int index;
  final ScrollController? scrollController;
  final void Function(String serviceName)? onTap;

  const _FeatureCard({
    required this.feature,
    required this.index,
    this.scrollController,
    this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_checkVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
    // Verificación de respaldo para asegurar visibilidad en cualquier dispositivo
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_isVisible) {
        _checkVisibility();
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_checkVisibility);
    super.dispose();
  }

  void _checkVisibility() {
    if (_isVisible || !mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final position = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      // Cuando la tarjeta entra en el rango visible (92% de la altura de la ventana)
      if (position.dy < screenHeight * 0.92) {
        setState(() {
          _isVisible = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _isVisible
            ? (_hovered ? const Offset(0, -0.035) : Offset.zero)
            : const Offset(0, 0.22),
        duration: _isVisible
            ? (_hovered
                ? const Duration(milliseconds: 200)
                : const Duration(milliseconds: 650))
            : const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _isVisible ? (_hovered ? 1.025 : 1.0) : 0.94,
          duration: _isVisible
              ? (_hovered
                  ? const Duration(milliseconds: 200)
                  : const Duration(milliseconds: 650))
              : const Duration(milliseconds: 650),
          curve: Curves.easeOutCubic,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => widget.onTap?.call(widget.feature.title),
              onHover: (hovering) => setState(() => _hovered = hovering),
              onHighlightChanged: (highlighted) =>
                  setState(() => _hovered = highlighted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _hovered
                        ? [
                            const Color(0xFF1E293B),
                            const Color(0xFF0F172A),
                          ]
                        : [
                            const Color(0xFF1B2232),
                            const Color(0xFF121722),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _hovered
                        ? const Color(AppConfig.cyanColorHex)
                        : Colors.white.withAlpha(22),
                    width: _hovered ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(_hovered ? 150 : 100),
                      blurRadius: _hovered ? 24 : 16,
                      offset: Offset(0, _hovered ? 12 : 7),
                    ),
                    BoxShadow(
                      color: const Color(AppConfig.cyanColorHex).withAlpha(
                        _hovered ? 85 : 20,
                      ),
                      blurRadius: _hovered ? 20 : 10,
                      spreadRadius: _hovered ? 1 : 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge circular con brillo
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            const Color(AppConfig.primaryColorHex).withAlpha(40),
                        border: Border.all(
                          color: _hovered
                              ? const Color(AppConfig.cyanColorHex)
                              : const Color(AppConfig.cyanColorHex).withAlpha(120),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _hovered
                                ? const Color(AppConfig.cyanColorHex).withAlpha(70)
                                : const Color(AppConfig.primaryColorHex).withAlpha(30),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          widget.feature.icon,
                          color: _hovered
                              ? const Color(AppConfig.cyanColorHex)
                              : const Color(0xFF38BDF8),
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.feature.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.feature.description,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // Indicador de acción interactivo
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pedir asistencia',
                          style: GoogleFonts.poppins(
                            color: _hovered
                                ? const Color(AppConfig.accentColorHex)
                                : const Color(0xFF64748B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 13,
                          color: _hovered
                              ? const Color(AppConfig.accentColorHex)
                              : const Color(0xFF64748B),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECCIÓN: CONTACTO
// ============================================================
class _ContactSection extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback onEmail;
  final VoidCallback onReview;

  const _ContactSection({
    super.key,
    required this.onCall,
    required this.onWhatsApp,
    required this.onEmail,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        children: [
          const _SectionTitle(
            title: 'Contáctanos',
            subtitle: 'Estamos listos para ayudarte ahora mismo',
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _ContactCard(
                icon: Icons.phone_rounded,
                title: 'Llamar',
                subtitle: AppConfig.phoneNumber,
                color: const Color(0xFF4CAF50),
                onTap: onCall,
              ),
              _ContactCard(
                icon: Icons.chat_bubble_rounded,
                title: 'WhatsApp',
                subtitle: 'Escríbenos al instante',
                color: const Color(0xFF25D366),
                onTap: onWhatsApp,
              ),
              _ContactCard(
                icon: Icons.email_rounded,
                title: 'Email',
                subtitle: AppConfig.email,
                color: const Color(0xFF2196F3),
                onTap: onEmail,
              ),
              _ContactCard(
                icon: Icons.star_rounded,
                title: 'Déjanos tu reseña',
                subtitle: 'Tu opinión en Google',
                color: const Color(0xFFFFC107),
                onTap: onReview,
              ),
            ],
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(AppConfig.primaryColorHex),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  AppConfig.address,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 180,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withAlpha(30)
                : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered ? widget.color.withAlpha(160) : Colors.white12,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: widget.color.withAlpha(50), blurRadius: 20)]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 36),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FOOTER
// ============================================================
class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.directions_car,
                    color: Color(AppConfig.primaryColorHex),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppConfig.companyName,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© 2026 ${AppConfig.companyName} · Todos los derechos reservados',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HELPER: Título de sección reutilizable
// ============================================================
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(AppConfig.primaryColorHex),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
