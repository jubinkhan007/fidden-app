import 'package:get/get.dart';
import '../../reviews/data/review_model.dart';

class ReviewController extends GetxController {
  var reviews = <Review>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  void fetchReviews() {
    isLoading.value = true;
    // Using static data for now
    reviews.value = [
      Review(
        author: 'Jane Doe',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        rating: 5.0,
        comment: 'Absolutely amazing service! I will definitely be back.',
        serviceName: 'HairCut',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        author: 'John Smith',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        rating: 4.0,
        comment: 'Great experience, but the wait was a bit long.',
        date: DateTime.now().subtract(const Duration(days: 5)),
        serviceName: 'Maniciure And Pedicure',
        reply:
            'Thank you for your feedback, John! We are working on improving our wait times.',
      ),
      Review(
        author: 'Emily White',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        rating: 5.0,
        comment: 'The best haircut I\'ve ever had!',
        serviceName: 'HairCut',
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    isLoading.value = false;
  }

  void addReply(Review review, String replyText) {
    review.reply = replyText;
    reviews.refresh(); // This triggers the UI to update
  }
}
