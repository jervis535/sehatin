import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class ReviewsScreen extends StatefulWidget {
  final int reviewerId;
  final String token;

  const ReviewsScreen({
    Key? key,
    required this.reviewerId,
    required this.token,
  }) : super(key: key);

  @override
  _ReviewsScreenState createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late Future<List<ReviewModel>> _pendingReviewsFuture;

  @override
  void initState() {
    super.initState();
    _pendingReviewsFuture = ReviewService.fetchPendingReviews(
      reviewerId: widget.reviewerId,
      token: widget.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Reviews'),
      ),
      body: FutureBuilder<List<ReviewModel>>(
        future: _pendingReviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reviews = snapshot.data!;
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews to rate.'));
          }
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return ReviewTile(
                review: reviews[index],
                token: widget.token,
                onReviewSubmitted: () {
                  // Once a review is submitted, refetch the list:
                  setState(() {
                    _pendingReviewsFuture = ReviewService.fetchPendingReviews(
                      reviewerId: widget.reviewerId,
                      token: widget.token,
                    );
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// A single card/tile for rating one reviewee.
class ReviewTile extends StatefulWidget {
  final ReviewModel review;
  final String token;
  final VoidCallback onReviewSubmitted;

  const ReviewTile({
    Key? key,
    required this.review,
    required this.token,
    required this.onReviewSubmitted,
  }) : super(key: key);

  @override
  _ReviewTileState createState() => _ReviewTileState();
}

class _ReviewTileState extends State<ReviewTile> {
  int _selectedRating = 0;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;
  late Future<UserModel?> _revieweeFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the reviewee’s user info so we can display their name/email
    _revieweeFuture = UserService.fetchUserById(widget.review.revieweeId);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onStarTap(int star) {
    setState(() {
      _selectedRating = star;
    });
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating (1–5 stars).')),
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
    });

    try {
      await ReviewService.submitReview(
        reviewId: widget.review.id,
        score: _selectedRating,
        notes: _notesController.text.trim(),
        token: widget.token,
      );
      widget.onReviewSubmitted();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildStarRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        return IconButton(
          icon: Icon(
            Icons.star,
            color: starIndex <= _selectedRating
                ? Colors.amber
                : Colors.grey.shade400,
          ),
          onPressed: () => _onStarTap(starIndex),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserModel?>(
              future: _revieweeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Loading reviewee…');
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Text('Unknown user');
                }
                final user = snapshot.data!;
                return Text(
                  'Reviewee: ${user.username} (${user.email})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text('Rate (1–5 stars):'),
            _buildStarRow(),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Write notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
