import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../widgets/animated_hero_header.dart';

class MonthlyLeaderboardScreen extends StatefulWidget {
  const MonthlyLeaderboardScreen({super.key});

  @override
  State<MonthlyLeaderboardScreen> createState() => _MonthlyLeaderboardScreenState();
}

class _MonthlyLeaderboardScreenState extends State<MonthlyLeaderboardScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final rankings = authService.getMonthlyRankings(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade700, Colors.orange.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Animated Hero Header
          AnimatedHeroHeader(
            title: 'Leaderboard',
            subtitle: 'Monthly Rankings & Achievements',
            primaryColor: Colors.amber.shade700,
            secondaryColor: Colors.orange.shade400,
            icon: Icons.emoji_events,
          ),

          // Month Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(
                        _selectedMonth.year,
                        _selectedMonth.month - 1,
                      );
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final now = DateTime.now();
                    final nextMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                    // Don't allow future months
                    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
                      setState(() {
                        _selectedMonth = nextMonth;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Leaderboard Content
          Expanded(
            child: rankings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No rankings yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete tasks to earn points!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top 3 Podium
                        if (rankings.isNotEmpty) ...[
                          _buildPodium(rankings),
                          const SizedBox(height: 32),
                        ],

                        // All Rankings List
                        Text(
                          'All Rankings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...rankings.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ranking = entry.value;
                          return _buildRankingCard(ranking, index);
                        }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> rankings) {
    final first = rankings.length > 0 ? rankings[0] : null;
    final second = rankings.length > 1 ? rankings[1] : null;
    final third = rankings.length > 2 ? rankings[2] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Top 3 Champions 🏆',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Second Place
              if (second != null)
                _buildPodiumPlace(second, 2, Colors.grey.shade400, 100)
              else
                const SizedBox(width: 80),

              // First Place
              if (first != null)
                _buildPodiumPlace(first, 1, Colors.amber.shade600, 130)
              else
                const SizedBox(width: 80),

              // Third Place
              if (third != null)
                _buildPodiumPlace(third, 3, Colors.brown.shade400, 80)
              else
                const SizedBox(width: 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    Map<String, dynamic> ranking,
    int place,
    Color color,
    double height,
  ) {
    final child = ranking['child'];
    final points = ranking['points'];
    
    String medal;
    switch (place) {
      case 1:
        medal = '🥇';
        break;
      case 2:
        medal = '🥈';
        break;
      case 3:
        medal = '🥉';
        break;
      default:
        medal = '🏅';
    }

    return Column(
      children: [
        // Medal and Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: place == 1 ? 40 : 32,
              backgroundColor: color,
              child: Text(
                child.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: place == 1 ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: Text(
                medal,
                style: TextStyle(
                  fontSize: place == 1 ? 32 : 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          child.name,
          style: TextStyle(
            fontSize: place == 1 ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        // Points
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                '$points',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Podium Base
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
            child: Text(
              '#$place',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> ranking, int index) {
    final child = ranking['child'];
    final points = ranking['points'] as int;
    final completedTasks = ranking['completedTasks'] as int;
    final rank = ranking['rank'] as int;

    Color rankColor;
    String rankEmoji;
    
    switch (rank) {
      case 1:
        rankColor = Colors.amber.shade700;
        rankEmoji = '🥇';
        break;
      case 2:
        rankColor = Colors.grey.shade600;
        rankEmoji = '🥈';
        break;
      case 3:
        rankColor = Colors.brown.shade600;
        rankEmoji = '🥉';
        break;
      default:
        rankColor = Colors.grey.shade400;
        rankEmoji = '#$rank';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: rank <= 3 ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: rank <= 3
            ? BorderSide(color: rankColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  rank <= 3 ? rankEmoji : '#$rank',
                  style: TextStyle(
                    fontSize: rank <= 3 ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: rankColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Child Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completedTasks tasks completed',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Points Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [rankColor.withOpacity(0.8), rankColor],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '$points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
