import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../core/theme.dart';
import '../models/lawyer.dart';

class LawyerCard extends StatelessWidget {
  final Lawyer lawyer;
  final VoidCallback onTap;
  final bool isCompact;

  const LawyerCard({
    super.key,
    required this.lawyer,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: isCompact ? const EdgeInsets.all(12) : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(isCompact ? 16 : 24),
          border: Border.all(
            color: AppTheme.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            Container(
              width: isCompact ? 60 : 80,
              height: isCompact ? 60 : 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
                color: AppTheme.borderLight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isCompact ? 16 : 20),
                child: CachedNetworkImage(
                  imageUrl: lawyer.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.borderLight,
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppTheme.textSecondary,
                      size: 32,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.borderLight,
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppTheme.textSecondary,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and verification
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lawyer.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isCompact ? 16 : 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lawyer.isVerified) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 12,
                                color: AppTheme.successColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.successColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Specialty
                  Text(
                    lawyer.specialty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Location and rating
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lawyer.location,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      RatingBarIndicator(
                        rating: lawyer.rating,
                        itemBuilder: (context, index) => const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 14,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${lawyer.rating})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  if (!isCompact) ...[
                    const SizedBox(height: 12),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Cases Won',
                            '${lawyer.casesWon}+',
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Experience',
                            '${lawyer.experienceYears} years',
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            'Rate',
                            '\$${lawyer.pricePerHour.toInt()}/hr',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}