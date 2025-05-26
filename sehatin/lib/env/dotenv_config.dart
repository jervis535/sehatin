import 'package:flutter_dotenv/flutter_dotenv.dart';

class DotenvConfig {
  static String get baseUrl => dotenv.env['API_URL']!;
}
