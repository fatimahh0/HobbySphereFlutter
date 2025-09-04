import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

import '../../data/repositories/review_repository_impl.dart';
import '../../data/services/review_service.dart';
import '../../domain/usecases/get_business_reviews.dart';
import '../bloc/business_reviews_bloc.dart';
import '../bloc/business_reviews_event.dart';
import '../bloc/business_reviews_state.dart';
import '../widgets/review_card.dart';

class BusinessReviewsScreen extends StatelessWidget {
  final int businessId;
  final String token;

  const BusinessReviewsScreen({
    super.key,
    required this.businessId,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => BusinessReviewsBloc(
        GetBusinessReviews(ReviewRepositoryImpl(ReviewService())),
      )..add(LoadBusinessReviews(token, businessId)),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(tr.reviewsTitle), // i18n key
          backgroundColor: theme.colorScheme.surface,
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<BusinessReviewsBloc, BusinessReviewsState>(
          builder: (context, state) {
            if (state is BusinessReviewsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BusinessReviewsError) {
              return Center(child: Text(state.message));
            }
            if (state is BusinessReviewsLoaded) {
              if (state.reviews.isEmpty) {
                return Center(child: Text(tr.reviewsNoReviews)); // i18n key
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.reviews.length,
                itemBuilder: (context, i) =>
                    ReviewCard(review: state.reviews[i]),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
