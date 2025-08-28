// Flutter 3.35.x
import 'package:flutter/material.dart'; // core UI
import 'package:hobby_sphere/core/services/business_activity_service.dart';
import 'package:hobby_sphere/core/services/currency_service.dart';
import 'package:intl/intl.dart'; // date/number formatting
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // L10n strings
import 'package:hobby_sphere/core/network/api_config.dart'; // baseUrl from hostIp.json (already loaded at app start)

// keep JSON flexible like the RN item
typedef Json = Map<String, dynamic>; // simple alias

class CardActivityBusiness extends StatefulWidget {
  final Json item; // activity data from backend
  final String token; // JWT token for calls

  // optional callbacks so parent can navigate/refresh (clean separation)
  final void Function(Json activity)? onOpenDetails; // open details screen
  final void Function(Json activity)? onOpenEdit; // open edit screen
  final void Function(Json activity)?
  onOpenReopen; // open create in "reopen" mode
  final VoidCallback? onDeleted; // after delete hook

  const CardActivityBusiness({
    super.key, // widget key
    required this.item, // activity json
    required this.token, // auth token
    this.onOpenDetails, // parent nav
    this.onOpenEdit,
    this.onOpenReopen,
    this.onDeleted, // parent refresh
  });

  @override
  State<CardActivityBusiness> createState() => _CardActivityBusinessState(); // state
}

class _CardActivityBusinessState extends State<CardActivityBusiness> {
  // services (reuse shared Dio inside ApiFetch)
  final _currencyService = CurrencyService(); // currency backend
  final _activityService = BusinessActivityService(); // activity backend

  // ui state for delete modal
  bool _modalVisible = false; // show/hide confirm modal
  bool _isDeleting = false; // show deleting state

  // currency code (CAD / DOLLAR / EURO...)
  String _currency = 'CAD'; // default until loaded

  @override
  void initState() {
    super.initState(); // base init
    _loadCurrency(); // fetch currency once
  }

  // build server root from ApiConfig.baseUrl (drop trailing "/api")
  String _serverRoot() {
    // read base url (e.g., http://3.96.140.126:8080/api)
    final base = ApiConfig.baseUrl; // configured at startup
    // remove trailing /api or /api/
    return base.replaceFirst(
      RegExp(r'/api/?$'),
      '',
    ); // -> http://3.96.140.126:8080
  }

  // return full absolute url for any relative image path
  String _fullUrl(String? raw) {
    // if null/empty -> empty
    if (raw == null || raw.isEmpty) return ''; // no image
    // if already absolute -> keep it
    if (raw.startsWith('http')) return raw; // absolute
    // else prefix with server root and ensure single slash
    final root = _serverRoot().replaceAll(
      RegExp(r'/$'),
      '',
    ); // no trailing slash
    final path = raw.startsWith('/') ? raw : '/$raw'; // ensure leading slash
    return '$root$path'; // full url
  }

  // fetch currency code from backend and store it
  Future<void> _loadCurrency() async {
    try {
      // ask backend for current currency code (normalized)
      final code = await _currencyService.getCurrentCurrencyCode(
        widget.token,
      ); // e.g., "CAD"
      if (!mounted) return; // guard
      setState(() => _currency = code); // save
    } catch (_) {
      // keep default on failure
    }
  }

  // small map: code -> symbol (same as RN)
  String _symbol(String code) {
    // normalize to uppercase
    switch (code.toUpperCase()) {
      case 'DOLLAR':
        return r'$'; // dollar
      case 'EURO':
        return '€'; // euro
      case 'CAD':
        return 'C\$'; // canadian dollar
      default:
        return code; // fallback: show the code
    }
  }

  // choose chip color by status (match RN)
  Color _statusColor(ColorScheme scheme, String? status) {
    // safe lowercase
    final s = (status ?? '').toLowerCase(); // normalize
    if (s == 'upcoming') return scheme.primary; // primary
    if (s == 'terminated') return scheme.error; // error
    return const Color(0xFF9CA3AF); // gray
  }

  // details: fetch latest and forward to parent
  Future<void> _handleDetails() async {
    try {
      // read id from item
      final id = widget.item['id']; // id
      if (id == null) return; // guard
      // get fresh activity by id
      final activity = await _activityService.getBusinessActivityById(
        widget.token,
        id,
      ); // GET
      // call parent navigation if provided
      widget.onOpenDetails?.call(activity); // navigate
    } catch (_) {
      // ignore errors (keep card stable)
    }
  }

  // edit: fetch latest and forward to parent
  Future<void> _handleEdit() async {
    try {
      final id = widget.item['id']; // id
      if (id == null) return; // guard
      final activity = await _activityService.getBusinessActivityById(
        widget.token,
        id,
      ); // GET
      widget.onOpenEdit?.call(activity); // navigate to edit
    } catch (_) {
      // ignore
    }
  }

