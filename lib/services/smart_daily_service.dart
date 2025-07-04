// services/smart_daily_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/ai_service.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firestore_db.dart';

class SmartDailyService {
  final FireDB _fireDB = FireDB();
  final Uuid _uuid = Uuid();

  /// Gets current location
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      return {
        'lat': position.latitude,
        'lon': position.longitude,
        'city': place.locality ?? 'Unknown',
        'country': place.country ?? 'Unknown',
        'full_address': '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}',
      };
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  /// Gets weather information
  Future<Map<String, dynamic>> getWeatherInfo(double lat, double lon) async {
    try {
      final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? ''; // Replace with your API key
      final String url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'temperature': data['main']['temp'].round(),
          'condition': data['weather'][0]['description'],
          'icon': _getWeatherIcon(data['weather'][0]['main']),
          'wind_speed': data['wind']['speed'].toDouble(),
        };
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      // Return default weather data if API fails
      return {
        'temperature': 22,
        'condition': 'Clear',
        'icon': '☀️',
        'wind_speed': 5.0,
      };
    }
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      default:
        return '🌤️';
    }
  }

  /// Gets all user notes and extracts pending tasks
  Future<List<String>> getPendingTasksFromNotes() async {
    try {
      final userEmail = await _fireDB.getCurrentUserEmail();
      final notes = await _fireDB.getAllStoredNotesForUser(userEmail);

      final noteContents = notes
          .where((note) => !note.isArchieve)
          .map((note) => '${note.title}\n${note.content}')
          .toList();

      return await AIService.analyzePendingTasks(noteContents);
    } catch (e) {
      print('Error getting pending tasks: $e');
      return [];
    }
  }

  /// Generates motivational quote based on user's notes
  Future<String> generateMotivationalQuote() async {
    try {
      final userEmail = await _fireDB.getCurrentUserEmail();
      final notes = await _fireDB.getAllStoredNotesForUser(userEmail);

      final recentNotes = notes
          .where((note) => !note.isArchieve)
          .take(5)
          .map((note) => '${note.title}\n${note.content}')
          .toList();

      if (recentNotes.isEmpty) {
        return "Every great journey begins with a single step. Start documenting your thoughts today.";
      }

      return await AIService.generateMotivationalQuote(recentNotes);
    } catch (e) {
      print('Error generating motivational quote: $e');
      return "Focus on progress, not perfection. Every small step counts toward your goals.";
    }
  }

  /// Generates AI daily plan
  Future<String> generateAIDailyPlan() async {
    try {
      final userEmail = await _fireDB.getCurrentUserEmail();
      final notes = await _fireDB.getAllStoredNotesForUser(userEmail);

      final allNotes = notes
          .where((note) => !note.isArchieve)
          .map((note) => '${note.title}\n${note.content}')
          .toList();

      final planResult = await AIService.generatePersonalizedPlan(allNotes);
      return planResult['short'] ?? "Plan your day with clear priorities and focused actions.";

    } catch (e) {
      print('Error generating AI daily plan: $e');
      return "Plan your day with intention. Set clear priorities and take consistent action toward your goals.";
    }
  }

  /// Checks if today's note already exists
  Future<Note?> getTodayNote() async {
    try {
      final userEmail = await _fireDB.getCurrentUserEmail();
      final notes = await _fireDB.getAllStoredNotesForUser(userEmail);

      final today = DateTime.now();
      final todayNote = notes.where((note) {
        final noteDate = note.createdTime;
        return noteDate.year == today.year &&
            noteDate.month == today.month &&
            noteDate.day == today.day &&
            note.title.contains('Smart Daily Note');
      }).firstOrNull;

      return todayNote;
    } catch (e) {
      print('Error checking today note: $e');
      return null;
    }
  }

  /// Generates complete daily note with all data
  Future<Note?> generateDailyNoteWithData({
    required Map<String, dynamic>? weatherData,
    required Map<String, dynamic>? locationData,
    required List<String> pendingTasks,
    required String motivationalQuote,
    required String aiGeneratedPlan,
  }) async {
    try {
      final userEmail = await _fireDB.getCurrentUserEmail();
      final notes = await _fireDB.getAllStoredNotesForUser(userEmail);

      final recentNotes = notes
          .where((note) => !note.isArchieve)
          .take(10)
          .map((note) => '${note.title}\n${note.content}')
          .toList();

      final allNotes = notes
          .where((note) => !note.isArchieve)
          .map((note) => '${note.title}\n${note.content}')
          .toList();

      final planResult = await AIService.generatePersonalizedPlan(allNotes);
      final fullPlan = planResult['full'] ?? aiGeneratedPlan;

      final content = await AIService.generateSmartDailyNote(
        weatherData: weatherData,
        locationData: locationData,
        pendingTasks: pendingTasks,
        motivationalQuote: motivationalQuote,
        aiGeneratedPlan: fullPlan,
        recentNotes: recentNotes,
      );

      final now = DateTime.now();
      final title = 'Smart Daily Note - ${now.day}/${now.month}/${now.year}';

      final note = Note(
        title: title,
        content: content,
        uniqueID: _uuid.v4(),
        createdTime: now,
        pin: false,
        isArchieve: false,
      );

      await _fireDB.createNewNoteFirestore(note);
      return note;
    } catch (e) {
      print('Error generating daily note: $e');
      throw Exception('Failed to generate daily note: ${e.toString()}');
    }
  }
}
