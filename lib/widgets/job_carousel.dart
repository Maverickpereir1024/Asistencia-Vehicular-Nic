// ============================================================
// lib/widgets/job_carousel.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';
import '../models/job_image.dart';

class JobCarousel extends StatefulWidget {
  final List<JobImage> images;

  const JobCarousel({super.key, required this.images});

  @override
  State<JobCarousel> createState() => _JobCarouselState();
}

class _JobCarouselState extends State<JobCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const SizedBox(
        height: 320,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(AppConfig.primaryColorHex),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.images.length,
          itemBuilder: (context, index, realIndex) {
            final image = widget.images[index];
            return _CarouselCard(
              key: ValueKey('carousel_${image.imageUrl}_$index'),
              image: image,
            );
          },
          options: CarouselOptions(
            height: 340,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 600),
            autoPlayCurve: Curves.easeInOut,
            enableInfiniteScroll: widget.images.length > 1,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: widget.images.length,
          effect: const ExpandingDotsEffect(
            dotColor: Color(0xFFCBD5E1),
            activeDotColor: Color(AppConfig.accentColorHex),
            dotHeight: 8,
            dotWidth: 8,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final JobImage image;

  const _CarouselCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen nativa con cache en memoria y manejo fluido en Flutter Web
            Image.network(
              image.imageUrl,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFF1E293B),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2.5,
                      color: const Color(AppConfig.accentColorHex),
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1E293B),
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.car_repair_rounded,
                          color: Colors.white54,
                          size: 44,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          image.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Gradiente inferior para legibilidad del texto
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(190),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),

            // Título y descripción del servicio
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    image.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (image.description != null && image.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      image.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
