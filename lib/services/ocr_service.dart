import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRResult {
  final double? amount;
  final String? category;
  
  OCRResult({this.amount, this.category});
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
    );
  }

  double? _extractHighestAmount(String text) {
    // Regex to match typical price formats like: $12.34, 12.34, 1,234.56, ₹12.34
    // We'll extract all numbers with decimals and find the max
    final regex = RegExp(r'\b\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{2})\b');
    final matches = regex.allMatches(text);
    
    double maxAmount = 0.0;
    bool found = false;

    for (final match in matches) {
      final str = match.group(0);
      if (str != null) {
        // Clean up formatting: e.g. 1,234.56 -> 1234.56 or 12,34 -> 12.34
        String cleanStr = str.replaceAll(',', '.'); 
        // If there are multiple dots, remove all but the last
        if ('.'.allMatches(cleanStr).length > 1) {
          final lastIndex = cleanStr.lastIndexOf('.');
          cleanStr = cleanStr.substring(0, lastIndex).replaceAll('.', '') + cleanStr.substring(lastIndex);
        }

        final val = double.tryParse(cleanStr);
        if (val != null) {
          if (val > maxAmount) {
            maxAmount = val;
            found = true;
          }
        }
      }
    }

    return found ? maxAmount : null;
  }

  String? _guessCategory(String text) {
    final lowerText = text.toLowerCase();
    
    // Simple keyword mapping based on common receipt terms
    final Map<String, List<String>> keywordMap = {
      'Food': ['restaurant', 'cafe', 'bistro', 'coffee', 'starbucks', 'mcdonalds', 'kfc', 'burger', 'pizza', 'deli', 'bakery', 'subway', 'dining'],
      'Groceries': ['supermarket', 'walmart', 'target', 'whole foods', 'trader joe', 'grocery', 'market', 'tesco', 'safeway', 'kroger', 'aldi'],
      'Transport': ['uber', 'lyft', 'taxi', 'cab', 'transit', 'metro', 'train', 'bus', 'flight', 'airlines', 'fuel', 'gas', 'shell', 'chevron', 'bp'],
      'Shopping': ['amazon', 'apple', 'best buy', 'mall', 'clothing', 'shoes', 'apparel', 'electronics'],
      'Health': ['pharmacy', 'cvs', 'walgreens', 'hospital', 'clinic', 'dental', 'doctor', 'medication'],
      'Entertainment': ['cinema', 'movie', 'amc', 'theater', 'ticket', 'concert', 'netflix', 'spotify'],
      'Utilities': ['electric', 'water', 'internet', 'comcast', 'verizon', 'att', 't-mobile', 'bill'],
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
