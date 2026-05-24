// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HabitProvider>().loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final hp     = context.watch<HabitProvider>();
    final stats  = hp.stats;
    final habits = (stats?['habits'] as List?) ?? [];
    final weekly = (stats?['weekly'] as List?) ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Compute summary numbers
    final totalDays     = weekly.length;
    final activeDays    = weekly.where((d) {
      final done = int.tryParse(d['completed'].toString()) ?? 0;
      return done > 0;
    }).length;
    final perfectDays   = weekly.where((d) {
      final total = (d['total'] as int?) ?? 0;
      final done  = int.tryParse(d['completed'].toString()) ?? 0;
      return total > 0 && done == total;
    }).length;
    final bestStreak    = habits.isNotEmpty
        ? (habits.map((h) => (h['streak'] as int?) ?? 0).reduce((a, b) => a > b ? a : b))
        : 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0E1A) : const Color(0xFFF6F5FF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F0E1A) : const Color(0xFFF6F5FF),
        elevation: 0,
        title: Text(
          'Statistik',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF7C6FFF),
        backgroundColor: isDark ? const Color(0xFF1E1C32) : Colors.white,
        onRefresh: () => hp.loadStats(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          physics: const BouncingScrollPhysics(),
          children: [

            // ── Summary Cards Row ────────────────────
            Row(
              children: [
                Expanded(child: _SummaryCard(
                  emoji: '📅',
                  value: '$activeDays',
                  label: 'Hari Aktif',
                  color: const Color(0xFF7C6FFF),
                  isDark: isDark,
                )),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(
                  emoji: '🎯',
                  value: '$perfectDays',
                  label: 'Hari Sempurna',
                  color: const Color(0xFF38EF7D),
                  isDark: isDark,
                )),
                const SizedBox(width: 12),
                Expanded(child: _SummaryCard(
                  emoji: '🔥',
                  value: '$bestStreak',
                  label: 'Streak Terbaik',
                  color: const Color(0xFFFF9A3C),
                  isDark: isDark,
                )),
              ],
            ),

            const SizedBox(height: 20),

            // ── Weekly Chart ─────────────────────────
            _SectionTitle(title: 'Minggu Ini', isDark: isDark),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1C32) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.grey.shade100,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: weekly.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Belum ada data minggu ini',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF6B688A)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekly.take(7).map((day) {
                        final total = (day['total'] as int?) ?? 0;
                        final done  = int.tryParse(
                                day['completed'].toString()) ??
                            0;
                        final pct   = total > 0 ? done / total : 0.0;
                        final date  = day['date'] as String? ?? '';
                        final isToday = date ==
                            DateTime.now()
                                .toIso8601String()
                                .substring(0, 10);
                        final dayName = date.isNotEmpty
                            ? [
                                'Sen','Sel','Rab','Kam','Jum','Sab','Min'
                              ][DateTime.tryParse(date)?.weekday != null
                                  ? (DateTime.parse(date).weekday - 1)
                                  : 0]
                            : '';

                        final barColor = pct == 1.0
                            ? const Color(0xFF38EF7D)
                            : pct > 0.5
                                ? const Color(0xFF7C6FFF)
                                : pct > 0
                                    ? const Color(0xFFB06AFF).withOpacity(0.7)
                                    : Colors.transparent;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (pct > 0)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '${(pct * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF9A97B8)
                                        : Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            Container(
                              width: 32,
                              height: 80,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                width: 32,
                                height: 80 * pct,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: pct > 0
                                      ? [
                                          BoxShadow(
                                            color: barColor
                                                .withOpacity(0.35),
                                            blurRadius: 8,
                                            offset:
                                                const Offset(0, 4),
                                            spreadRadius: -2,
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 3),
                              decoration: isToday
                                  ? BoxDecoration(
                                      color: const Color(0xFF7C6FFF)
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    )
                                  : null,
                              child: Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isToday
                                      ? const Color(0xFF7C6FFF)
                                      : (isDark
                                          ? const Color(0xFF6B688A)
                                          : Colors.grey.shade500),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 24),

            // ── Per Habit ────────────────────────────
            _SectionTitle(title: 'Per Habit', isDark: isDark),
            const SizedBox(height: 12),
            ...habits.map((h) => _HabitStatCard(habit: h, isDark: isDark)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;
  final bool isDark;
  const _SummaryCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C32) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isDark
                  ? const Color(0xFF9A97B8)
                  : Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitStatCard extends StatelessWidget {
  final Map habit;
  final bool isDark;
  const _HabitStatCard({required this.habit, required this.isDark});

  Color get _color {
    try {
      return Color(int.parse(
          (habit['color'] as String).replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF7C6FFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct    = double.tryParse(
            habit['completion_pct']?.toString() ?? '0') ??
        0.0;
    final streak = (habit['streak'] as int?) ?? 0;

    String streakEmoji = '';
    Color streakColor  = const Color(0xFFFFB347);
    if (streak >= 30) { streakEmoji = '🔥💎'; streakColor = const Color(0xFF00B4D8); }
    else if (streak >= 14) { streakEmoji = '🔥⚡'; streakColor = const Color(0xFFFF6B35); }
    else if (streak >= 7)  { streakEmoji = '🔥✨'; streakColor = const Color(0xFFFF9A3C); }
    else if (streak > 0)   { streakEmoji = '🔥';  streakColor = const Color(0xFFFFB347); }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C32) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _color.withOpacity(isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.star_rounded, color: _color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  habit['name'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: streakColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: streakColor.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(streakEmoji,
                          style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 3),
                      Text(
                        '$streak hari',
                        style: TextStyle(
                          color: streakColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    backgroundColor: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade100,
                    color: _color,
                    minHeight: 7,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: _color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${habit['total_completed'] ?? 0} dari ${habit['total_logs'] ?? 0} hari (30 hari terakhir)',
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF6B688A)
                  : Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}