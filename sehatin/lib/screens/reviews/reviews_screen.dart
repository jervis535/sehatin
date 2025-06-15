import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class ReviewsScreen extends StatefulWidget {
  final int reviewerId;
  final String token;

  const ReviewsScreen({Key? key, required this.reviewerId, required this.token})
    : super(key: key);

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
      backgroundColor: const Color(0xFFF7EAEA),
      appBar: AppBar(
        title: const Text(
          'Pending Reviews',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: FutureBuilder<List<ReviewModel>>(
        future: _pendingReviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color.fromARGB(255, 52, 43, 182),
                  ),
                  SizedBox(height: 16),
                  Text('Loading reviews...'),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }
          final reviews = snapshot.data!;
          if (reviews.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Color.fromARGB(255, 52, 43, 182),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No reviews to rate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              return ReviewTile(
                review: reviews[index],
                token: widget.token,
                onReviewSubmitted: () {
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
        const SnackBar(
          content: Text('Please select a rating (1–5 stars).'),
          backgroundColor: Colors.orange,
        ),
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
        const SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildStarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final starIndex = i + 1;
        return GestureDetector(
          onTap: () => _onStarTap(starIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starIndex <= _selectedRating ? Icons.star : Icons.star_border,
              size: 36,
              color:
                  starIndex <= _selectedRating
                      ? Colors.amber
                      : Colors.grey.shade400,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 52, 43, 182),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: FutureBuilder<UserModel?>(
              future: _revieweeFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    'Loading reviewee...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return const Text(
                    'Unknown user',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  );
                }
                final user = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviewee: ${user.username}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rate (1–5 stars):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildStarRow(),
                const SizedBox(height: 16),

                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Write notes (optional)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 52, 43, 182),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Submit Review',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
