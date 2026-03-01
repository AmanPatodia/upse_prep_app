import 'dart:convert';
import 'dart:io';

void main() async {
  final file = File('/Users/aman.patodia/AMS IAS/assets/data/pyqs.json');
  final raw = await file.readAsString();
  final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;

  final existing = decoded.cast<Map<String, dynamic>>();
  final existingNos = existing
      .map((e) => e['questionNumber'])
      .whereType<num>()
      .map((e) => e.toInt())
      .toSet();

  const answers = <int, String>{
    13: 'B', 14: 'A', 15: 'A', 16: 'C', 17: 'D', 18: 'C', 19: 'B', 20: 'B',
    21: 'C', 22: 'C', 23: 'B', 24: 'A', 25: 'B', 26: 'C', 27: 'B', 28: 'D',
    29: 'B', 30: 'C', 31: 'B', 32: 'D', 33: 'A', 34: 'B', 35: 'D', 36: 'C',
    37: 'A', 38: 'A', 39: 'A', 40: 'A', 41: 'B', 42: 'C', 43: 'D', 44: 'D',
    45: 'C', 46: 'C', 47: 'A', 48: 'C', 49: 'C', 50: 'C', 51: 'D', 52: 'D',
    53: 'C', 54: 'D', 55: 'A', 56: 'D', 57: 'A', 58: 'A', 59: 'A', 60: 'B',
    61: 'A', 62: 'A', 63: 'C', 64: 'B', 65: 'A', 66: 'A', 67: 'C', 68: 'D',
    69: 'D', 70: 'A', 71: 'D', 72: 'A', 73: 'D', 74: 'C', 75: 'A', 76: 'C',
    77: 'C', 79: 'B', 80: 'D', 81: 'C', 82: 'B', 83: 'A', 84: 'A', 85: 'C',
    86: 'D', 87: 'A', 88: 'A', 89: 'D', 90: 'B', 91: 'B', 92: 'C', 93: 'B',
    94: 'A', 95: 'C', 99: 'C', 100: 'D'
  };

  for (final entry in answers.entries) {
    final qNo = entry.key;
    if (existingNos.contains(qNo)) continue;

    existing.add({
      'year': 2025,
      'paperType': 'gs',
      'paperNumber': 2,
      'questionNumber': qNo,
      'subject': _subjectFor(qNo),
      'chapter': _chapterFor(qNo),
      'question': 'UPSC Prelims 2025 GS-I Question $qNo',
      'options': const ['Option A', 'Option B', 'Option C', 'Option D'],
      'answer': entry.value,
      'sourceName': 'UPSC Prelims 2025 GS-I',
      'explanation':
          'Expert key (Unofficial). Full question text can be updated in asset later.',
    });
  }

  existing.sort((a, b) {
    final an = (a['questionNumber'] as num?)?.toInt() ?? 0;
    final bn = (b['questionNumber'] as num?)?.toInt() ?? 0;
    return an.compareTo(bn);
  });

  final encoder = const JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(existing)}\n');
  stdout.writeln('Updated entries: ${existing.length}');
}

String _subjectFor(int qNo) {
  if (qNo <= 20) return 'Science and Tech';
  if (qNo <= 30) return 'History';
  if (qNo <= 40) return 'Economy';
  if (qNo <= 50) return 'Geography';
  if (qNo <= 70) return 'Polity and Governance';
  if (qNo <= 80) return 'Economy';
  if (qNo <= 90) return 'Polity and Governance';
  return 'History';
}

String _chapterFor(int qNo) => 'GS Paper I 2025';
