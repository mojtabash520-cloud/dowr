import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/word.dart';
import '../../domain/entities/game_settings.dart';
import '../bloc/game_bloc.dart';
import '../../core/utils/sound_manager.dart';
import '../../core/utils/ad_manager.dart';
import '../../core/utils/monetization_manager.dart';
import '../widgets/animated_widgets.dart';
import 'dart:async';

class GamePage extends StatelessWidget {
  final List<Word> gameWords;
  final GameSettings settings;
  const GamePage({super.key, required this.gameWords, required this.settings});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(words: gameWords, settings: settings)..add(StartGame()),
      child: GameView(settings: settings),
    );
  }
}

class GameView extends StatefulWidget {
  final GameSettings settings;
  const GameView({super.key, required this.settings});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with TickerProviderStateMixin {
  final SoundManager _sounds = SoundManager();
  Timer? _tickDebounce;
  Timer? _readyTickTimer; // ✅ تایمر مخصوص تیک‌تاک در صفحه آماده‌باش
  
  bool _isReadyPhase = true; 
  Color _flashColor = Colors.transparent; 

  @override
  void initState() {
    super.initState();
    _sounds.startMusic();
    
    // ✅ پخش صدای تیک‌تاک استرس‌زا در پس‌زمینه تا زمانی که دکمه آماده‌ایم را بزنند
    _readyTickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isReadyPhase && mounted) {
        _sounds.playTick();
      }
    });
  }

  @override
  void dispose() {
    _tickDebounce?.cancel();
    _readyTickTimer?.cancel(); // ✅ خاموش کردن تایمر آماده‌باش
    super.dispose();
  }

  void _toggleMute() {
    _sounds.toggleMute();
    setState(() {});
  }

  TextStyle get _numberFont => const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold);

  String _toFarsi(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }
    return input;
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showFlash(Color color) {
    setState(() => _flashColor = color);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _flashColor = Colors.transparent);
    });
  }

  void _handleWordTap(BuildContext context) {
    _showFlash(Colors.green.withOpacity(0.4)); 
    _sounds.playCorrect();
    context.read<GameBloc>().add(const UserAction(GameActionType.correct));
  }
  
  void _handleSkip(BuildContext context) {
    _showFlash(Colors.orange.withOpacity(0.4)); 
    _sounds.playPass();
    context.read<GameBloc>().add(const UserAction(GameActionType.pass));
  }

  void _handleFoul(BuildContext context) {
    _showFlash(Colors.red.withOpacity(0.4)); 
    _sounds.playFoul();
    context.read<GameBloc>().add(const UserAction(GameActionType.foul));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Stack(
        children: [
          Scaffold(
            body: FantasyBackground(
              child: SafeArea(
                child: BlocConsumer<GameBloc, GameState>(
                  listener: (context, state) async {
                    if (state.status == GameStatus.gameFinished) {
                      _sounds.playGameOver(); 
                      _showLeaderboardDialog(context, state.ranking);
                    }
                    if (state.status == GameStatus.teamEliminated) {
                      _sounds.stopMusic();
                      _sounds.playFoul();
                      _showTurnFinishedDialog(context, state, isElimination: true);
                    }
                    if (state.status == GameStatus.turnFinished) {
                       _sounds.playCorrect();
                       bool isPrem = await MonetizationManager.isPremium();
                       if (!isPrem) await AdManager.checkAndShowInterstitial();
                       if (mounted) _showTurnFinishedDialog(context, state, isElimination: false);
                    }
      
                    // ✅ برگشتن ۲۰ ثانیه حیاتی آخر با صدای تیک!
                    if (state.status == GameStatus.playing && !_isReadyPhase) {
                       int timeToShow = widget.settings.mode == GameMode.rounds ? state.roundRemainingTime : state.teams[state.currentTeamIndex].remainingTime;
                       if (timeToShow > 0 && timeToShow <= 20) { // تنظیم شد روی ۲۰ ثانیه
                         if (_tickDebounce?.isActive ?? false) return;
                         _sounds.playTick();
                         _tickDebounce = Timer(const Duration(milliseconds: 900), () {});
                       }
                    }
                  },
                  listenWhen: (prev, curr) {
                    // فقط زمانی صفحه را آپدیت کن که واقعا تغییری رخ داده باشد
                    return prev.status != curr.status || 
                           prev.roundRemainingTime != curr.roundRemainingTime || 
                           prev.teams != curr.teams ||
                           prev.currentWord != curr.currentWord;
                  },
                  builder: (context, state) {
                    if (state.teams.isEmpty) return const SizedBox();
                    final activeTeam = state.teams[state.currentTeamIndex];
                    int mainTimerValue = widget.settings.mode == GameMode.rounds ? state.roundRemainingTime : activeTeam.remainingTime;
      
                    return Column(
                      children: [
                        _buildScoreboardHeader(context, state),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                            decoration: BoxDecoration(color: mainTimerValue <= 10 ? Colors.red.shade100 : Colors.white54, borderRadius: BorderRadius.circular(20)),
                            child: Text(_toFarsi(_formatTime(mainTimerValue)), style: _numberFont.copyWith(fontSize: 32, color: mainTimerValue <= 10 ? Colors.red : Colors.indigo)),
                          ),
                        ),
      
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start, 
                                      children: [
                                        const SizedBox(height: 10),
                                        const Text("نوبت تیم:", style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Peyda')),
                                        Text(activeTeam.name, style: TextStyle(color: activeTeam.color, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'Peyda'), textAlign: TextAlign.center),
                                        const SizedBox(height: 15),
                                        
                                        GestureDetector(
                                          onTap: _isReadyPhase ? null : () => _handleWordTap(context),
                                          child: GameCard(
                                            child: Column(
                                              children: [
                                                const Text("🔥 کلمه هدف 🔥", style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Peyda')),
                                                const SizedBox(height: 8),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  // ✅ انیمیشن بسیار نرم‌تر و زیباتر برای کلمات
                                                  child: AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 350),
                                                    transitionBuilder: (child, anim) {
                                                      return FadeTransition(
                                                        opacity: anim,
                                                        child: ScaleTransition(
                                                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                                            CurvedAnimation(parent: anim, curve: Curves.easeOutBack)
                                                          ),
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      _isReadyPhase ? "؟ ؟ ؟" : (state.currentWord?.text ?? "..."), 
                                                      key: ValueKey(_isReadyPhase ? "hidden" : state.currentWord?.text), 
                                                      textAlign: TextAlign.center, 
                                                      style: const TextStyle(fontFamily: 'Hasti', fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D), height: 1.2)
                                                    ),
                                                  ),
                                                ),
                                                if (!_isReadyPhase && (state.currentWord?.forbidden.isNotEmpty ?? false)) ...[
                                                  const SizedBox(height: 15),
                                                  const Divider(),
                                                  Wrap(spacing: 6, runSpacing: 6, alignment: WrapAlignment.center, children: state.currentWord!.forbidden.map((f) => Chip(label: Text(f, style: const TextStyle(fontSize: 14, fontFamily: 'Peyda')), padding: EdgeInsets.zero, backgroundColor: Colors.red.shade50, labelStyle: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontFamily: 'Peyda'), side: BorderSide.none)).toList())
                                                ],
                                                const SizedBox(height: 25),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF00C853).withOpacity(0.5), width: 1.5)),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: const [
                                                      Icon(Icons.touch_app_rounded, color: Color(0xFF00C853), size: 20),
                                                      SizedBox(width: 8),
                                                      Text("برای پاسخ درست ضربه بزنید", style: TextStyle(fontFamily: 'Peyda', color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 13)),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
      
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 5, 16, 40),
                          child: SizedBox(
                            height: 70, 
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: ToonButton(title: "رد (تعویض)", icon: Icons.fast_forward_rounded, color: const Color(0xFFFFC045), onPressed: _isReadyPhase ? () {} : () => _handleSkip(context))),
                                const SizedBox(width: 16),
                                Expanded(child: ToonButton(title: "خطا", icon: Icons.close_rounded, color: const Color(0xFFFF6584), onPressed: _isReadyPhase ? () {} : () => _handleFoul(context))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),

          IgnorePointer(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              color: _flashColor,
            ),
          ),

          // ✅ این صفحه فقط یک بار در ابتدای بازی می‌آید!
          if (_isReadyPhase)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: BlocBuilder<GameBloc, GameState>(
                    builder: (context, state) {
                      if (state.teams.isEmpty) return const SizedBox();
                      final activeTeam = state.teams[state.currentTeamIndex];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("نوبت تیم", style: TextStyle(fontFamily: 'Peyda', fontSize: 24, color: Colors.white70)),
                          const SizedBox(height: 10),
                          Text(activeTeam.name, style: TextStyle(fontFamily: 'Hasti', fontSize: 50, color: activeTeam.color, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 60),
                          SizedBox(
                            width: 220, height: 75,
                            child: ToonButton(
                              title: "آماده‌ایم!",
                              icon: Icons.play_arrow_rounded,
                              color: const Color(0xFF00C853),
                              isLarge: true,
                              onPressed: () {
                                _readyTickTimer?.cancel(); // قطع کردن صدای تیک
                                _sounds.playCorrect(); 
                                setState(() => _isReadyPhase = false); 
                                context.read<GameBloc>().add(const ResumeTurn()); 
                              }
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreboardHeader(BuildContext context, GameState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(onTap: () => _showExitDialog(context), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.close_rounded, color: Colors.red, size: 20))),
              Column(children: [const Text("جنگ واژگان", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Hasti')), if (widget.settings.mode == GameMode.rounds) Text("راند ${_toFarsi(state.currentRound.toString())}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Peyda'))]),
              GestureDetector(onTap: _toggleMute, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _sounds.isMusicMuted ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(12)), child: Icon(_sounds.isMusicMuted ? Icons.music_off_rounded : Icons.music_note_rounded, color: _sounds.isMusicMuted ? Colors.red : Colors.green, size: 20))),
          ]),
          const SizedBox(height: 8),
          Column(children: state.teams.map((team) {
              bool isActive = team == state.teams[state.currentTeamIndex];
              double progress = 0;
              String infoText = "";
              if (widget.settings.mode == GameMode.survival) {
                progress = team.remainingTime / (team.totalTime > 0 ? team.totalTime : 1);
                infoText = _toFarsi(_formatTime(team.remainingTime));
              } else {
                progress = 1.0; infoText = "${_toFarsi(team.score.toString())} امتیاز";
              }
              if (team.isEliminated) {
                return Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.close, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(team.name, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12, fontFamily: 'Peyda')), const Spacer(), const Text("حذف شد", style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Peyda'))]));
              }
              return AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.only(bottom: 4), padding: EdgeInsets.symmetric(horizontal: 8, vertical: isActive ? 6 : 4), decoration: BoxDecoration(color: isActive ? Colors.white : Colors.white.withOpacity(0.5), border: isActive ? Border.all(color: team.color, width: 1.5) : Border.all(color: Colors.transparent), borderRadius: BorderRadius.circular(8), boxShadow: isActive ? [BoxShadow(color: team.color.withOpacity(0.2), blurRadius: 4)] : []), child: Row(children: [Icon(isActive ? Icons.play_arrow_rounded : Icons.circle, color: team.color, size: isActive ? 16 : 10), const SizedBox(width: 6), SizedBox(width: 60, child: Text(team.name, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12, fontFamily: 'Peyda'), overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), if (widget.settings.mode == GameMode.survival) Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(team.color), minHeight: 6))) else const Spacer(), const SizedBox(width: 8), Text(infoText, style: _numberFont.copyWith(fontSize: 13, color: Colors.black87))]));
          }).toList())
      ]),
    );
  }

  void _showTurnFinishedDialog(BuildContext context, GameState state, {required bool isElimination}) {
    final currentTeam = state.teams[state.currentTeamIndex];
    int nextIndex = (state.currentTeamIndex + 1) % state.teams.length;
    if (isElimination) {
       int loopSafety = 0;
       while(state.teams[nextIndex].isEliminated && loopSafety < state.teams.length) { nextIndex = (nextIndex + 1) % state.teams.length; loopSafety++; }
    }
    final nextTeam = state.teams[nextIndex];
    
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
        title: Text(
          isElimination ? "😱 تیم حذف شد!" : "⏰ پایان نوبت", 
          textAlign: TextAlign.center, 
          style: TextStyle(fontFamily: 'Peyda', fontSize: 22, color: isElimination ? Colors.red : currentTeam.color, fontWeight: FontWeight.w900)
        ), 
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            if (widget.settings.mode == GameMode.rounds) ...[
              const Text("امتیاز فعلی:", style: TextStyle(fontFamily: 'Peyda', fontSize: 16, color: Colors.black54)), 
              Text(_toFarsi("${currentTeam.score}"), style: _numberFont.copyWith(fontSize: 40, color: Colors.black))
            ], 
            const Divider(), 
            const SizedBox(height: 10), 
            const Text("نوبت تیم بعدی:", style: TextStyle(fontFamily: 'Peyda', fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
            Text(nextTeam.name, style: TextStyle(fontFamily: 'Peyda', fontSize: 24, fontWeight: FontWeight.w900, color: nextTeam.color))
          ]
        ), 
        actions: [
          SizedBox(
            width: double.infinity, 
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: nextTeam.color, padding: const EdgeInsets.symmetric(vertical: 12)),
              onPressed: () { 
                _sounds.startMusic(); 
                Navigator.pop(context); 
                // ✅ بستن دیالوگ و استارت بلافاصله‌ی تیم بعدی (بدون توقف)
                context.read<GameBloc>().add(DismissElimination());
              },
              child: const Text("شروع نوبت بعد", style: TextStyle(fontFamily: 'Peyda', fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            )
          )
        ]
      )
    );
  }

  void _showLeaderboardDialog(BuildContext context, List<Team> ranking) {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent, 
        child: Container(
          padding: const EdgeInsets.all(24), 
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)), 
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              const Text("🏆 پایان بازی 🏆", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Hasti', color: Colors.black87)), 
              const SizedBox(height: 20), 
              SizedBox(
                height: 300, 
                child: ListView.builder(
                  itemCount: ranking.length, 
                  itemBuilder: (context, index) { 
                    final team = ranking[index]; 
                    Color rankColor = Colors.grey.shade100; 
                    IconData rankIcon = Icons.star_border; 
                    if (index == 0) { rankColor = const Color(0xFFFFD700); rankIcon = Icons.emoji_events; } 
                    else if (index == 1) { rankColor = const Color(0xFFC0C0C0); rankIcon = Icons.looks_two; } 
                    else if (index == 2) { rankColor = const Color(0xFFCD7F32); rankIcon = Icons.looks_3; } 
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8), 
                      padding: const EdgeInsets.all(12), 
                      decoration: BoxDecoration(color: index == 0 ? rankColor.withOpacity(0.2) : Colors.white, border: Border.all(color: index == 0 ? rankColor : Colors.grey.shade200), borderRadius: BorderRadius.circular(16)), 
                      child: Row(
                        children: [
                          Icon(rankIcon, color: index == 0 ? Colors.orange : Colors.grey), 
                          const SizedBox(width: 10), 
                          Text(_toFarsi("${index + 1}"), style: _numberFont.copyWith(fontSize: 18, color: Colors.black87)), 
                          const SizedBox(width: 10), 
                          Expanded(child: Text(team.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: team.color, fontFamily: 'Peyda'))), 
                          Text(widget.settings.mode == GameMode.rounds ? _toFarsi("${team.score} امتیاز") : (index==0 ? "برنده" : "حذف"), style: _numberFont.copyWith(fontWeight: FontWeight.bold, color: Colors.black54))
                        ]
                      )
                    ); 
                  }
                )
              ), 
              const SizedBox(height: 20), 
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                  onPressed: () {
                    _sounds.startMusic();
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }, 
                  child: const Text("بازی جدید", style: TextStyle(fontFamily: 'Peyda', color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                ),
              )
            ]
          )
        )
      )
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context, 
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), 
        title: const Text("خروج از بازی؟", style: TextStyle(fontFamily: 'Peyda', fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
        content: const Text("بازی فعلی از دست می‌رود. مطمئنی؟", style: TextStyle(fontFamily: 'Peyda', fontSize: 16, color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("لغو", style: TextStyle(fontFamily: 'Peyda', fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold))
          ), 
          ElevatedButton(
            onPressed: () {
              _sounds.startMusic();
              Navigator.of(context).popUntil((r) => r.isFirst);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6584)), 
            child: const Text("خروج", style: TextStyle(fontFamily: 'Peyda', fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))
          )
        ]
      )
    );
  }
}
