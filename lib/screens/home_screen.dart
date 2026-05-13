import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amordaily/providers/love_provider.dart';
import 'package:amordaily/utils/constants.dart';
import 'dart:ui';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:amordaily/utils/quotes_data.dart';
import 'package:amordaily/utils/app_localizations.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _floatController;
  late Animation<double> _heartScale;
  late Animation<double> _floatY;
  String? _currentQuote;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _heartScale = Tween<double>(begin: 1.0, end: 1.28).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOutSine),
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);
    _floatY = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    /* Pick a random quote each time screen is initialized */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<LoveProvider>(context, listen: false);
      setState(() {
        _currentQuote = QuotesData.getRandomQuote(provider.story.language);
      });
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoveProvider>(
      builder: (context, loveProvider, _) {
        if (loveProvider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final story = loveProvider.story;
        final loc = loveProvider.loc;
        final nextMilestone = _getNextMilestone(loveProvider);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                  Text(
                    loc.t('our_love_story'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 3,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  /* Avatars overlapping with floating heart */
                  AnimatedBuilder(
                    animation: _floatY,
                    builder: (context, _) {
                      return Transform.translate(
                        offset: Offset(0, _floatY.value),
                        child: _buildAvatarRow(story, loveProvider),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  _buildCounter(loveProvider.daysTogether, loc),
                  const SizedBox(height: 8),
                  Text(
                    '${story.partner1Name} & ${story.partner2Name}  •  ${loc.t('since')} ${AppLocalizations.formatDate(story.startDate, story.language)}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (story.showQuotes && _currentQuote != null) ...[
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.12),
                                      Colors.white.withValues(alpha: 0.03),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20,
                                      spreadRadius: -5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 32),
                                    const SizedBox(height: 12),
                                    Text(
                                      _currentQuote!,
                                      style: GoogleFonts.playfairDisplay(
                                        textStyle: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.95),
                                          fontSize: 16,
                                          height: 1.6,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  if (nextMilestone != null) _buildUpcomingCard(nextMilestone, loc),
                  const SizedBox(height: 120), /* Padding for bottom nav */
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildAvatarRow(LoveStory story, LoveProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* Partner 1 - left */
          Expanded(
            child: _buildAvatar(
              story.partner1Name,
              story.partner1ImagePath,
              story.partner1BirthDate,
              provider,
              isLeft: true,
            ),
          ),
          /* Floating heart center */
          Container(
            margin: const EdgeInsets.only(top: 30),
            child: AnimatedBuilder(
              animation: _heartScale,
              builder: (context, _) {
                return Transform.scale(
                  scale: _heartScale.value,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFF6B8A),
                      size: 60,
                    ),
                  ),
                );
              },
            ),
          ),
          /* Partner 2 - right */
          Expanded(
            child: _buildAvatar(
              story.partner2Name,
              story.partner2ImagePath,
              story.partner2BirthDate,
              provider,
              isLeft: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? path, DateTime? birthDate, LoveProvider provider, {required bool isLeft}) {
    return Container(
      width: 110,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B8A), Color(0xFFBF4080), Color(0xFF7B2D8B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor: const Color(0xFF3D1060),
              backgroundImage: path != null ? FileImage(File(path)) : null,
              child: path == null
                  ? const Icon(Icons.person_rounded, size: 40, color: Colors.white70)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          if (provider.story.showAge && birthDate != null)
            Text(
              '${provider.getAge(birthDate)} ${provider.loc.t('age')}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
          if (provider.story.showZodiac && birthDate != null)
            Container(
              margin: const EdgeInsets.only(top: 3),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Text(
                provider.getZodiacSign(birthDate),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCounter(int days, dynamic loc) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Colors.white, Color(0xFFFFB3C6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(b),
          child: Text(
            '$days',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 96,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.t('days_together'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 5,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic>? _getNextMilestone(LoveProvider provider) {
    final all = provider.getFilteredMilestones();
    return all.isEmpty ? null : all.first;
  }

  Widget _buildUpcomingCard(Map<String, dynamic> milestone, dynamic loc) {
    final date = milestone['date'] as DateTime;
    final daysLeft = date.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('upcoming_anniversary'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        milestone['title'] as String,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '$daysLeft\n${loc.t('days_unit')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
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
