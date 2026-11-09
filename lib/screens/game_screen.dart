
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/realm_widgets.dart';
import '../core/save_system.dart';
import '../providers/game_state.dart';
import '../game/graphics/pixel_art_data.dart';
import '../game/graphics/pixel_sprite_painter.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          game.isGameOver
              ? 'ARENA · RESULTADO'
              : 'ARENA · TURNO ${game.currentTurn}',
        ),
        actions: [
          IconButton(
            onPressed: game.resetGame,
            tooltip: 'Reiniciar partida',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: game.isGameOver
          ? _ArenaResultScreen(
              game: game,
              onRetry: game.resetGame,
              onMenu: () => Navigator.of(context).pop(),
            )
          : RealmBackground(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final wide = box.maxWidth > box.maxHeight * 1.3;
                    final board = _board(game);
                    final controls = _controls(game);

                    return wide
                        ? Row(
                            children: [
                              Expanded(child: board),
                              SizedBox(
                                width: 250,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: controls,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(child: board),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16, 8, 16, 16,
                                ),
                                child: controls,
                              ),
                            ],
                          );
                  },
                ),
              ),
            ),
    );
  }

  Widget _board(GameState game) => LayoutBuilder(
        builder: (context, box) {
          final side = math.min(box.maxWidth, box.maxHeight) - 24;

          return Center(
            child: SizedBox(
              width: side,
              height: side,
              child: GestureDetector(
                onPanEnd: (details) {
                  final v = details.velocity.pixelsPerSecond;

                  if (v.dx.abs() > v.dy.abs()) {
                    if (v.dx.abs() > 80) {
                      game.moveInDirection(v.dx > 0 ? 1 : -1, 0);
                    }
                  } else if (v.dy.abs() > 80) {
                    game.moveInDirection(0, v.dy > 0 ? 1 : -1);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF222720),
                    border: Border.all(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: 64,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemBuilder: (context, index) {
                      final x = index % 8;
                      final y = index ~/ 8;

                      final robot = game.robots
                          .where(
                            (r) => r.x == x && r.y == y && r.hp > 0,
                          )
                          .firstOrNull;

                      final friendly =
                          robot?.id.startsWith('p') ?? false;

                      final selected = robot != null &&
                          robot.id == game.selectedRobotId;

                      final moveTarget = game.canMoveTo(x, y);
                      final attackTarget = game.canAttackAt(x, y);

                      final targetColor = moveTarget
                          ? const Color(0xFF94A480)
                          : const Color(0xFFB36B57);

                      return Semantics(
                        button: true,
                        label:
                            'Casilla ${x + 1}, ${y + 1}'
                            '${robot == null ? '' : friendly ? ', aliado' : ', enemigo'}'
                            '${moveTarget ? ', movimiento disponible' : ''}'
                            '${attackTarget ? ', objetivo de ataque' : ''}',
                        child: InkWell(
                          onTap: () => game.onCellTapped(x, y),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF625539)
                                  : moveTarget
                                      ? const Color(0xFF344638)
                                      : attackTarget
                                          ? const Color(0xFF513630)
                                          : (x + y) % 2 == 0
                                              ? const Color(0xFF363D30)
                                              : const Color(0xFF252B25),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primaryColor
                                    : moveTarget || attackTarget
                                        ? targetColor
                                        : const Color(0xFF454737),
                                width: moveTarget || attackTarget ? 2 : .7,
                              ),
                            ),
                            child: robot == null
                                ? null
                                : LayoutBuilder(
                                    builder: (context, cell) => Stack(
                                      children: [
                                        Positioned.fill(
                                          bottom: 6,
                                          child: FittedBox(
                                            child: PixelSpriteWidget(
                                              sprite: friendly
                                                  ? PixelArtLibrary.knightIdle
                                                  : PixelArtLibrary.bossTitan,
                                              pixelSize: 4,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 3,
                                          right: 3,
                                          bottom: 2,
                                          child: LinearProgressIndicator(
                                            value: (robot.hp / robot.maxHp)
                                                .clamp(0, 1),
                                            minHeight: 3,
                                            color: friendly
                                                ? const Color(0xFF94A480)
                                                : const Color(0xFFB36B57),
                                            backgroundColor: Colors.black54,
                                          ),
                                        ),
                                        if (friendly && cell.maxWidth >= 36)
                                          Positioned(
                                            top: 1,
                                            right: 2,
                                            child: Text(
                                              '${robot.actionPoints}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.accentColor,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _controls(GameState game) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'EL TABLERO DE GUERRA',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 16,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 8),
          _actionPointsPanel(game),
          const SizedBox(height: 8),
          const _BoardLegend(),
          const SizedBox(height: 8),
          Text(
            game.logs ??
                'Selecciona a tu guardián. Mueve, ataca y administra tus acciones.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _direction(
                Icons.arrow_left_rounded,
                () => game.moveInDirection(-1, 0),
              ),
              _direction(
                Icons.arrow_drop_up_rounded,
                () => game.moveInDirection(0, -1),
              ),
              _direction(
                Icons.arrow_drop_down_rounded,
                () => game.moveInDirection(0, 1),
              ),
              _direction(
                Icons.arrow_right_rounded,
                () => game.moveInDirection(1, 0),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: game.endTurn,
              icon: const Icon(Icons.skip_next),
              label: const Text('PASAR TURNO'),
            ),
          ),
        ],
      );

  Widget _actionPointsPanel(GameState game) {
    final robot = game.activePlayerRobot;
    if (robot == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .3),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: .6),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  robot.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Puntos de acción: ${robot.actionPoints}',
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: '${robot.actionPoints} puntos de acción restantes',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.bolt,
                    size: 20,
                    color: index < robot.actionPoints
                        ? AppTheme.accentColor
                        : AppTheme.muted.withValues(alpha: .35),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _direction(IconData icon, VoidCallback action) =>
      IconButton.filledTonal(
        onPressed: action,
        icon: Icon(icon, size: 26),
      );
}


class _ArenaResultScreen extends StatelessWidget {
  const _ArenaResultScreen({
    required this.game,
    required this.onRetry,
    required this.onMenu,
  });

  final GameState game;
  final VoidCallback onRetry;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final victory = game.winnerMessage.contains('VICTORIA');
        final stats = SaveSystem.data;

    final winRate = stats.arenaMatchesPlayed == 0
        ? 0
        : (stats.arenaVictories / stats.arenaMatchesPlayed * 100).round();

    final player = game.robots
        .where((robot) => robot.id.startsWith('p'))
        .firstOrNull;

    final enemy = game.robots
        .where((robot) => robot.id.startsWith('e'))
        .firstOrNull;

    final resultColor = victory
        ? const Color(0xFF94A480)
        : const Color(0xFFB36B57);

    return RealmBackground(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 600;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(compact ? 8 : 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    padding: EdgeInsets.all(compact ? 12 : 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171D19),
                      border: Border.all(
                        color: resultColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          victory
                              ? Icons.emoji_events
                              : Icons.shield_outlined,
                          color: resultColor,
                          size: compact ? 42 : 76,
                        ),
                        SizedBox(height: compact ? 6 : 16),
                        Text(
                          victory ? '¡VICTORIA!' : '¡DERROTA!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cinzel',
                            fontSize: compact ? 23 : 30,
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 10),
                        Text(
                          victory
                              ? 'Has derrotado al Titán de Asedio.'
                              : 'Tu guardián de acero ha caído.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontSize: compact ? 12 : 14,
                          ),
                        ),
                        SizedBox(height: compact ? 8 : 26),
                        const Divider(color: Colors.white24),
                        SizedBox(height: compact ? 4 : 12),
                        _resultRow(
                          Icons.flag,
                          'Turno final',
                          '${game.currentTurn}',
                          compact: compact,
                        ),
                        _resultRow(
                          Icons.favorite,
                          'Vida de tu guardián',
                          '${player?.hp ?? 0} / ${player?.maxHp ?? 100}',
                          compact: compact,
                        ),
                        _resultRow(
                          Icons.smart_toy_outlined,
                          'Vida del titán',
                          '${enemy?.hp ?? 0} / ${enemy?.maxHp ?? 100}',
                          compact: compact,
                        ),
                        SizedBox(height: compact ? 6 : 16),
                        const Divider(color: Colors.white24),
                        SizedBox(height: compact ? 4 : 10),
                        _resultRow(
                          Icons.sports_esports,
                          'Partidas jugadas',
                          '${stats.arenaMatchesPlayed}',
                          compact: compact,
                        ),
                        _resultRow(
                          Icons.emoji_events_outlined,
                          'Victorias',
                          '${stats.arenaVictories}',
                          compact: compact,
                        ),
                        _resultRow(
                          Icons.close,
                          'Derrotas',
                          '${stats.arenaDefeats}',
                          compact: compact,
                        ),
                        _resultRow(
                          Icons.percent,
                          'Porcentaje de victorias',
                          '$winRate%',
                          compact: compact,
                        ),
                        SizedBox(height: compact ? 8 : 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh),
                            label: const Text('REINICIAR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: resultColor,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(
                                vertical: compact ? 9 : 14,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 6 : 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onMenu,
                            icon: const Icon(Icons.home_outlined),
                            label: const Text('VOLVER AL MENÚ'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.accentColor,
                              padding: EdgeInsets.symmetric(
                                vertical: compact ? 9 : 14,
                              ),
                              side: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _resultRow(
    IconData icon,
    String label,
    String value, {
    required bool compact,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 3 : 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.accentColor,
            size: compact ? 17 : 20,
          ),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.muted,
                fontSize: compact ? 12 : 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}


class _BoardLegend extends StatelessWidget {
  const _BoardLegend();

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        children: const [
          _LegendItem(color: Color(0xFF94A480), label: 'Mover'),
          _LegendItem(color: Color(0xFFB36B57), label: 'Atacar'),
        ],
      );
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 11,
            ),
          ),
        ],
      );
}
