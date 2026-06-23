import '../../domain/entities/paginated_votes.dart';
import 'deputy_vote_dto.dart';

class PaginatedVotesDto {
  const PaginatedVotesDto({
    required this.votes,
    required this.currentPage,
    required this.lastPage,
  });

  final List<DeputyVoteDto> votes;
  final int currentPage;
  final int lastPage;

  factory PaginatedVotesDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

    if (data is! List) {
      throw Exception('Missing data array in votes response');
    }

    return PaginatedVotesDto(
      votes: data
          .whereType<Map<String, dynamic>>()
          .map(DeputyVoteDto.fromJson)
          .toList(growable: false),
      currentPage: _asInt(meta['current_page']) ?? 1,
      lastPage: _asInt(meta['last_page']) ?? 1,
    );
  }

  PaginatedVotes toDomain() {
    return PaginatedVotes(
      votes: votes.map((vote) => vote.toDomain()).toList(growable: false),
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
}
