import 'dart:async'; 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../widgets/animated_widgets.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with SingleTickerProviderStateMixin {
      
  String get _botToken {
    const part1 = "MjgxODM1MDpmMGRaSkdR";
    const part2 = "WWNUWk9FNTV2V29vX04yZVUwSWdsVmh5b25RVQ==";
    return utf8.decode(base64.decode(part1 + part2));
  }
  
  final String _chatId = "726989697";

  late TabController _tabController;
  final _wordController = TextEditingController();
  final _commentController = TextEditingController();

  final List<String> _categories = [
    "اشیاء",
    "مکان‌ها",
    "حیوانات",
    "ویژگی‌ها",
    "خوراکی",
    "تکنولوژی",
    "ورزش",
    "ضرب‌المثل",
    "مشاهیر",
    "فیلم و سریال",
    "دنیای فوتبال",
    "عمومی / دیگر"
  ];

  String _selectedCategory = "اشیاء";
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wordController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitData({required bool isWordSuggestion}) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showErrorDialog(
          "خطای اتصال", "لطفاً اینترنتت رو چک کن و دوباره امتحان کن.");
      return;
    }

    if (isWordSuggestion && _wordController.text.trim().isEmpty) {
      _showErrorDialog("کلمه خالی است", "لطفاً یک کلمه بنویسید.");
      return;
    }
    if (!isWordSuggestion && _commentController.text.trim().isEmpty) {
      _showErrorDialog("متن خالی است", "لطفاً نظر خود را بنویسید.");
      return;
    }

    setState(() => _isSending = true);

    String message = "";
    if (isWordSuggestion) {
      message = """
💡 *پیشنهاد کلمه جدید*
---------------------------
📂 *دسته:* $_selectedCategory
📝 *کلمه:* ${_wordController.text.trim()}
---------------------------
#کلمه_جدید #${_selectedCategory.replaceAll(' ', '_')}
""";
    } else {
      message = """
💌 *نظر یا انتقاد جدید*
---------------------------
💬 *متن پیام:*
${_commentController.text.trim()}
---------------------------
#نظر #فیدبک
""";
    }

    try {
      final url = Uri.parse("https://tapi.bale.ai/bot$_botToken/sendMessage");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "chat_id": _chatId,
          "text": message,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSuccessDialog(isWordSuggestion);
        if (isWordSuggestion) {
          _wordController.clear();
        } else {
          _commentController.clear();
        }
      } else {
        _showErrorDialog(
            "خطای سرور", "مشکلی در ارسال پیش اومد. کد: ${response.statusCode}");
      }
    } on TimeoutException {
      _showErrorDialog("خطای اینترنت", "ارتباط خیلی طول کشید! اینترنت شما ضعیفه.");
    } catch (e) {
      _showErrorDialog("خطای ارسال", "ارسال نشد. لطفاً بعداً تلاش کنید.");
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(fontFamily: 'Hasti', color: Colors.red)),
        content: Text(content, style: const TextStyle(fontFamily: 'Peyda')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("باشه"))
        ],
      ),
    );
  }

  void _showSuccessDialog(bool isWord) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("دریافت شد! 🎉",
            style: TextStyle(fontFamily: 'Hasti', color: Colors.green)),
        content: Text(
            isWord
                ? "ممنون! کلمه پیشنهادیتو بررسی و اضافه میکنیم. دمت گرم❤️."
                : "ممنون از نظر شما. حتماً می‌خوانیم!",
            style: const TextStyle(fontFamily: 'Peyda')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("باشه"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FantasyBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 5)
                            ]),
                        child: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 20),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "ارسال بازخورد",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Hasti'),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(
                      fontFamily: 'Hasti',
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "پیشنهاد کلمه"),
                    Tab(text: "ارسال نظر"),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildWordSuggestionTab(),
                    _buildCommentTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordSuggestionTab() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("دسته بندی کلمه:",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Peyda')),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                items: _categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(fontFamily: 'Peyda')),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedCategory = newValue!),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text("کلمه پیشنهادی:",
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Peyda')),
          const SizedBox(height: 8),
          TextField(
            controller: _wordController,
            decoration: InputDecoration(
              hintText: "مثلاً: قورمه سبزی",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
            style: const TextStyle(fontFamily: 'Peyda'),
          ),
          const SizedBox(height: 10),
          const Text("با ارسال کلمه، به کامل‌تر شدن بازی کمک می‌کنید.",
              style: TextStyle(
                  fontSize: 12, color: Colors.grey, fontFamily: 'Peyda')),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: _isSending
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                : ToonButton(
                    title: "ارسال کلمه",
                    color: const Color(0xFF6C63FF),
                    isLarge: true,
                    onPressed: () => _submitData(isWordSuggestion: true),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTab() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("هر چه میخواهد دل تنگت بگو:",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Peyda',
                  fontSize: 16)),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "نظر، انتقاد، یا گزارش باگ...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              style: const TextStyle(fontFamily: 'Peyda'),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: _isSending
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6584)))
                : ToonButton(
                    title: "ارسال نظر",
                    color: const Color(0xFFFF6584),
                    isLarge: true,
                    onPressed: () => _submitData(isWordSuggestion: false),
                  ),
          ),
        ],
      ),
    );
  }
}
