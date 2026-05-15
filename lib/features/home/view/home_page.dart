import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../add_medicine/view/add_medicine_page.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../widgets/medicine_card.dart';
import '../widgets/profile_header.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/medicine_model.dart';
import 'package:daily_dose/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with WidgetsBindingObserver {
  DateTime selectedDate = DateTime.now();
  Set<String> selectedCardKeys = {};
  Timer? _refreshTimer;
  late final ScrollController _scrollController;

  // ValueNotifier instead of a plain field: the scroll listener updates this
  // without calling setState(), so only ProfileHeader (wrapped in a
  // ValueListenableBuilder) rebuilds on each scroll tick, not the entire page.
  final ValueNotifier<double> _collapseNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final raw = (_scrollController.offset / 80.0).clamp(0.0, 1.0);
      final progress = (raw * 100).round() / 100;
      if (progress != _collapseNotifier.value) {
        _collapseNotifier.value = progress;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadMedicines();
    });

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _scrollController.dispose();
    _collapseNotifier.dispose();
    super.dispose();
  }

  void _clearSelection() {
    setState(() => selectedCardKeys.clear());
  }

  void navigateToAddMedicine() {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded && profileState.selectedProfileId != null) {
      final profileName = profileState.profiles
          .firstWhere((p) => p.id == profileState.selectedProfileId)
          .name;
      Navigator.of(context)
          .push(MaterialPageRoute(
            builder: (_) => AddMedicinePage(
              profileId: profileState.selectedProfileId!,
              profileName: profileName,
            ),
          ))
          .then((_) => _loadMedicines());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.pleaseSelectProfileFirst),
      ));
    }
  }

  void showAdvancedDeleteOptions() {
    final profileState = context.read<ProfileCubit>().state;
    final homeState = context.read<HomeCubit>().state;
    if (profileState is ProfileLoaded &&
        profileState.selectedProfileId != null &&
        homeState is HomeLoaded) {
      _showAdvancedDeleteOptions(
          context, profileState.selectedProfileId!, homeState);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.pleaseSelectProfileOrWait),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectionMode = selectedCardKeys.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSelectionMode
              ? AppLocalizations.of(context)!
                  .selectedCount(selectedCardKeys.length)
              : AppLocalizations.of(context)!.appTitle,
        ),
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              )
            : null,
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDeleteSelected(context),
                ),
              ]
            : const [],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded && state.selectedProfileId != null) {
                _loadMedicines();
              }
            },
          ),
        ],
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Only ProfileHeader rebuilds when the scroll position changes —
            // the AppBar, divider, and date-toggle above are unaffected.
            ValueListenableBuilder<double>(
              valueListenable: _collapseNotifier,
              builder: (_, collapseProgress, _) =>
                  ProfileHeader(collapseProgress: collapseProgress),
            ),
            const Divider(),
            _buildDateToggle(),
            // BlocBuilder is scoped to the scrollable list only; static widgets
            // above are never rebuilt when HomeCubit emits a new state.
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) =>
                    _buildScrollContent(context, state, isSelectionMode),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Scroll content — always a CustomScrollView so _scrollController is always
  // attached and AlwaysScrollableScrollPhysics lets the user drag even when the
  // list is empty, keeping the collapsed header accessible.
  // ---------------------------------------------------------------------------

  Widget _buildScrollContent(
    BuildContext context,
    HomeState state,
    bool isSelectionMode,
  ) {
    if (state is HomeLoading) {
      return CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: const [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (state is HomeLoaded && state.medicines.isNotEmpty) {
      return CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverList.builder(
            itemCount: state.medicines.length,
            itemBuilder: (context, index) {
              final medicine = state.medicines[index];
              final cardKey =
                  '${medicine.id}|${medicine.startTime.toIso8601String()}';
              final isSelected = selectedCardKeys.contains(cardKey);
              return MedicineCard(
                medicine: medicine,
                isSelected: isSelected,
                onLongPress: () =>
                    setState(() => selectedCardKeys.add(cardKey)),
                onTap: () {
                  if (isSelectionMode) {
                    setState(() {
                      if (isSelected) {
                        selectedCardKeys.remove(cardKey);
                      } else {
                        selectedCardKeys.add(cardKey);
                      }
                    });
                  } else {
                    _showMedicineDetails(context, medicine);
                  }
                },
                onTaken: () {
                  if (!isSelectionMode) {
                    _showMarkTakenDialog(context, medicine);
                  }
                },
                onUncheck: () {
                  if (!isSelectionMode) {
                    _showUnmarkTakenDialog(context, medicine);
                  }
                },
              );
            },
          ),
          // Guarantees a drag surface below the last card so the user can
          // always pull the collapsed header back into view.
          const SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox.shrink(),
          ),
        ],
      );
    }

    // Empty, error, or awaiting-selection — still scrollable so the collapsed
    // header can always be dragged back into view.
    final Widget centerContent;
    if (state is HomeError) {
      centerContent = Text('Error: ${state.message}');
    } else if (state is HomeLoaded) {
      centerContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.medication_liquid_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noMedicines,
            style: TextStyle(
              color: (Theme.of(context).textTheme.bodyLarge?.color ??
                      Colors.black)
                  .withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      centerContent = Text(AppLocalizations.of(context)!.selectProfile);
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: centerContent),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _confirmDeleteSelected(BuildContext context) {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is! ProfileLoaded ||
        profileState.selectedProfileId == null) {
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.deleteSelectedMedicines),
        content: Text(
          AppLocalizations.of(ctx)!
              .deleteSelectedContent(selectedCardKeys.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.cancel),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<HomeCubit>()
                  .deleteMedicines(selectedCardKeys.toList());
              _clearSelection();
              Navigator.pop(ctx);
            },
            child: Text(
              AppLocalizations.of(ctx)!.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkTakenDialog(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.markTakenTitle),
        content:
            Text(AppLocalizations.of(ctx)!.markTakenContent(medicine.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomeCubit>().markAsTaken(medicine);
            },
            child: Text(
              AppLocalizations.of(ctx)!.confirm,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showUnmarkTakenDialog(BuildContext context, Medicine medicine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.unmarkTakenTitle),
        content:
            Text(AppLocalizations.of(ctx)!.unmarkTakenContent(medicine.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HomeCubit>().unmarkAsTaken(medicine);
            },
            child: Text(
              AppLocalizations.of(ctx)!.confirm,
              style: const TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _showMedicineDetails(
      BuildContext context, Medicine occurrenceMedicine) {
    final medicine = context.read<HomeCubit>().medicineBox.values.firstWhere(
          (m) => m.id == occurrenceMedicine.id,
          orElse: () => occurrenceMedicine,
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final loc = AppLocalizations.of(context)!;
        final dateFormat = DateFormat.yMMMd().add_jm();
        final initialSchedule = medicine.isInterval
            ? medicine.startTime
            : (medicine.fixedTime ?? medicine.startTime);
        final endDate = medicine.durationDays != null
            ? initialSchedule.add(Duration(days: medicine.durationDays!))
            : initialSchedule;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 24.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (medicine.imagePath != null)
                  Center(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12)),
                      child: Image.file(
                        File(medicine.imagePath!),
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  const Center(
                    child: CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.medication, size: 40),
                    ),
                  ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    medicine.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    loc.dosageLabel(medicine.dosage),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                if (medicine.note != null && medicine.note!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      medicine.note!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(loc.startDate),
                  subtitle: Text(dateFormat.format(initialSchedule)),
                ),
                ListTile(
                  leading: const Icon(Icons.event_busy),
                  title: Text(loc.endDate),
                  subtitle: Text(dateFormat.format(endDate)),
                ),
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: Text(loc.frequency),
                  subtitle: Text(
                    medicine.isInterval && medicine.intervalHours != null
                        ? loc.everyXHours(medicine.intervalHours!)
                        : loc.daily,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      final profileState =
                          context.read<ProfileCubit>().state;
                      if (profileState is ProfileLoaded &&
                          profileState.selectedProfileId != null) {
                        final profileName = profileState.profiles
                            .firstWhere(
                                (p) => p.id == profileState.selectedProfileId)
                            .name;
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                              builder: (_) => AddMedicinePage(
                                profileId: profileState.selectedProfileId!,
                                profileName: profileName,
                                medicine: medicine,
                              ),
                            ))
                            .then((_) => _loadMedicines());
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        loc.editMedicineTitle,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAdvancedDeleteOptions(
    BuildContext context,
    String profileId,
    HomeLoaded homeState,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(sheetCtx)!.deletionOptions,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.red),
              title: Text(
                AppLocalizations.of(sheetCtx)!.deleteAllMedicines,
                style: const TextStyle(color: Colors.red),
              ),
              subtitle:
                  Text(AppLocalizations.of(sheetCtx)!.completelyClearProfile),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                // Use the outer page context, not the now-popped sheet context.
                _confirmDeleteAll(context, profileId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome_motion),
              title:
                  Text(AppLocalizations.of(sheetCtx)!.deleteSpecificMedicine),
              subtitle:
                  Text(AppLocalizations.of(sheetCtx)!.chooseMedicineModify),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _showSpecificMedicineSelector(context, homeState);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, String profileId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.deleteAllMedicinesTitle),
        content: Text(AppLocalizations.of(ctx)!.deleteAllMedicinesContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final cubit = context.read<HomeCubit>();
              Navigator.of(ctx).pop();
              cubit.deleteAllMedicines(profileId);
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSpecificMedicineSelector(
    BuildContext context,
    HomeLoaded homeState,
  ) {
    final uniqueMedicines = <String, Medicine>{};
    for (final m in homeState.medicines) {
      uniqueMedicines[m.id] ??= m;
    }

    if (uniqueMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.noActiveMedicines),
      ));
      return;
    }

    final uniqueList = uniqueMedicines.values.toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!.selectMedicineToDelete,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: uniqueList.length,
                itemBuilder: (context, index) {
                  final med = uniqueList[index];
                  return ListTile(
                    title: Text(
                      med.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(med.dosage),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(context);
                      _showRepetitionScopeSelector(
                          context, med.id, med.name);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRepetitionScopeSelector(
    BuildContext context,
    String medicineId,
    String medicineName,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppLocalizations.of(context)!
                    .deleteRepetitionsFor(medicineName),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(AppLocalizations.of(context)!.pastRepetitions),
              subtitle:
                  Text(AppLocalizations.of(context)!.keepFutureHidePast),
              onTap: () {
                context.read<HomeCubit>().updateMedicineScope(
                      medicineId,
                      hideBefore: DateTime.now(),
                    );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: Text(AppLocalizations.of(context)!.futureRepetitions),
              subtitle:
                  Text(AppLocalizations.of(context)!.keepPastStopFuture),
              onTap: () {
                context.read<HomeCubit>().updateMedicineScope(
                      medicineId,
                      hideAfter: DateTime.now(),
                    );
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.delete_forever, color: Colors.red),
              title: Text(
                AppLocalizations.of(context)!.allRepetitions,
                style: const TextStyle(color: Colors.red),
              ),
              subtitle: Text(
                  AppLocalizations.of(context)!.completelyDeleteMedicine),
              onTap: () {
                context.read<HomeCubit>().deleteMedicine(medicineId);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  void _loadMedicines() {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded &&
        profileState.selectedProfileId != null) {
      context.read<HomeCubit>().loadMedicines(
            profileState.selectedProfileId!,
            selectedDate,
          );
    }
  }

  // ---------------------------------------------------------------------------
  // Date-toggle UI
  // ---------------------------------------------------------------------------

  Widget _buildTab({
    required String title,
    required bool isActive,
    required int value,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (value == 0) {
              selectedDate =
                  DateTime.now().subtract(const Duration(days: 1));
            } else if (value == 1) {
              selectedDate = DateTime.now();
            } else {
              selectedDate = DateTime.now().add(const Duration(days: 1));
            }
          });
          _clearSelection();
          _loadMedicines();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isActive
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(20)),
                  boxShadow:
                      Theme.of(context).brightness == Brightness.dark
                          ? null
                          : AppColors.softShadow,
                )
              : const BoxDecoration(color: Colors.transparent),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.outline,
              fontWeight:
                  isActive ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateToggle() {
    final now = DateTime.now();
    final isYesterday = DateUtils.isSameDay(
        selectedDate, now.subtract(const Duration(days: 1)));
    final isToday = DateUtils.isSameDay(selectedDate, now);
    final isTomorrow = DateUtils.isSameDay(
        selectedDate, now.add(const Duration(days: 1)));

    final int selectedSegment;
    if (isYesterday) {
      selectedSegment = 0;
    } else if (isToday) {
      selectedSegment = 1;
    } else if (isTomorrow) {
      selectedSegment = 2;
    } else {
      selectedSegment = -1;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        children: [
          _buildTab(
            title: AppLocalizations.of(context)!.yesterday,
            isActive: selectedSegment == 0,
            value: 0,
          ),
          _buildTab(
            title: AppLocalizations.of(context)!.today,
            isActive: selectedSegment == 1,
            value: 1,
          ),
          _buildTab(
            title: AppLocalizations.of(context)!.tomorrow,
            isActive: selectedSegment == 2,
            value: 2,
          ),
          _buildCalendarTab(isActive: selectedSegment == -1),
        ],
      ),
    );
  }

  Widget _buildCalendarTab({required bool isActive}) {
    return GestureDetector(
      onTap: () {
        showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ).then((date) {
          if (date != null) {
            setState(() => selectedDate = date);
            _clearSelection();
            _loadMedicines();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: isActive
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius:
                    const BorderRadius.all(Radius.circular(20)),
                boxShadow:
                    Theme.of(context).brightness == Brightness.dark
                        ? null
                        : AppColors.softShadow,
              )
            : const BoxDecoration(color: Colors.transparent),
        alignment: Alignment.center,
        child: isActive
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer,
                    size: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      selectedDate.day.toString(),
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              )
            : Icon(
                Icons.calendar_today_outlined,
                color: Theme.of(context).colorScheme.outline,
                size: 24,
              ),
      ),
    );
  }
}
