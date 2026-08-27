// lib/screens/alerts/alerts_screen.dart

import 'package:disaster_app_ui/widgets/%20bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/colors.dart';
import '../../../widgets/text_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../services/disaster_alert_service.dart';
import '../../../models/disaster_alert_model.dart';
import '../../../widgets/app_scaffold.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({
    super.key,
  });

  @override
  State<AlertScreen> createState() =>
      _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen>
    with SingleTickerProviderStateMixin {
  final DisasterAlertService _alertService =
      DisasterAlertService();

  DisasterAlertSnapshot? _snapshot;

  String? _error;

  bool _loading = true;

  late final AnimationController
      _shimmerController;

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _shimmerController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 1200,
      ),
    )..repeat();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        _loadAlerts();
      },
    );
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    _shimmerController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD
  // ==========================================================================

  Future<void> _loadAlerts() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final snapshot =
          await _alertService
              .fetchAlertSnapshot();

      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        _loading = false;
      });
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppScaffold(
      title: null,
      subtitle: null,
      scroll: true,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      bottomNavigationBar:
          const BottomNavBar(
        currentIndex: 2,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 4,
          ),

          _pageHeader(),

          const SizedBox(
            height: 22,
          ),

          _buildContent(),

          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _pageHeader() {
    return SizedBox(
      width: double.infinity,

      child: Stack(
        alignment:
            Alignment.center,
        children: [
          const Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: 58,
            ),

            child: Column(
              children: [
                TextWidget(
                  'Disaster Alerts',
                  size: 27,
                  weight:
                      FontWeight.w800,
                  color:
                      AppColor.text,
                  align:
                      TextAlign.center,
                ),

                SizedBox(
                  height: 5,
                ),

                TextWidget(
                  'Live warnings and recent updates',
                  size: 12.5,
                  color:
                      AppColor.textMuted,
                  align:
                      TextAlign.center,
                ),
              ],
            ),
          ),

          Positioned(
            right: 0,

            child: Material(
              color:
                  Colors.transparent,

              child: InkWell(
                onTap:
                    _loading
                        ? null
                        : _loadAlerts,

                borderRadius:
                    BorderRadius.circular(
                  15,
                ),

                child: Container(
                  width: 46,
                  height: 46,

                  decoration:
                      BoxDecoration(
                    color:
                        AppColor.surface,

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),

                    border:
                        Border.all(
                      color:
                          AppColor.border,
                    ),
                  ),

                  alignment:
                      Alignment.center,

                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.2,
                            color:
                                AppColor.primary,
                          ),
                        )
                      : const Icon(
                          Icons
                              .refresh_rounded,
                          color:
                              AppColor.primary,
                          size: 23,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CONTENT
  // ==========================================================================

  Widget _buildContent() {
    if (_error != null) {
      return _errorView(
        _error!,
      );
    }

    if (_loading &&
        _snapshot == null) {
      return _initialLoading();
    }

    final snapshot =
        _snapshot;

    if (snapshot == null) {
      return _errorView(
        'Alert information is unavailable.',
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // ====================================================================
        // LOCATION / SOURCE STATUS
        // ====================================================================

        _liveStatusCard(
          snapshot,
        ),

        if ((snapshot.partialWarning ??
                '')
            .trim()
            .isNotEmpty) ...[
          const SizedBox(
            height: 12,
          ),

          _partialWarning(
            snapshot.partialWarning!,
          ),
        ],

        const SizedBox(
          height: 20,
        ),

        // ====================================================================
        // OVERVIEW
        // ====================================================================

        _overview(
          nearby:
              snapshot
                  .nearbyAlerts
                  .length,

          pakistan:
              snapshot
                  .pakistanCurrentAlerts
                  .length,

          recent:
              snapshot
                  .recentPakistanAlerts
                  .length,
        ),

        const SizedBox(
          height: 24,
        ),

        // ====================================================================
        // NEAR YOU
        // ====================================================================

        _feedPanel(
          title:
              'Near You',

          subtitle:
              snapshot.locationAvailable
                  ? 'Within ${DisasterAlertService.nearbyRadiusKm} km • last 24 hours'
                  : 'Location required for local monitoring',

          icon:
              Icons.my_location_rounded,

          accent:
              AppColor.danger,

          alerts:
              snapshot.nearbyAlerts,

          dataAvailable:
              snapshot.locationAvailable &&
                  snapshot
                      .nearbySourceAvailable,

          emptyTitle:
              'No Nearby Alerts',

          emptySubtitle:
              'No earthquake activity was returned near your location in the last 24 hours.',

          unavailableTitle:
              'Local Monitoring Unavailable',

          unavailableSubtitle:
              snapshot.locationMessage,
        ),

        const SizedBox(
          height: 18,
        ),

        // ====================================================================
        // PAKISTAN CURRENT
        // ====================================================================

        _feedPanel(
          title:
              'Across Pakistan',

          subtitle:
              'Current warnings • last 24 hours',

          icon:
              Icons.cell_tower_rounded,

          accent:
              AppColor.primary,

          alerts:
              snapshot
                  .pakistanCurrentAlerts,

          dataAvailable:
              snapshot
                  .pakistanDataAvailable,

          emptyTitle:
              'No Current Alerts',

          emptySubtitle:
              'Connected sources returned no active disaster events for Pakistan in the last 24 hours.',

          unavailableTitle:
              'Pakistan Feed Unavailable',

          unavailableSubtitle:
              'Current Pakistan alert sources could not be reached.',
        ),

        const SizedBox(
          height: 18,
        ),

        // ====================================================================
        // RECENT
        // ====================================================================

        _feedPanel(
          title:
              'Recent Updates',

          subtitle:
              'Previous events • last 30 days',

          icon:
              Icons.history_rounded,

          accent:
              AppColor.info,

          alerts:
              snapshot
                  .recentPakistanAlerts,

          dataAvailable:
              snapshot
                  .pakistanDataAvailable,

          emptyTitle:
              'No Recent Events',

          emptySubtitle:
              'Connected sources returned no previous Pakistan disaster events in the recent monitoring window.',

          unavailableTitle:
              'Recent Feed Unavailable',

          unavailableSubtitle:
              'Historical Pakistan alert information could not be loaded.',
        ),

        const SizedBox(
          height: 10,
        ),

        // ====================================================================
        // LAST UPDATED
        // ====================================================================

        _lastUpdated(
          snapshot,
        ),
      ],
    );
  }

  // ==========================================================================
  // LIVE STATUS
  // ==========================================================================

  Widget _liveStatusCard(
    DisasterAlertSnapshot snapshot,
  ) {
    final hasLocation =
        snapshot.locationAvailable &&
            snapshot.userLocation !=
                null;

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        15,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColor.surface,

        borderRadius:
            BorderRadius.circular(
          19,
        ),

        border:
            Border.all(
          color:
              AppColor.border,
        ),

        boxShadow: [
          BoxShadow(
            color:
                AppColor.shadow,
            blurRadius:
                14,
            offset:
                const Offset(
              0,
              7,
            ),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,

            decoration:
                BoxDecoration(
              color: hasLocation
                  ? AppColor.safeSoft
                  : AppColor.warningSoft,

              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            child: Icon(
              hasLocation
                  ? Icons
                      .location_on_rounded
                  : Icons
                      .location_off_rounded,

              color: hasLocation
                  ? AppColor.safeGreen
                  : AppColor.warning,

              size: 22,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                TextWidget(
                  hasLocation
                      ? 'Location monitoring active'
                      : 'Location monitoring unavailable',

                  size: 13.5,

                  weight:
                      FontWeight.w800,

                  color:
                      AppColor.text,
                ),

                const SizedBox(
                  height: 3,
                ),

                if (hasLocation)
                  TextWidget(
                    '${snapshot.userLocation!.latitude.toStringAsFixed(4)}, '
                    '${snapshot.userLocation!.longitude.toStringAsFixed(4)}',

                    size: 11,

                    color:
                        AppColor.textMuted,
                  )
                else
                  TextWidget(
                    snapshot
                        .locationMessage,

                    size: 11,

                    color:
                        AppColor.textMuted,
                  ),
              ],
            ),
          ),

          _sourceDot(
            available:
                snapshot
                    .usgsPakistanAvailable,
            label:
                'USGS',
          ),

          const SizedBox(
            width: 7,
          ),

          _sourceDot(
            available:
                snapshot
                    .gdacsAvailable,
            label:
                'GDACS',
          ),
        ],
      ),
    );
  }

  Widget _sourceDot({
    required bool available,
    required String label,
  }) {
    return Tooltip(
      message:
          '$label ${available ? 'online' : 'unavailable'}',

      child: Container(
        width: 9,
        height: 9,

        decoration:
            BoxDecoration(
          color: available
              ? AppColor.safeGreen
              : AppColor.warning,

          shape:
              BoxShape.circle,
        ),
      ),
    );
  }

  // ==========================================================================
  // PARTIAL WARNING
  // ==========================================================================

  Widget _partialWarning(
    String message,
  ) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColor.warningSoft,

        borderRadius:
            BorderRadius.circular(
          16,
        ),

        border:
            Border.all(
          color: AppColor.warning
              .withOpacity(
            0.20,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons
                .sync_problem_rounded,
            color:
                AppColor.warning,
            size: 19,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: TextWidget(
              message,
              size: 11.5,
              weight:
                  FontWeight.w600,
              color:
                  AppColor.text,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // OVERVIEW
  // ==========================================================================

  Widget _overview({
    required int nearby,
    required int pakistan,
    required int recent,
  }) {
    return Row(
      children: [
        Expanded(
          child:
              _overviewItem(
            icon:
                Icons.near_me_rounded,

            value:
                nearby,

            label:
                'Nearby',

            color: nearby > 0
                ? AppColor.danger
                : AppColor.safeGreen,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child:
              _overviewItem(
            icon:
                Icons.cell_tower_rounded,

            value:
                pakistan,

            label:
                'Pakistan',

            color: pakistan > 0
                ? AppColor.warning
                : AppColor.primary,
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child:
              _overviewItem(
            icon:
                Icons.history_rounded,

            value:
                recent,

            label:
                'Recent',

            color:
                AppColor.info,
          ),
        ),
      ],
    );
  }

  Widget _overviewItem({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 14,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColor.surface,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              AppColor.border,
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration:
                BoxDecoration(
              color: color
                  .withOpacity(
                0.10,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              icon,
              size: 19,
              color: color,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          TextWidget(
            value.toString(),

            size: 18,

            weight:
                FontWeight.w900,

            color:
                AppColor.text,
          ),

          const SizedBox(
            height: 2,
          ),

          TextWidget(
            label,

            size: 10.5,

            weight:
                FontWeight.w600,

            color:
                AppColor.textMuted,

            align:
                TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PANEL
  // ==========================================================================

  Widget _feedPanel({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required List<DisasterAlert> alerts,
    required bool dataAvailable,
    required String emptyTitle,
    required String emptySubtitle,
    required String unavailableTitle,
    required String unavailableSubtitle,
  }) {
    return Container(
      width:
          double.infinity,

      decoration:
          BoxDecoration(
        color:
            AppColor.surface,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border:
            Border.all(
          color:
              AppColor.border,
        ),

        boxShadow: [
          BoxShadow(
            color:
                AppColor.shadow,
            blurRadius:
                16,
            offset:
                const Offset(
              0,
              8,
            ),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              18,
            ),

            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,

                  decoration:
                      BoxDecoration(
                    color: accent
                        .withOpacity(
                      0.10,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),

                  child: Icon(
                    icon,
                    size: 22,
                    color:
                        accent,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        title,
                        size: 16,
                        weight:
                            FontWeight.w900,
                        color:
                            AppColor.text,
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      TextWidget(
                        subtitle,
                        size: 11,
                        color:
                            AppColor.textMuted,
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),

                  decoration:
                      BoxDecoration(
                    color: accent
                        .withOpacity(
                      0.08,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      999,
                    ),
                  ),

                  child: TextWidget(
                    alerts.length
                        .toString(),

                    size: 11,

                    weight:
                        FontWeight.w800,

                    color:
                        accent,
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 1,
            color:
                AppColor.border,
          ),

          if (!dataAvailable)
            _emptyPanel(
              title:
                  unavailableTitle,

              subtitle:
                  unavailableSubtitle,

              icon:
                  Icons.cloud_off_rounded,

              color:
                  AppColor.warning,
            )
          else if (alerts.isEmpty)
            _emptyPanel(
              title:
                  emptyTitle,

              subtitle:
                  emptySubtitle,

              icon:
                  Icons
                      .verified_user_outlined,

              color:
                  AppColor.safeGreen,
            )
          else
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                5,
                18,
                7,
              ),

              child: Column(
                children:
                    List.generate(
                  alerts.length,
                  (index) =>
                      _alertRow(
                    alert:
                        alerts[index],

                    isLast: index ==
                        alerts.length -
                            1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ALERT ROW
  // ==========================================================================

  Widget _alertRow({
    required DisasterAlert alert,
    required bool isLast,
  }) {
    final severityColor =
        _severityColor(
      alert.severity,
    );

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 15,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,

                decoration:
                    BoxDecoration(
                  color: severityColor
                      .withOpacity(
                    0.10,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                child: Icon(
                  _alertIcon(
                    alert.title,
                  ),

                  color:
                      severityColor,

                  size: 21,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child:
                              TextWidget(
                            alert.title,

                            size: 14.5,

                            weight:
                                FontWeight.w900,

                            color:
                                AppColor.text,
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        _severityBadge(
                          alert.severity,
                          severityColor,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    TextWidget(
                      alert.summary,

                      size: 12,

                      color:
                          AppColor.textMuted,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _metaChip(
                          icon:
                              Icons.public_rounded,

                          text:
                              alert.source,

                          color:
                              AppColor.primary,
                        ),

                        if (alert.magnitude !=
                            null)
                          _metaChip(
                            icon:
                                Icons.graphic_eq_rounded,

                            text:
                                'M ${alert.magnitude!.toStringAsFixed(1)}',

                            color:
                                severityColor,
                          ),

                        _metaChip(
                          icon:
                              Icons.schedule_rounded,

                          text:
                              _timeAgo(
                            alert.publishedAt,
                          ),

                          color:
                              AppColor.textMuted,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 7,
                    ),

                    TextWidget(
                      DateFormat(
                        'd MMM yyyy • h:mm a',
                      ).format(
                        alert
                            .publishedAt
                            .toLocal(),
                      ),

                      size: 10,

                      color:
                          AppColor.textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!isLast) ...[
            const SizedBox(
              height: 15,
            ),

            Container(
              height: 1,
              color:
                  AppColor.border,
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // EMPTY PANEL
  // ==========================================================================

  Widget _emptyPanel({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding:
          const EdgeInsets.all(
        18,
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration:
                BoxDecoration(
              color: color
                  .withOpacity(
                0.10,
              ),

              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child: Icon(
              icon,
              color:
                  color,
              size: 23,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                TextWidget(
                  title,

                  size: 15,

                  weight:
                      FontWeight.w900,

                  color:
                      AppColor.text,
                ),

                const SizedBox(
                  height: 4,
                ),

                TextWidget(
                  subtitle,

                  size: 11.5,

                  color:
                      AppColor.textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BADGES
  // ==========================================================================

  Widget _severityBadge(
    String severity,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),

      decoration:
          BoxDecoration(
        color: color
            .withOpacity(
          0.10,
        ),

        borderRadius:
            BorderRadius.circular(
          99,
        ),
      ),

      child: TextWidget(
        severity,

        size: 9.5,

        weight:
            FontWeight.w800,

        color:
            color,
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColor.inputFill,

        borderRadius:
            BorderRadius.circular(
          10,
        ),
      ),

      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color:
                color,
          ),

          const SizedBox(
            width: 5,
          ),

          TextWidget(
            text,
            size: 9.5,
            weight:
                FontWeight.w700,
            color:
                AppColor.textMuted,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // LAST UPDATED
  // ==========================================================================

  Widget _lastUpdated(
    DisasterAlertSnapshot snapshot,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 14,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons
                .verified_outlined,
            color:
                AppColor.textMuted,
            size: 14,
          ),

          const SizedBox(
            width: 6,
          ),

          TextWidget(
            'Live sources checked ${DateFormat('h:mm a').format(snapshot.fetchedAt)}',

            size: 10,

            color:
                AppColor.textMuted,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INITIAL LOADING
  // ==========================================================================

  Widget _initialLoading() {
    return Column(
      children:
          List.generate(
        3,
        (_) =>
            _shimmerCard(),
      ),
    );
  }

  Widget _shimmerCard() {
    return AnimatedBuilder(
      animation:
          _shimmerController,

      builder:
          (_, __) {
        return Container(
          width:
              double.infinity,

          height: 150,

          margin:
              const EdgeInsets.only(
            bottom: 14,
          ),

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              22,
            ),

            gradient:
                LinearGradient(
              begin: Alignment(
                -1 +
                    _shimmerController
                            .value *
                        2,
                0,
              ),

              end: Alignment(
                1 +
                    _shimmerController
                            .value *
                        2,
                0,
              ),

              colors: [
                Colors
                    .grey.shade200,
                Colors
                    .grey.shade100,
                Colors
                    .grey.shade200,
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // ERROR
  // ==========================================================================

  Widget _errorView(
    String error,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 34,
      ),

      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,

            decoration:
                BoxDecoration(
              color:
                  AppColor.dangerSoft,

              borderRadius:
                  BorderRadius.circular(
                23,
              ),
            ),

            child: const Icon(
              Icons.cloud_off_rounded,

              size: 34,

              color:
                  AppColor.danger,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          const TextWidget(
            'Unable to update alerts',

            size: 17,

            weight:
                FontWeight.w900,

            color:
                AppColor.text,
          ),

          const SizedBox(
            height: 6,
          ),

          TextWidget(
            error,

            size: 11.5,

            color:
                AppColor.textMuted,

            align:
                TextAlign.center,
          ),

          const SizedBox(
            height: 18,
          ),

          CustomButton(
            title:
                'Retry',

            onTap:
                _loadAlerts,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ICON
  // ==========================================================================

  IconData _alertIcon(
    String title,
  ) {
    final text =
        title.toLowerCase();

    if (text.contains(
      'earthquake',
    )) {
      return Icons
          .vibration_rounded;
    }

    if (text.contains(
      'flood',
    )) {
      return Icons
          .flood_rounded;
    }

    if (text.contains(
      'cyclone',
    )) {
      return Icons
          .cyclone_rounded;
    }

    if (text.contains(
      'storm',
    )) {
      return Icons
          .thunderstorm_rounded;
    }

    if (text.contains(
      'drought',
    )) {
      return Icons
          .wb_sunny_rounded;
    }

    if (text.contains(
      'fire',
    )) {
      return Icons
          .local_fire_department_rounded;
    }

    return Icons
        .crisis_alert_rounded;
  }

  // ==========================================================================
  // SEVERITY
  // ==========================================================================

  Color _severityColor(
    String severity,
  ) {
    switch (
        severity.toLowerCase()) {
      case 'severe':
        return AppColor.danger;

      case 'high':
        return const Color(
          0xFFE97838,
        );

      case 'moderate':
        return AppColor.warning;

      default:
        return AppColor.safeGreen;
    }
  }

  // ==========================================================================
  // TIME AGO
  // ==========================================================================

  String _timeAgo(
    DateTime date,
  ) {
    final difference =
        DateTime.now()
            .difference(
      date.toLocal(),
    );

    if (difference.isNegative ||
        difference.inMinutes <
            1) {
      return 'Now';
    }

    if (difference.inMinutes <
        60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours <
        24) {
      return '${difference.inHours}h ago';
    }

    return '${difference.inDays}d ago';
  }
}