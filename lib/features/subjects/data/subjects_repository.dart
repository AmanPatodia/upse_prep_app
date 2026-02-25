import '../domain/subject_models.dart';

abstract class SubjectsRepository {
  Future<List<Subject>> getSubjects();
  Future<Topic?> getTopicById(String topicId);
}

class DemoSubjectsRepository implements SubjectsRepository {
  static const _subjects = [
    Subject(
      id: 'polity',
      name: 'Indian Polity',
      chapters: [
        Chapter(
          id: 'const-framework',
          subjectId: 'polity',
          title: 'Constitutional Framework',
          topics: [
            Topic(
              id: 'preamble',
              chapterId: 'const-framework',
              title: 'Preamble',
              notes:
                  'The Preamble declares India as sovereign, socialist, secular, democratic republic.',
              importantPoints: [
                'Justice, liberty, equality, fraternity',
                'Added terms by 42nd Amendment',
              ],
              bookReferences: ['Laxmikanth Ch. 2', 'NCERT Polity Class XI'],
              pdfUrl: 'https://example.com/preamble.pdf',
            ),
            Topic(
              id: 'features',
              chapterId: 'const-framework',
              title: 'Salient Features',
              notes:
                  'Blend of rigidity and flexibility, federal system with unitary bias, independent judiciary.',
              importantPoints: ['Parliamentary form', 'Single citizenship'],
              bookReferences: ['Laxmikanth Ch. 1'],
              revisionPriority: RevisionPriority.high,
            ),
          ],
        ),
      ],
    ),
    Subject(
      id: 'economy',
      name: 'Economy',
      chapters: [
        Chapter(
          id: 'macro',
          subjectId: 'economy',
          title: 'Macroeconomics',
          topics: [
            Topic(
              id: 'gdp',
              chapterId: 'macro',
              title: 'GDP Concepts',
              notes:
                  'Nominal vs real GDP, GDP deflator, base year revisions and limitations.',
              importantPoints: [
                'GDP at constant prices',
                'GVA vs GDP relation',
              ],
              bookReferences: ['NCERT XII Macroeconomics', 'Sriram IAS notes'],
              revisionPriority: RevisionPriority.medium,
            ),
          ],
        ),
      ],
    ),
  ];

  @override
  Future<List<Subject>> getSubjects() async => _subjects;

  @override
  Future<Topic?> getTopicById(String topicId) async {
    for (final subject in _subjects) {
      for (final chapter in subject.chapters) {
        for (final topic in chapter.topics) {
          if (topic.id == topicId) return topic;
        }
      }
    }
    return null;
  }
}
