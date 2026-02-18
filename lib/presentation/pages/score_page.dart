import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';

class ScorePage extends StatelessWidget {
  const ScorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        // اگر بازی تمام شده، صفحه برنده را نشان بده
        if (state.status == GameStatus.gameFinished &&
            state.winnerTeam != null) {
          return _buildWinnerView(context, state.winnerTeam!);
        }

        return Scaffold(
          backgroundColor: Colors.indigo.shade50,
          appBar: AppBar(
            title: const Text("نتایج این دور"),
            centerTitle: true,
            automaticallyImplyLeading: false, // حذف دکمه بازگشت
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // 1. لیست کلمات بازی شده
              Expanded(
                child: state.roundHistory.isEmpty
                    ? const Center(child: Text("کلمه‌ای بازی نشد!"))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.roundHistory.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final result = state.roundHistory[index];
                          return ListTile(
                            title: Text(
                              result.word.text,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            trailing: _buildResultIcon(result.action),
                          );
                        },
                      ),
              ),

              // 2. جدول امتیازات کلی
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "جدول امتیازات",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: state.teams
                          .map(
                            (team) => Column(
                              children: [
                                Text(
                                  team.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${team.score}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // دکمه دور بعد
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // 1. آماده‌سازی برای دور بعد
                          context.read<GameBloc>().add(NextRound());
                          // 2. بستن صفحه امتیازات
                          Navigator.pop(context);
                          // 3. شروع مجدد تایمر
                          context.read<GameBloc>().add(StartGame());
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          "شروع دور بعد",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultIcon(GameActionType action) {
    switch (action) {
      case GameActionType.correct:
        return const Icon(Icons.check_circle, color: Colors.green, size: 28);
      case GameActionType.foul:
        return const Icon(Icons.cancel, color: Colors.red, size: 28);
      case GameActionType.pass:
        return const Icon(Icons.remove_circle, color: Colors.orange, size: 28);
    }
  }

  Widget _buildWinnerView(BuildContext context, Team winner) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 120, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                "برنده بازی!",
                style: TextStyle(color: Colors.white70, fontSize: 28),
              ),
              const SizedBox(height: 12),
              Text(
                winner.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // بازگشت به صفحه اول (خانه)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "خروج / بازی جدید",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
