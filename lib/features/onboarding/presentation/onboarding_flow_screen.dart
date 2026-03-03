import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  static const _primary = Color(0xFF1A227F);
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markOnboardingSeen() async {
    final settingsBox = Hive.box(AppConstants.settingsBox);
    await settingsBox.put(AppConstants.onboardingSeenKey, true);
  }

  Future<void> _nextOrFinish() async {
    if (_index < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _markOnboardingSeen();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _skip() async {
    await _markOnboardingSeen();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              index: _index,
              onBack: _index == 0
                  ? null
                  : () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                      );
                    },
              onSkip: _skip,
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                children: [
                  _IntroPage(textSecondary: textSecondary),
                  _AnalyticsPage(textSecondary: textSecondary),
                  _FocusPage(textSecondary: textSecondary),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => _Dot(active: i == _index),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _nextOrFinish,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _index == 2 ? 'Get Started' : 'Next',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.index,
    required this.onBack,
    required this.onSkip,
  });

  final int index;
  final VoidCallback? onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A227F);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: index == 0
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
          ),
          Expanded(
            child: Text(
              index == 0 ? 'UPSC Prep' : 'UPSC Preparation',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 48,
            child: TextButton(
              onPressed: onSkip,
              child: const Text(
                'Skip',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.textSecondary});

  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A227F).withValues(alpha: 0.1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.shield,
                  size: 220,
                  color: const Color(0xFF1A227F).withValues(alpha: 0.15),
                ),
                const Icon(Icons.menu_book, size: 110, color: Color(0xFF1A227F)),
                const Positioned(
                  right: 40,
                  bottom: 70,
                  child: Icon(
                    Icons.verified_user,
                    size: 50,
                    color: Color(0xFF1A227F),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'All-in-One Prep',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Access daily current affairs, PYQs, and mains answer writing topics in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: textSecondary),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _AnalyticsPage extends StatelessWidget {
  const _AnalyticsPage({required this.textSecondary});

  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(top: 16, bottom: 26),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'OVERALL ACCURACY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '78%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A227F),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up, size: 16, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            '12%',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const SizedBox(
                  height: 130,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Bar(label: 'Polity', height: 0.7),
                      _Bar(label: 'History', height: 0.55),
                      _Bar(label: 'Geo', height: 0.9, isHighlight: true),
                      _Bar(label: 'Econ', height: 0.4),
                      _Bar(label: 'Env', height: 0.65),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: _InfoBox(title: 'Strongest', value: 'Geography')),
                    SizedBox(width: 12),
                    Expanded(child: _InfoBox(title: 'Focus Area', value: 'Economics')),
                  ],
                ),
              ],
            ),
          ),
          const Text(
            'Track Your Growth',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Get deep insights into your strengths and weaknesses with subject-wise analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FocusPage extends StatelessWidget {
  const _FocusPage({required this.textSecondary});

  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 260,
          height: 260,
          margin: const EdgeInsets.only(bottom: 30),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A227F).withValues(alpha: isDark ? 0.15 : 0.08),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1A227F).withValues(alpha: 0.3),
                    width: 4,
                  ),
                ),
              ),
              const Icon(
                Icons.hourglass_empty,
                size: 80,
                color: Color(0xFF1A227F),
              ),
              const Positioned(
                top: 40,
                right: 50,
                child: Icon(Icons.auto_awesome, size: 28, color: Color(0xFF1A227F)),
              ),
              const Positioned(
                bottom: 60,
                left: 50,
                child: Icon(Icons.timer, size: 40, color: Color(0xFF1A227F)),
              ),
            ],
          ),
        ),
        const Text(
          'Deep Work Mode',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Build discipline and stay distraction-free with our integrated Focus Mode timer.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1A227F) : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.height, this.isHighlight = false});

  final String label;
  final double height;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 110 * height,
            decoration: BoxDecoration(
              color: isHighlight
                  ? const Color(0xFF1A227F)
                  : const Color(0xFF1A227F).withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? const Color(0xFF1A227F) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF6F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
