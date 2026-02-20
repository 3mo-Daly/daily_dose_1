import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../add_medicine/view/add_medicine_page.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../widgets/medicine_card.dart';
import '../widgets/profile_header.dart';
import '../../../core/theme/theme_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  Set<String> selectedCardKeys = {};

  @override
  void initState() {
    super.initState();
    // Initial load will be triggered by BlocListener or manually here if needed
    // But since profile loads async, we rely on listener
  }

  void _clearSelection() {
    setState(() {
      selectedCardKeys.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSelectionMode = selectedCardKeys.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSelectionMode
              ? '${selectedCardKeys.length} Selected'
              : 'The Daily Dose',
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
                  onPressed: () {
                    final profileState = context.read<ProfileCubit>().state;
                    if (profileState is ProfileLoaded &&
                        profileState.selectedProfileId != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Selected Medicines?'),
                          content: Text(
                            'This will permanently delete ${selectedCardKeys.length} medicine(s).',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<HomeCubit>().deleteMedicines(
                                  selectedCardKeys.toList(),
                                );
                                _clearSelection();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ]
            : [
                IconButton(
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  onPressed: () {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    context.read<ThemeCubit>().toggleTheme(isDark);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    // Date picker or toggle
                    showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                        _clearSelection();
                        _loadMedicines();
                      }
                    });
                  },
                ),
              ],
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
            const ProfileHeader(),
            const Divider(),
            _buildDateToggle(),
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HomeLoaded) {
                    if (state.medicines.isEmpty) {
                      return const Center(
                        child: Text('No medicines for this day'),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.medicines.length,
                      itemBuilder: (context, index) {
                        final medicine = state.medicines[index];
                        final cardKey = '${medicine.id}|${medicine.startTime.toIso8601String()}';
                        final isSelected = selectedCardKeys.contains(cardKey);

                        return MedicineCard(
                          medicine: medicine,
                          isSelected: isSelected,
                          onLongPress: () {
                            setState(() {
                              selectedCardKeys.add(cardKey);
                            });
                          },
                          onTap: () {
                            if (isSelectionMode) {
                              setState(() {
                                if (isSelected) {
                                  selectedCardKeys.remove(cardKey);
                                } else {
                                  selectedCardKeys.add(cardKey);
                                }
                              });
                            }
                          },
                          onTaken: () {
                            if (!isSelectionMode) {
                              context.read<HomeCubit>().markAsTaken(medicine);
                            }
                          },
                        );
                      },
                    );
                  } else if (state is HomeError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('Select a profile'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'deleteAll',
            backgroundColor: Colors.red[100],
            foregroundColor: Colors.red,
            onPressed: () {
              final profileState = context.read<ProfileCubit>().state;
              if (profileState is ProfileLoaded &&
                  profileState.selectedProfileId != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete All Medicines?'),
                    content: const Text(
                      'This will permanently delete all medicines for this profile.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<HomeCubit>().deleteAllMedicines(
                            profileState.selectedProfileId!,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Icon(Icons.delete_sweep),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'addMedicine',
            onPressed: () {
              final profileState = context.read<ProfileCubit>().state;
              if (profileState is ProfileLoaded &&
                  profileState.selectedProfileId != null) {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => AddMedicinePage(
                          profileId: profileState.selectedProfileId!,
                        ),
                      ),
                    )
                    .then((_) => _loadMedicines());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a profile first'),
                  ),
                );
              }
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

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

  Widget _buildDateToggle() {
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    final isTomorrow = DateUtils.isSameDay(
      selectedDate,
      DateTime.now().add(const Duration(days: 1)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Today')),
          ButtonSegment(value: 1, label: Text('Tomorrow')),
        ],
        selected: {if (isToday) 0 else if (isTomorrow) 1 else -1},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            if (newSelection.contains(0)) {
              selectedDate = DateTime.now();
            } else if (newSelection.contains(1)) {
              selectedDate = DateTime.now().add(const Duration(days: 1));
            }
          });
          _loadMedicines();
        },
        emptySelectionAllowed:
            true, // Allow deselect if picking other date via calendar
      ),
    );
  }
}