  // reopen: fetch latest and forward with mode "reopen"
  Future<void> _handleReopen() async {
    try {
      final id = widget.item['id']; // id
      if (id == null) return; // guard
      final activity = await _activityService.getBusinessActivityById(
        widget.token,
        id,
      ); // GET
      widget.onOpenReopen?.call(activity); // navigate to reopen flow
    } catch (_) {
      // ignore
    }
  }

  // delete: call backend, close modal, notify parent to refresh
  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true); // start loading
    try {
      final id = widget.item['id']; // id
      if (id == null) return; // guard
      await _activityService.deleteBusinessActivity(widget.token, id); // DELETE
      if (!mounted) return; // guard
      setState(() => _modalVisible = false); // close modal
      widget.onDeleted?.call(); // tell parent to refresh list
    } catch (_) {
      // ignore or plug a snackbar/toast
    } finally {
      if (mounted) setState(() => _isDeleting = false); // stop loading
    }
  }

  @override
  Widget build(BuildContext context) {
    // theme + texts
    final scheme = Theme.of(context).colorScheme; // colors
    final text = Theme.of(context).textTheme; // text styles
    final t = AppLocalizations.of(context)!; // L10n

    // guard item id like RN
    if (widget.item['id'] == null) return const SizedBox.shrink(); // nothing

    // image (absolute if needed)
    final fullImageUrl = _fullUrl(
      widget.item['imageUrl']?.toString(),
    ); // full url
    // main fields
    final itemName = widget.item['itemName']?.toString() ?? 'Unnamed'; // title
    final status = widget.item['status']?.toString(); // status text
    final maxParticipants = widget.item['maxParticipants'] ?? 0; // count
    final price = (widget.item['price'] is num)
        ? (widget.item['price'] as num).toDouble()
        : 0.0; // price

    // start date (string or millis)
    final DateTime? start = switch (widget.item['startDatetime']) {
      null => null, // none
      final s when s is String => DateTime.tryParse(s), // parse ISO
      final n when n is num => DateTime.fromMillisecondsSinceEpoch(
        n.toInt(),
      ), // unix ms
      _ => null, // other
    };

    // format date or show N/A (like RN)
    final dateText = start != null
        ? DateFormat.yMd().format(start)
        : 'N/A'; // e.g., 8/28/2025
    // currency symbol + formatted price
    final symbol = _symbol(_currency); // e.g., C$
    final priceText = NumberFormat('#,##0.##').format(price); // 1,234.5

    return Container(
      width: double.infinity, // full width
      decoration: BoxDecoration(
        color: scheme.surface, // card background
        borderRadius: BorderRadius.circular(16), // rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06), // soft shadow
            blurRadius: 12, // blur
            offset: const Offset(0, 6), // drop
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // clip children to radius
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // stretch
        children: [
          // tap image -> details
          InkWell(
            onTap: _handleDetails, // open details
            child: SizedBox(
              height: 90, // same as RN
              child: fullImageUrl.isNotEmpty
                  ? Image.network(
                      fullImageUrl, // url
                      fit: BoxFit.cover, // cover
                      errorBuilder: (_, __, ___) =>
                          const _ImagePlaceholder(), // fallback
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child; // done
                        return const _ImageLoading(); // simple loader
                      },
                    )
                  : const _ImagePlaceholder(), // no image -> placeholder
            ),
          ),

          // content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ), // inner spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // left align
              children: [
                // title text
                Text(
                  itemName, // activity name
                  maxLines: 1, // one line
                  overflow: TextOverflow.ellipsis, // ellipsis
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, // bold
                    color: scheme.onSurface, // color
                  ),
                ),

                const SizedBox(height: 4), // small gap
                // calendar icon + start date
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ), // icon
                    const SizedBox(width: 6), // gap
                    Text(
                      dateText, // date or N/A
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.6),
                      ), // muted
                    ),
                  ],
                ),

                const SizedBox(height: 6), // small gap
                // people icon + participants
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ), // icon
                    const SizedBox(width: 6), // gap
                    Text(
                      '$maxParticipants ${t.activityDetailsParticipants}', // "X Participants"
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurface.withOpacity(0.6),
                      ), // muted
                    ),
                  ],
                ),

                const SizedBox(height: 8), // gap
                // price + action icons
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // space between
                  children: [
                    // price text (primary color)
                    Text(
                      '$symbol $priceText', // e.g., C$ 25
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, // bold
                        color: scheme.primary, // primary
                      ),
                    ),

                    // edit + delete icons
                    Row(
                      children: [
                        // edit
                        IconButton(
                          onPressed: _handleEdit, // open edit
                          icon: Icon(
                            Icons.edit,
                            size: 18,
                            color: scheme.primary,
                          ), // icon
                          tooltip: t.activityDetailsEdit, // a11y
                        ),
                        // delete (open modal)
                        IconButton(
                          onPressed: () => setState(
                            () => _modalVisible = true,
                          ), // show modal
                          icon: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: scheme.error,
                          ), // icon
                          tooltip: t.buttonDelete, // a11y
                        ),
                      ],
                    ),
                  ],
                ),

                // status chip + reopen button
                Padding(
                  padding: const EdgeInsets.only(top: 8), // space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // left
                    children: [
                      // colored status chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ), // chip padding
                        decoration: BoxDecoration(
                          color: _statusColor(
                            scheme,
                            status,
                          ), // color by status
                          borderRadius: BorderRadius.circular(14), // round
                        ),
                        child: Text(
                          // show L10n value for known statuses or capitalize raw
                          switch ((status ?? '').toLowerCase()) {
                            'upcoming' => t.activitiesFiltersUpcoming, // L10n
                            'terminated' =>
                              t.activitiesFiltersTerminated, // L10n
                            final s =>
                              s
                                      .isNotEmpty // else capitalize
                                  ? '${s[0].toUpperCase()}${s.substring(1)}'
                                  : '—',
                          },
                          style: text.labelSmall?.copyWith(
                            color: Colors.white, // white text
                            fontWeight: FontWeight.bold, // bold
                          ),
                        ),
                      ),

                      // "Reopen Activity" when terminated
                      if ((status ?? '').toLowerCase() == 'terminated')
                        Padding(
                          padding: const EdgeInsets.only(top: 8), // gap
                          child: ElevatedButton(
                            onPressed: _handleReopen, // reopen flow
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary, // primary
                              foregroundColor: scheme.onPrimary, // text
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ), // padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ), // radius
                              textStyle: text.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ), // semi-bold
                            ),
                            child: Text(t.activitiesReopen), // L10n text
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // confirm delete modal (RN Modal equivalent)
          if (_modalVisible)
            _DeleteConfirmModal(
              title: t
                  .ticketCancelTitle, // using your L10n key "ticketCancelTitle"
              message: t
                  .ticketCancelConfirm, // using your L10n key "ticketCancelConfirm"
              cancelText: t.ticketCancel, // "Cancel"
              confirmText: _isDeleting
                  ? t.editBusinessDeleting
                  : t.ticketConfirm, // "Deleting..." or "Confirm"
              onCancel: () => setState(() => _modalVisible = false), // close
              onConfirm: _isDeleting
                  ? null
                  : _handleDelete, // run delete if not busy
            ),
        ],
      ),
    );
  }
}

