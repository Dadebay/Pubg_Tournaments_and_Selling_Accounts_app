import 'package:flutter/material.dart';
import 'package:game_app/views/cards/empty_users_card.dart';
import 'package:game_app/views/cards/team_user_card.dart';
import 'package:game_app/views/constants/index.dart';
import '../../models/tournament_model.dart';

class CardTeamsAll extends StatefulWidget {
  final Teams teams;
  final int selectedTeam;
  final Function(int id) selectTeam;
  final int usersCount;

  const CardTeamsAll({
    required this.teams,
    required this.selectedTeam,
    required this.selectTeam,
    required this.usersCount,
    super.key,
  });

  @override
  State<CardTeamsAll> createState() => _CardTeamsAllState();
}

class _CardTeamsAllState extends State<CardTeamsAll> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.selectedTeam == widget.teams.id;
    final int filledSlots = widget.teams.teamUsers?.length ?? 0;
    final int totalSlots = widget.usersCount;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: () {
          widget.selectTeam(widget.teams.id!);
          HapticFeedback.lightImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade400,
                      Colors.orange.shade600,
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.shade800,
                      Colors.grey.shade900,
                    ],
                  ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.orange.withOpacity(0.4)
                    : Colors.black.withOpacity(0.3),
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 5),
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
            border: Border.all(
              color: isSelected
                  ? Colors.orange.shade300.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                // Background pattern
                if (isSelected)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DotPatternPainter(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                
                // Main content
                Column(
                  children: [
                    // Header with team number and stats
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.black.withOpacity(0.2)
                            : Colors.black.withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(23),
                          topRight: Radius.circular(23),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Team icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.groups,
                              color: isSelected ? Colors.white : Colors.grey.shade400,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Team label
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'TEAM ',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.grey.shade400,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Text(
                                      '#${widget.teams.number}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Player count
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 14,
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$filledSlots/$totalSlots Players',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.grey.shade500,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: filledSlots == totalSlots
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: filledSlots == totalSlots
                                    ? Colors.green
                                    : Colors.orange,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  filledSlots == totalSlots
                                      ? Icons.check_circle
                                      : Icons.hourglass_empty,
                                  size: 14,
                                  color: filledSlots == totalSlots
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  filledSlots == totalSlots ? 'FULL' : 'OPEN',
                                  style: TextStyle(
                                    color: filledSlots == totalSlots
                                        ? Colors.green
                                        : Colors.orange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Team members list
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          for (var i = 0; i < totalSlots; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i < totalSlots - 1 ? 5 : 0,
                              ),
                              child: widget.teams.teamUsers != null &&
                                      widget.teams.teamUsers!.length >= i + 1
                                  ? TeamUserCard(
                                      teamUsers: widget.teams.teamUsers![i],
                                    )
                                  : const EmptyUsersCard(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Selected indicator badge
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.orange.shade600,
                        size: 16,
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

// Custom painter for background pattern
class DotPatternPainter extends CustomPainter {
  final Color color;

  DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}