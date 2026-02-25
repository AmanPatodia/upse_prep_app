import '../domain/ai_models.dart';

abstract class AiEngine {
  Future<List<AiUpdate>> fetchSmartUpdates();
}

class DemoAiEngine implements AiEngine {
  @override
  Future<List<AiUpdate>> fetchSmartUpdates() async {
    return [
      AiUpdate(
        id: 'ai1',
        type: AiUpdateType.summary,
        title: 'Daily UPSC Summary',
        content:
            '7 key events condensed into GS-friendly summaries with prelims facts + mains angle.',
        createdAt: DateTime.now(),
      ),
      AiUpdate(
        id: 'ai2',
        type: AiUpdateType.generatedMcq,
        title: 'Generated MCQs from Economy News',
        content:
            'Created 12 moderate-level MCQs from fiscal deficit and inflation articles.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AiUpdate(
        id: 'ai3',
        type: AiUpdateType.lastMinuteNotes,
        title: 'One-page Quick Revision: Parliament',
        content:
            'Generated concise notes with frequently asked facts and PYQ patterns.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
