import '../domain/mcq_models.dart';

abstract class McqRepository {
  Future<List<McqQuestion>> getSubjectMcqs({String? subject, String? chapter});
  Future<List<AttemptSummary>> getAttemptHistory();
  Future<List<String>> getSubjects();
  Future<List<String>> getChaptersBySubject(String subject);
}

class DemoMcqRepository implements McqRepository {
  static const _syllabus = {
    'History': [
      'Ancient India',
      'Medieval India',
      'Modern India',
      'Indian National Movement',
      'Art and Culture',
    ],
    'Geography': [
      'Physical Geography',
      'Indian Geography',
      'World Geography',
      'Resources and Industries',
      'Climate and Monsoon',
    ],
    'Indian Polity and Governance': [
      'Constitutional Framework',
      'Fundamental Rights and Duties',
      'Parliament and Legislature',
      'Judiciary',
      'Constitutional Bodies',
    ],
    'Economy': [
      'National Income',
      'Inflation and Monetary Policy',
      'Fiscal Policy and Budget',
      'Banking and Financial Markets',
      'External Sector',
    ],
    'Environment and Ecology': [
      'Ecosystems and Biodiversity',
      'Climate Change',
      'Pollution and Conservation',
      'Environmental Conventions',
      'Protected Areas in India',
    ],
    'General Science and Science Tech': [
      'Basic Physics Chemistry Biology',
      'Biotechnology',
      'Space and Defense Technology',
      'Computer and AI Basics',
      'Health and Disease',
    ],
    'Current Affairs': [
      'National Events',
      'International Relations',
      'Economy Current Affairs',
      'Environment Current Affairs',
      'Science and Tech Current Affairs',
    ],
    'CSAT Aptitude': [
      'Comprehension',
      'Logical Reasoning and Analytical Ability',
      'Decision Making and Problem Solving',
      'Basic Numeracy',
      'Data Interpretation',
    ],
  };

  static final _questions = <McqQuestion>[
    for (final subjectEntry in _syllabus.entries)
      for (final chapter in subjectEntry.value) ...[
        McqQuestion(
          id: '${subjectEntry.key}-$chapter-1',
          subject: subjectEntry.key,
          chapter: chapter,
          question:
              'Prelims practice: Choose the most accurate statement about "$chapter".',
          options: const [
            'Only statement 1 is correct',
            'Only statement 2 is correct',
            'Both statements are correct',
            'Neither statement is correct',
          ],
          correctIndex: 2,
          explanation:
              'Syllabus-aligned static practice question for $chapter under ${subjectEntry.key}.',
          difficulty: Difficulty.easy,
        ),
        McqQuestion(
          id: '${subjectEntry.key}-$chapter-2',
          subject: subjectEntry.key,
          chapter: chapter,
          question:
              'With reference to UPSC prelims, which pair related to "$chapter" is correctly matched?',
          options: const [
            '1 and 2 only',
            '2 and 3 only',
            '1 and 3 only',
            '1, 2 and 3',
          ],
          correctIndex: 0,
          explanation:
              'Pair-matching type static practice for chapter-wise prelims revision.',
          difficulty: Difficulty.medium,
        ),
        McqQuestion(
          id: '${subjectEntry.key}-$chapter-3',
          subject: subjectEntry.key,
          chapter: chapter,
          question:
              'Consider the following statements regarding "$chapter". Which of the above is/are correct?',
          options: const [
            '1 only',
            '2 only',
            'Both 1 and 2',
            'Neither 1 nor 2',
          ],
          correctIndex: 2,
          explanation:
              'Statement-based static prelims question template to build conceptual clarity.',
          difficulty: Difficulty.hard,
        ),
      ],
  ];

  static final _history = [
    AttemptSummary(
      total: 100,
      correct: 68,
      avgSecondsPerQuestion: 54,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
    ),
    AttemptSummary(
      total: 50,
      correct: 39,
      avgSecondsPerQuestion: 49,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<AttemptSummary>> getAttemptHistory() async => _history;

  @override
  Future<List<McqQuestion>> getSubjectMcqs({
    String? subject,
    String? chapter,
  }) async {
    return _questions
        .where((q) {
          final subjectPass =
              subject == null || subject.trim().isEmpty || q.subject == subject;
          final chapterPass =
              chapter == null || chapter.trim().isEmpty || q.chapter == chapter;
          return subjectPass && chapterPass;
        })
        .toList(growable: false);
  }

  @override
  Future<List<String>> getSubjects() async =>
      _syllabus.keys.toList(growable: false);

  @override
  Future<List<String>> getChaptersBySubject(String subject) async {
    return _syllabus[subject] ?? const <String>[];
  }
}
