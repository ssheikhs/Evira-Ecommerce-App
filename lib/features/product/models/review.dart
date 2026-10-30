import 'package:flutter/foundation.dart';

@immutable
class Review {
  final int rating;
  final String comment;
  final String reviewerName;
  final DateTime? date;

  const Review({
    required this.rating,
    required this.comment,
    required this.reviewerName,
    this.date,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      comment: map['comment']?.toString() ?? '',
      reviewerName: map['reviewerName']?.toString() ?? 'Anonymous',
      date: DateTime.tryParse(map['date']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() => {
    'rating': rating,
    'comment': comment,
    'reviewerName': reviewerName,
    'date': date?.toIso8601String(),
  };
}
