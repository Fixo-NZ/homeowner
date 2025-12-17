import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/tradie_model.dart';

class TradieRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<TradieModel>> fetchTradies() async {
    // Try a set of candidate endpoints (server may expose the list under
    // different paths). The baseUrl already contains '/api', so candidates
    // should be relative paths without '/api'.
    final candidates = [
      '/tradies',
      '/homeowner/tradies',
      '/tradie',
      '/homeowner/tradie',
      '/users/tradies',
    ];

    for (final path in candidates) {
      try {
        print('TradieRepository: trying $path');
        final resp = await _dio.get(path);
        if (resp.statusCode == 200) {
          final data = resp.data;
          if (data is List) {
            return data.map((e) => TradieModel.fromJson(e as Map<String, dynamic>)).toList();
          }
          if (data is Map && data['data'] is List) {
            return (data['data'] as List).map((e) => TradieModel.fromJson(e as Map<String, dynamic>)).toList();
          }
          // If response is a map with a top-level collection under another key,
          // attempt to find the first List value.
          if (data is Map) {
            final maybeList = data.values.firstWhere((v) => v is List, orElse: () => null);
            if (maybeList is List) {
              return maybeList.map((e) => TradieModel.fromJson(e as Map<String, dynamic>)).toList();
            }
          }
          print('TradieRepository: $path returned 200 but unexpected body shape: ${resp.data}');
        } else {
          print('TradieRepository: $path returned status ${resp.statusCode}');
        }
      } on DioException catch (e) {
        print('TradieRepository: $path failed: ${e.message}');
        // continue to next candidate
      } catch (e, s) {
        print('TradieRepository: $path unexpected error: $e\n$s');
      }
    }

    print('TradieRepository: no candidate endpoint returned a valid tradie list');
    return [];
  }
}
