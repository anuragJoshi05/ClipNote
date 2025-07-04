// services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Fixes common encoding issues from AI output
  static String fixBrokenSymbols(String text) {
    return text
        .replaceAll(RegExp(r'â\s*\[\]\s*¢'), '•')
        .replaceAll('â€¢', '•')
        .replaceAll('â€™', "'")
        .replaceAll('â€"', '-')
        .replaceAll('â€œ', '"')
        .replaceAll('â€', '"')
        .replaceAll('Ã©', 'é')
        .replaceAll(':bulb:', '💡')
        .replaceAll(':check:', '✅')
        .replaceAll(':fire:', '🔥')
        .replaceAll(':note:', '📝')
        .replaceAll(':star:', '⭐')
        .replaceAll(':rocket:', '🚀')
    // Clean only **actual garbage** characters like �, � etc.
        .replaceAll(RegExp(r'[�]+'), '');
  }

  /// Makes API call to Gemini
  static Future<String> _makeGeminiRequest(String prompt, {double temperature = 0.3, int maxTokens = 500}) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not configured');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': temperature,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': maxTokens,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return fixBrokenSymbols(content.toString().trim());
        } else {
          throw Exception('No content generated from Gemini API');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Gemini API Error: ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your internet connection.');
      }
      rethrow;
    }
  }

  /// Summarizes a note
  static Future<String> summarizeNote({
    required String title,
    required String content,
  }) async {
    if (content.trim().isEmpty) {
      throw Exception('Note content is empty');
    }

    final prompt = '''You are a professional note summarizer. Create a concise, well-structured summary that captures the key points of the note content. Your summary should be:
- Clear and easy to understand
- Organized with numbered points (1, 2, 3...)
- Focused on the most important information
- Professional yet accessible in tone
- Limited to 3-5 main points maximum
- No emojis or special characters
- Pure English text only

Title: $title

Content: $content

Please provide a clear, numbered summary of the key points from this note.''';

    return await _makeGeminiRequest(prompt, maxTokens: 300);
  }

  /// Generates motivational quote based on user's notes
  static Future<String> generateMotivationalQuote(List<String> recentNotes) async {
    final notesContext = recentNotes.take(5).join('\n\n');

    final prompt = '''Based on the following recent notes from a user, generate a personalized motivational quote that is:
- Inspiring and uplifting
- Relevant to their current activities and interests
- Professional and meaningful
- Maximum 25 words
- No emojis or special characters
- Pure English only

Recent notes context:
$notesContext

Generate a single motivational quote that would inspire this person today.''';

    return await _makeGeminiRequest(prompt, temperature: 0.7, maxTokens: 100);
  }

  /// Analyzes all notes and extracts unique pending tasks (removes duplicates)
  static Future<List<String>> analyzePendingTasks(List<String> allNotes) async {
    if (allNotes.isEmpty) return [];

    final notesContent = allNotes.join('\n\n---\n\n');

    final prompt = '''Analyze ALL the following notes and extract unique pending tasks and action items. Remove duplicates and similar tasks:

Requirements:
- Extract only actionable tasks and to-dos
- Remove duplicate tasks (same or very similar tasks mentioned multiple times)
- Be specific and clear
- Use numbered format (1. 2. 3...)
- No emojis, symbols, or special characters
- Maximum 15 unique tasks
- Pure English only
- Fast and direct analysis
- If no tasks found, return "No pending tasks identified"

Notes to analyze:
$notesContent

Extract unique pending tasks without duplicates:''';

    final response = await _makeGeminiRequest(prompt, maxTokens: 400);

    if (response.toLowerCase().contains('no pending tasks') || response.trim().isEmpty) {
      return [];
    }

    // Extract tasks and remove duplicates
    final tasks = response
        .split('\n')
        .where((line) => line.trim().isNotEmpty && RegExp(r'^\d+\.').hasMatch(line.trim()))
        .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
        .where((task) => task.isNotEmpty)
        .toList();

    // Additional duplicate removal using Set to ensure uniqueness
    final uniqueTasks = <String>[];
    final seen = <String>{};

    for (final task in tasks) {
      final normalizedTask = task.toLowerCase().trim();
      if (!seen.contains(normalizedTask)) {
        seen.add(normalizedTask);
        uniqueTasks.add(task);
      }
    }

    return uniqueTasks.take(15).toList();
  }

  /// Generates personalized AI plan (returns both short and full versions)
  static Future<Map<String, String>> generatePersonalizedPlan(List<String> allNotes) async {
    if (allNotes.isEmpty) {
      final defaultPlan = "Start documenting your thoughts and activities to receive personalized recommendations.";
      return {
        'short': defaultPlan,
        'full': defaultPlan,
      };
    }

    final notesContext = allNotes.take(10).join('\n\n');

    final prompt = '''Based on the following notes, create a personalized daily plan with numbered points:

Requirements:
- Tailored to user activities and interests
- Actionable and practical points
- Short and fast manner
- Use numbered format (1. 2. 3...)
- No symbols, emojis, or special characters
- Pure English only
- Maximum 15 points
- No unnecessary text or precautions
- Direct and efficient

User notes:
$notesContext

Create a numbered daily plan:''';

    final response = await _makeGeminiRequest(prompt, temperature: 0.6, maxTokens: 350);

    // Extract numbered points
    final points = response
        .split('\n')
        .where((line) => line.trim().isNotEmpty && RegExp(r'^\d+\.').hasMatch(line.trim()))
        .toList();

    // Short version (first 10 points for display)
    final shortPoints = points.take(10).toList();
    final shortPlan = shortPoints.join('\n');

    // Full version (all points for note generation)
    final fullPlan = points.join('\n');

    return {
      'short': shortPlan.isNotEmpty ? shortPlan : "Plan your day with clear priorities and focused actions.",
      'full': fullPlan.isNotEmpty ? fullPlan : "Plan your day with clear priorities and focused actions.",
    };
  }

  /// Generates comprehensive smart daily note
  static Future<String> generateSmartDailyNote({
    required Map<String, dynamic>? weatherData,
    required Map<String, dynamic>? locationData,
    required List<String> pendingTasks,
    required String motivationalQuote,
    required String aiGeneratedPlan,
    required List<String> recentNotes,
  }) async {
    final weatherInfo = weatherData != null
        ? "Weather: ${weatherData['temperature']}°C, ${weatherData['condition']}"
        : "Weather information unavailable";

    final locationInfo = locationData != null
        ? "Location: ${locationData['city']}, ${locationData['country']}"
        : "Location information unavailable";

    final tasksInfo = pendingTasks.isNotEmpty
        ? "Pending tasks: ${pendingTasks.take(5).join(', ')}"
        : "No pending tasks identified";

    final notesContext = recentNotes.take(5).join('\n');

    final prompt = '''Create a comprehensive smart daily note based on the following information:

$weatherInfo
$locationInfo
Motivational quote: $motivationalQuote
AI Plan: $aiGeneratedPlan
$tasksInfo

Recent notes context:
$notesContext

Requirements:
1. Well-structured, 50–150 words max  
2. Formal and professional tone (some light humor occasionally is fine)  
3. No emojis, no symbols like *, #,%,or any symbol, etc.  
4. No formatting like bold or italics — pure plain text  
5. Use serial numbers if giving points  
6. The note must feel genuinely useful and engaging 
7.Very logical and well created plan , if possible give in points
8. It should be faster read, user must read and get its information faster, not useless english expanding
9.Must be compact and user engaging, and high quality
10.Do not mention same task twice, unless it related to something else, so please clarify and conform then only add
11.Make it great''';

    return await _makeGeminiRequest(prompt, temperature: 0.5, maxTokens: 400);
  }
}
