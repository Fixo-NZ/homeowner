import 'package:flutter_test/flutter_test.dart';
import 'package:tradie/features/feedback/models/contractor.dart';

void main() {
  group('Contractor Model', () {
    test('should create a Contractor instance', () {
      final contractor = Contractor(
        id: '1',
        name: 'John Builder',
        specialty: 'Carpenter',
        avatar: 'JB',
        rating: 4.8,
        completedJobs: 150,
      );

      expect(contractor.id, '1');
      expect(contractor.name, 'John Builder');
      expect(contractor.specialty, 'Carpenter');
      expect(contractor.avatar, 'JB');
      expect(contractor.rating, 4.8);
      expect(contractor.completedJobs, 150);
    });

    test('should create Contractor from JSON', () {
      final json = {
        'id': '2',
        'name': 'Maria Garcia',
        'specialty': 'Electrician',
        'avatar': 'MG',
        'rating': 4.9,
        'completedJobs': 200,
      };

      final contractor = Contractor.fromJson(json);

      expect(contractor.id, '2');
      expect(contractor.name, 'Maria Garcia');
      expect(contractor.specialty, 'Electrician');
      expect(contractor.rating, 4.9);
      expect(contractor.completedJobs, 200);
    });

    test('should convert Contractor to JSON', () {
      final contractor = Contractor(
        id: '3',
        name: 'David Chen',
        specialty: 'Plumber',
        avatar: 'DC',
        rating: 5.0,
        completedJobs: 175,
      );

      final json = contractor.toJson();

      expect(json['id'], '3');
      expect(json['name'], 'David Chen');
      expect(json['specialty'], 'Plumber');
      expect(json['avatar'], 'DC');
      expect(json['rating'], 5.0);
      expect(json['completedJobs'], 175);
    });
  });
}
