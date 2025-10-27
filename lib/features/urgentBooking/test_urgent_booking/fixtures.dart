import '../models/service_model.dart';
import '../models/tradie_recommendation.dart';

ServiceModel buildService({int id = 1, String status = 'Pending'}) {
  return ServiceModel(
    jobId: id,
    homeownerId: 1,
    jobCategoryId: 1,
    jobDescription: 'Test job',
    location: 'Test location',
    status: status,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

TradieRecommendation buildTradie({int id = 1, String name = 'John'}) {
  return TradieRecommendation(
    id: id,
    name: name,
    occupation: 'Plumber',
    rating: 4.5,
    serviceArea: 'Nearby',
    yearsExperience: 5,
    distanceKm: 2.3,
    hourlyRate: 75.0,
    availability: 'Available',
    skills: ['Plumbing', 'Repair'],
    profileImage: null,
    isVerified: true,
    isTopRated: false,
    jobsCompleted: 12,
    reviewsCount: 34,
  );
}

TradieRecommendationResponse buildRecommendations() {
  return TradieRecommendationResponse(
    success: true,
    message: 'OK',
    serviceId: 1,
    recommendations: [buildTradie()],
  );
}
