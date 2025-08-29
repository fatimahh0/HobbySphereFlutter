// ===== Flutter 3.35.x =====
// CardActivityBusiness — public shell that composes internal parts.

import 'package:flutter/material.dart';
import 'card_activity_utils.dart';
import '_banner.dart';
import '_title_subtitle.dart';
import '_meta_wrap.dart';
import '_status_price_row.dart';
import '_actions_row.dart';
import '_reopen_button.dart';

class CardActivityBusiness extends StatelessWidget {
  const CardActivityBusiness({
    super.key,
    required this.id,
    required this.title,
    required this.participants,
    required this.price,
    required this.currency,
    required this.status,
    this.startDate,
    this.imageUrl,
    this.subtitle,
    this.serverRoot,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onReopen,
    this.participantsLabel,
  });

  // -------- required --------
  final String id, title, currency, status;
  final int participants;
  final double price;

  // -------- optional --------
  final DateTime? startDate;
  final String? imageUrl, subtitle, serverRoot, participantsLabel;
  final VoidCallback? onView, onEdit, onDelete, onReopen;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final img = resolveImage(serverRoot, imageUrl);
    final sym = currencySymbol(currency);
    final chipColor = statusColor(context, status);

    return Container(
      decoration: cardDecoration(cs),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardBanner(imageUrl: img, onTap: onView),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleSubtitle(title: title, subtitle: subtitle),
                const SizedBox(height: 4),
                MetaWrap(
                  date: startDate,
                  participants: participants,
                  participantsLabel: participantsLabel ?? 'Participants',
                ),
                const SizedBox(height: 8),
                StatusPriceRow(
                  status: status,
                  chipColor: chipColor,
                  price: '$sym ${fmtPrice(price)}',
                  priceTextStyle: tt.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ActionsRow(
                  onView: onView,
                  onEdit: onEdit,
                  onDelete: onDelete,
                  deleteColor: cs.error,
                ),
                if (status.toLowerCase() == 'terminated' &&
                    onReopen != null) ...[
                  const SizedBox(height: 6),
                  ReopenButton(onReopen: onReopen!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