// image placeholder (gray box with icon)
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder(); // const ctor

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB), // gray background
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined),
      ), // icon
    );
  }
}

// simple loading placeholder (light gray)
class _ImageLoading extends StatelessWidget {
  const _ImageLoading(); // const ctor

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFF1F5F9)); // lighter gray
  }
}

// modal card that mimics RN <Modal/> overlay
class _DeleteConfirmModal extends StatelessWidget {
  final String title; // dialog title
  final String message; // dialog message
  final String cancelText; // cancel label
  final String confirmText; // confirm label
  final VoidCallback? onCancel; // cancel handler
  final VoidCallback? onConfirm; // confirm handler

  const _DeleteConfirmModal({
    required this.title, // title text
    required this.message, // message text
    required this.cancelText, // cancel label
    required this.confirmText, // confirm label
    this.onCancel, // cancel handler
    this.onConfirm, // confirm handler
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme; // theme colors

    return Stack(
      children: [
        // dim backdrop (tap to close)
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel, // close on backdrop tap
            child: Container(color: Colors.black54), // semi-transparent black
          ),
        ),
        // centered dialog
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // 80% width
            padding: const EdgeInsets.all(24), // inner padding
            decoration: BoxDecoration(
              color: scheme.surface, // card background
              borderRadius: BorderRadius.circular(16), // rounded
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // soft shadow
                  blurRadius: 16, // blur
                  offset: const Offset(0, 6), // drop
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // wrap content
              children: [
                // title
                Text(
                  title, // title text
                  textAlign: TextAlign.center, // center
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold, // bold
                    color: scheme.onSurface, // text color
                  ),
                ),
                const SizedBox(height: 12), // space
                // message
                Text(
                  message, // message text
                  textAlign: TextAlign.center, // center
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.7), // muted
                  ),
                ),
                const SizedBox(height: 18), // space
                // buttons row
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // even spacing
                  children: [
                    // cancel button
                    TextButton(
                      onPressed: onCancel, // close
                      child: Text(
                        cancelText,
                        style: TextStyle(color: scheme.primary),
                      ), // label
                    ),
                    // confirm button
                    TextButton(
                      onPressed: onConfirm, // delete
                      child: Text(
                        confirmText,
                        style: TextStyle(color: scheme.error),
                      ), // label
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
