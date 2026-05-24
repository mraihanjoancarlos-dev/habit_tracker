// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadToday();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _DashboardTab(),
          _HabitsTab(),
          StatsScreen(),
          ProfileScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? _AnimatedFAB(onTap: () => Navigator.pushNamed(context, '/add-habit').then((_) {
              context.read<HabitProvider>().loadToday();
            }))
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF13121F) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF7C6FFF).withOpacity(0.12)
                  : Colors.grey.shade100,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF7C6FFF).withOpacity(0.06)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: const Color(0xFF7C6FFF).withOpacity(isDark ? 0.18 : 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) {
            HapticFeedback.selectionClick();
            setState(() => _selectedIndex = i);
            if (i == 2) context.read<HabitProvider>().loadStats();
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined,
                  color: isDark ? const Color(0xFF6B688A) : Colors.grey.shade400),
              selectedIcon: const Icon(Icons.wb_sunny_rounded, color: Color(0xFF7C6FFF)),
              label: 'Hari ini',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined,
                  color: isDark ? const Color(0xFF6B688A) : Colors.grey.shade400),
              selectedIcon: const Icon(Icons.grid_view_rounded, color: Color(0xFF7C6FFF)),
              label: 'Habit',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_graph_outlined,
                  color: isDark ? const Color(0xFF6B688A) : Colors.grey.shade400),
              selectedIcon: const Icon(Icons.auto_graph_rounded, color: Color(0xFF7C6FFF)),
              label: 'Statistik',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded,
                  color: isDark ? const Color(0xFF6B688A) : Colors.grey.shade400),
              selectedIcon:
                  const Icon(Icons.person_rounded, color: Color(0xFF7C6FFF)),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedFAB({required this.onTap});
  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C6FFF), Color(0xFFB06AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6FFF).withOpacity(0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB HARI INI
// ─────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final hp = context.watch<HabitProvider>();
    final today = hp.today;
    final list = (today?['habits'] as List?) ?? [];
    final name =
        (auth.user?['name'] as String? ?? 'Pengguna').split(' ').first;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM', 'id_ID').format(now);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 19
                ? 'Selamat Sore'
                : 'Selamat Malam';
    final greetEmoji = hour < 12
        ? '🌤️'
        : hour < 15
            ? '☀️'
            : hour < 19
                ? '🌆'
                : '🌙';

    return SafeArea(
      child: RefreshIndicator(
        color: const Color(0xFF7C6FFF),
        backgroundColor: isDark ? const Color(0xFF1E1C32) : Colors.white,
        onRefresh: () => hp.loadToday(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  greetEmoji,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$greeting,',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? const Color(0xFF9A97B8)
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        // Avatar
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C6FFF), Color(0xFFB06AFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C6FFF).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF6B688A)
                            : Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Progress Card ──────────────────
                    _ProgressCard(hp: hp),
                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Habit Hari Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (list.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C6FFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${hp.completedToday}/${hp.totalToday} selesai',
                              style: const TextStyle(
                                  color: Color(0xFF7C6FFF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Habit List ───────────────────────────
            hp.isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF7C6FFF)),
                    ),
                  )
                : list.isEmpty
                    ? SliverFillRemaining(child: _EmptyState())
                    : SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) =>
                                _HabitCard(habit: list[i], index: i),
                            childCount: list.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final HabitProvider hp;
  const _ProgressCard({required this.hp});

  @override
  Widget build(BuildContext context) {
    final pct = hp.completionRate;
    final done = hp.completedToday;
    final total = hp.totalToday;
    final isAllDone = total > 0 && done == total;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isAllDone
              ? [const Color(0xFF0D4A35), const Color(0xFF0A3D2B)]
              : isDark
                  ? [const Color(0xFF1E1A3A), const Color(0xFF2A2050)]
                  : [const Color(0xFF7C6FFF), const Color(0xFFB06AFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? Border.all(
                color: isAllDone
                    ? const Color(0xFF38EF7D).withOpacity(0.2)
                    : const Color(0xFF7C6FFF).withOpacity(0.3),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: (isAllDone
                    ? const Color(0xFF11998e)
                    : const Color(0xFF7C6FFF))
                .withOpacity(isDark ? 0.25 : 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAllDone ? '🎉 Luar Biasa!' : '💪 Tetap Semangat!',
                    style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.6)
                            : Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$done',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        TextSpan(
                          text: ' / $total',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'habit selesai hari ini',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 13),
                  ),
                ],
              ),
              // Circle progress
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        color: isAllDone
                            ? const Color(0xFF38EF7D)
                            : Colors.white,
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${(pct * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.15),
              color: isAllDone ? const Color(0xFF38EF7D) : Colors.white,
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF7C6FFF).withOpacity(0.12)
                  : const Color(0xFF7C6FFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF7C6FFF).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(Icons.rocket_launch_outlined,
                size: 48, color: Color(0xFF7C6FFF)),
          ),
          const SizedBox(height: 20),
          Text(
            'Mulai perjalananmu!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan habit pertamamu\ndan mulai membangun kebiasaan baik.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF6B688A)
                  : Colors.grey.shade500,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add-habit'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah Habit'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HABIT CARD
// ─────────────────────────────────────────────
class _HabitCard extends StatefulWidget {
  final Map habit;
  final int index;
  const _HabitCard({required this.habit, required this.index});
  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color {
    try {
      return Color(int.parse(
          (widget.habit['color'] as String).replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF7C6FFF);
    }
  }

  IconData _getIcon(String? iconName) {
    const icons = {
      'water_drop': Icons.water_drop_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'menu_book': Icons.menu_book_rounded,
      'self_improvement': Icons.self_improvement_rounded,
      'code': Icons.code_rounded,
      'music_note': Icons.music_note_rounded,
      'restaurant': Icons.restaurant_rounded,
      'bedtime': Icons.bedtime_rounded,
      'directions_run': Icons.directions_run_rounded,
      'star': Icons.star_rounded,
    };
    return icons[iconName] ?? Icons.star_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDone =
        widget.habit['is_completed'] == 1 || widget.habit['is_completed'] == true;
    final streak = widget.habit['streak'] ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onLongPress: () => _showOptions(context),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDone
                ? _color.withOpacity(isDark ? 0.12 : 0.06)
                : (isDark ? const Color(0xFF1E1C32) : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDone
                  ? _color.withOpacity(0.35)
                  : (isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.grey.shade100),
              width: 1,
            ),
            boxShadow: isDone
                ? []
                : [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(isDark ? 0.25 : 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: _color.withOpacity(0.08),
              highlightColor: _color.withOpacity(0.04),
              onTap: () {
                HapticFeedback.lightImpact();
                context
                    .read<HabitProvider>()
                    .toggle(widget.habit['id'] as int);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Icon circle
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDone
                            ? _color
                            : _color.withOpacity(isDark ? 0.18 : 0.1),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isDone
                            ? [
                                BoxShadow(
                                  color: _color.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 22)
                          : Icon(
                              _getIcon(widget.habit['icon'] as String?),
                              color: _color,
                              size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.habit['name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: -0.2,
                              decoration: isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor:
                                  isDark ? Colors.white38 : Colors.grey,
                              color: isDone
                                  ? (isDark
                                      ? Colors.white30
                                      : Colors.grey.shade400)
                                  : (isDark
                                      ? Colors.white
                                      : Colors.black87),
                            ),
                          ),
                          if (widget.habit['description'] != null &&
                              widget.habit['description']
                                  .toString()
                                  .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                widget.habit['description'],
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF6B688A)
                                      : Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Streak badge
                    if (streak > 0) _StreakBadge(streak: streak),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1C32) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              widget.habit['name'] ?? '',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _OptionTile(
              icon: Icons.edit_rounded,
              color: const Color(0xFF7C6FFF),
              label: 'Edit habit',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-habit',
                    arguments: widget.habit);
              },
            ),
            const SizedBox(height: 10),
            _OptionTile(
              icon: Icons.delete_rounded,
              color: const Color(0xFFFF6B6B),
              label: 'Hapus habit',
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1C32) : Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Text('Hapus habit?',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        content: Text(
          'Hapus "${widget.habit['name']}"? Tindakan ini tidak bisa dibatalkan.',
          style: TextStyle(
              color: isDark ? const Color(0xFF9A97B8) : Colors.grey.shade600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9A97B8)
                        : Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<HabitProvider>()
                  .deleteHabit(widget.habit['id'] as int);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  String get _flameEmoji {
    if (streak >= 30) return '🔥💎';
    if (streak >= 14) return '🔥⚡';
    if (streak >= 7) return '🔥✨';
    return '🔥';
  }

  Color get _badgeColor {
    if (streak >= 30) return const Color(0xFF00B4D8);
    if (streak >= 14) return const Color(0xFFFF6B35);
    if (streak >= 7) return const Color(0xFFFF9A3C);
    return const Color(0xFFFFB347);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: _badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_flameEmoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 3),
          Text(
            '$streak',
            style: TextStyle(
              color: _badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB KELOLA HABIT
// ─────────────────────────────────────────────
class _HabitsTab extends StatelessWidget {
  const _HabitsTab();

  @override
  Widget build(BuildContext context) {
    final hp = context.watch<HabitProvider>();
    final list = (hp.today?['habits'] as List?) ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0E1A) : const Color(0xFFF6F5FF),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0F0E1A) : const Color(0xFFF6F5FF),
        elevation: 0,
        title: Text(
          'Semua Habit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C6FFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF7C6FFF).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${list.length} habit',
                  style: const TextStyle(
                      color: Color(0xFF7C6FFF),
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: list.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📋',
                      style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada habit',
                    style: TextStyle(
                        color: isDark
                            ? const Color(0xFF6B688A)
                            : Colors.grey.shade500,
                        fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (ctx, i) =>
                  _HabitCard(habit: list[i], index: i),
            ),
    );
  }
}