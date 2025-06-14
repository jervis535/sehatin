class ReviewModel {
  final int id;
  final int reviewerId;
  final int revieweeId;
  int? score;
  String? notes;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.reviewerId,
    required this.revieweeId,
    this.score,
    this.notes,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as int,
        reviewerId: json['reviewer_id'] as int,
        revieweeId: json['reviewee_id'] as int,
        score: json['score'] != null ? json['score'] as int : null,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'reviewer_id': reviewerId,
        'reviewee_id': revieweeId,
        'score': score,
        'notes': notes,
      };
}
