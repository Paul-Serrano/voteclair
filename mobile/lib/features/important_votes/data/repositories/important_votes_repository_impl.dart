import '../../../../core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/important_vote_item.dart';
import '../../domain/repositories/important_votes_repository.dart';
import '../dto/important_vote_item_dto.dart';

class ImportantVotesRepositoryImpl implements ImportantVotesRepository {
  ImportantVotesRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ImportantVoteItem>> getImportantVotes({int limit = 20}) async {
    try {
      return await _fetchFromScrutinsList(limit);
    } on DioException catch (error) {
      final shouldRetry = error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout;

      if (!shouldRetry) {
        return _fetchImportantVotes(limit);
      }

      try {
        return await _fetchFromScrutinsList(limit);
      } on DioException {
        return _fetchImportantVotes(limit);
      }
    }
  }

  Future<List<ImportantVoteItem>> _fetchFromScrutinsList(int limit) async {
    final response = await _apiClient.get(
      '/scrutins',
      queryParameters: <String, dynamic>{
        'order_by': 'importance',
        'order_dir': 'desc',
        'importance': 'important',
        'page': 1,
      },
    );

    return _extractData(response.data)
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .take(limit)
        .map((item) {
          if (item['date_scrutin'] == null && item['date'] != null) {
            item['date_scrutin'] = item['date'];
          }
          return item;
        })
        .map(ImportantVoteItemDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList(growable: false);
  }

  Future<List<ImportantVoteItem>> _fetchImportantVotes(int limit) async {
    final response = await _apiClient.get(
      '/scrutins/important',
      queryParameters: <String, dynamic>{'limit': limit},
    );
    final rawData = _extractData(response.data);

    return rawData
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(ImportantVoteItemDto.fromJson)
        .map((dto) => dto.toDomain())
        .toList(growable: false);
  }

  List<dynamic> _extractData(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data;
      }
    }

    return const <dynamic>[];
  }

}
