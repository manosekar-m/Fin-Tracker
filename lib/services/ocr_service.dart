import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRResult {
  final double? amount;
  final String? category;
  final DateTime? date;
  final String? notes;
  
  OCRResult({this.amount, this.category, this.date, this.notes});
}

class OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OCRResult> processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    
    final fullText = recognizedText.text;
    
    return OCRResult(
      amount: _extractHighestAmount(fullText),
      category: _guessCategory(fullText),
      date: _extractDate(fullText),
      notes: _guessNotes(fullText),
    );
  }

  double? _extractHighestAmount(String text) {
    // Improved regex to match integers and various decimal formats: 123, 123.45, 1,234.56, ₹1,234
    // We look for currency-like numbers and find the maximum one (often the total)
    final regex = RegExp(r'(?:\₹|\$|RS|INR)?\s?(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{1,2})?|\d+[.,]\d{1,2}|\d+)');
    final matches = regex.allMatches(text);
    
    double maxAmount = 0.0;
    bool found = false;

    for (final match in matches) {
      final str = match.group(1); // Group 1 contains the actual number
      if (str != null) {
        // Normalize: remove thousands separators and ensure dot is decimal separator
        // If it looks like 1.234,56 (European) vs 1,234.56 (US/India)
        String cleanStr = str.replaceAll(',', ''); 
        if (cleanStr.contains('.') && cleanStr.split('.').last.length > 2) {
          // Probably 1.234 format (dot used as thousand separator)
          cleanStr = cleanStr.replaceAll('.', '');
        }

        final val = double.tryParse(cleanStr);
        if (val != null) {
          // Basic heuristic: total is usually one of the larger numbers
          // But avoid obviously wrong huge numbers if any
          if (val > maxAmount && val < 1000000) {
            maxAmount = val;
            found = true;
          }
        }
      }
    }

    return found ? maxAmount : null;
  }

  DateTime? _extractDate(String text) {
    // Patterns: DD/MM/YYYY, DD-MM-YYYY, YYYY/MM/DD, DD MMM YYYY
    final patterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
      RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'),
      RegExp(r'(\d{1,2})\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s(\d{2,4})', caseSensitive: false),
    ];

    for (final p in patterns) {
      final match = p.firstMatch(text);
      if (match != null) {
        try {
          if (match.groupCount == 3) {
            int day, month, year;
            if (p.pattern.startsWith('(\\d{4})')) {
              year = int.parse(match.group(1)!);
              month = int.parse(match.group(2)!);
              day = int.parse(match.group(3)!);
            } else if (match.group(2)!.length > 2) {
              // Month name
              day = int.parse(match.group(1)!);
              final monthStr = match.group(2)!.toLowerCase();
              final months = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'];
              month = months.indexWhere((m) => monthStr.startsWith(m)) + 1;
              year = int.parse(match.group(3)!);
            } else {
              day = int.parse(match.group(1)!);
              month = int.parse(match.group(2)!);
              year = int.parse(match.group(3)!);
            }
            if (year < 100) year += 2000;
            return DateTime(year, month, day);
          }
        } catch (_) {}
      }
    }
    return null;
  }

  String? _guessNotes(String text) {
    // The merchant name is often on the first few lines of the receipt
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.length > 3).toList();
    for (final line in lines) {
      // Skip if line contains numbers (likely an address or phone or amount)
      if (!RegExp(r'\d').hasMatch(line)) {
        return line;
      }
    }
    return lines.isNotEmpty ? lines.first : null;
  }

  String? _guessCategory(String text) {
    final lowerText = text.toLowerCase();
    
    // Simple keyword mapping based on common receipt terms
    final Map<String, List<String>> keywordMap = {
      'Food': ['restaurant', 'cafe', 'bistro', 'coffee', 'starbucks', 'mcdonalds', 'kfc', 'burger', 'pizza', 'deli', 'bakery', 'subway', 'dining', 'food', 'eat', 'kitchen', 'swiggy', 'zomato'],
      'Transport': ['uber', 'lyft', 'taxi', 'cab', 'transit', 'metro', 'train', 'bus', 'flight', 'airlines', 'fuel', 'gas', 'shell', 'chevron', 'bp', 'petrol', 'diesel', 'auto', 'ola'],
      'Shopping': ['amazon', 'apple', 'best buy', 'mall', 'clothing', 'shoes', 'apparel', 'electronics', 'fashion', 'retail', 'store', 'h&m', 'zara', 'walmart', 'target'],
      'Bills': ['electric', 'water', 'internet', 'comcast', 'verizon', 'att', 't-mobile', 'bill', 'recharge', 'jio', 'airtel', 'power', 'utility', 'gas bill'],
      'Health': ['pharmacy', 'cvs', 'walgreens', 'hospital', 'clinic', 'dental', 'doctor', 'medication', 'medicine', 'lab', 'health', 'apollo'],
      'Entertainment': ['cinema', 'movie', 'amc', 'theater', 'ticket', 'concert', 'netflix', 'spotify', 'pvr', 'inox', 'show'],
      'Education': ['school', 'college', 'university', 'tuition', 'book', 'stationary', 'course', 'udemy', 'coursera', 'fee'],
      'Investment': ['stock', 'mutual fund', 'crypto', 'bitcoin', 'zerodha', 'upstox', 'groww', 'gold', 'silver'],
    };

    for (final entry in keywordMap.entries) {
      for (final keyword in entry.value) {
        if (lowerText.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return null; // Let the UI default or let user choose
  }

  void dispose() {
    _textRecognizer.close();
  }
}
