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
import '../../../models/medicine_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  Set<String> selectedCardKeys = {};
  bool _isShowingAll = false;

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
              final homeState = context.read<HomeCubit>().state;
              
              if (profileState is ProfileLoaded && profileState.selectedProfileId != null && homeState is HomeLoaded) {
                _showAdvancedDeleteOptions(context, profileState.selectedProfileId!, homeState);
              } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a profile or wait for medicines to load first.')),
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

  void _showAdvancedDeleteOptions(BuildContext context, String profileId, HomeLoaded homeState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Deletion Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text('Delete All Medicines', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Completely clear this profile.'),
                onTap: () {
                  Navigator.pop(context); // close bottom sheet
                  _confirmDeleteAll(context, profileId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome_motion),
                title: const Text('Delete Specific Medicine'),
                subtitle: const Text('Choose a medicine and modify its past/future occurrences.'),
                onTap: () {
                  Navigator.pop(context); // close bottom sheet
                  _showSpecificMedicineSelector(context, homeState);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteAll(BuildContext context, String profileId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Medicines?'),
        content: const Text('This will permanently delete all medicines for this profile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<HomeCubit>().deleteAllMedicines(profileId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSpecificMedicineSelector(BuildContext context, HomeLoaded homeState) {
    // Deduplicate the generated medicines to find the underlying unique models
    final uniqueMedicines = <String, Medicine>{};
    for (var m in homeState.medicines) {
       uniqueMedicines[m.id] ??= m; 
    }

    if (uniqueMedicines.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active medicines found.')));
       return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
             return Column(
               children: [
                 const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Select Medicine To Delete', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
                 Expanded(
                   child: ListView(
                     controller: scrollController,
                     children: uniqueMedicines.values.map((med) {
                        return ListTile(
                          title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(med.dosage),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(context); // Close selection sheet
                            _showRepetitionScopeSelector(context, med.id, med.name);
                          },
                        );
                     }).toList(),
                   ),
                 ),
               ],
             );
          }
        );
      },
    );
  }

  void _showRepetitionScopeSelector(BuildContext context, String medicineId, String medicineName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Delete Repetitions for $medicineName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Past Repetitions'),
                subtitle: const Text('Keep future reminders, but hide all past history.'),
                onTap: () {
                  context.read<HomeCubit>().updateMedicineScope(medicineId, hideBefore: DateTime.now());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text('Future Repetitions'),
                subtitle: const Text('Keep past history, but stop all future reminders.'),
                onTap: () {
                  context.read<HomeCubit>().updateMedicineScope(medicineId, hideAfter: DateTime.now());
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('All Repetitions', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Completely delete this specific medicine entirely.'),
                onTap: () {
                   // Full deletion of just this medicine ID
                   context.read<HomeCubit>().deleteMedicine(medicineId);
                   Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _loadMedicines() {
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded &&
        profileState.selectedProfileId != null) {
      context.read<HomeCubit>().loadMedicines(
        profileState.selectedProfileId!,
        selectedDate,
        showAll: _isShowingAll,
      );
    }
  }

  Widget _buildDateToggle() {
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());
    final isTomorrow = DateUtils.isSameDay(
      selectedDate,
      DateTime.now().add(const Duration(days: 1)),
    );
    
    int selectedSegment = -1;
    if (_isShowingAll) {
       selectedSegment = 2;
    } else if (isToday) {
       selectedSegment = 0;
    } else if (isTomorrow) {
       selectedSegment = 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Today')),
          ButtonSegment(value: 1, label: Text('Tomorrow')),
          ButtonSegment(value: 2, label: Text('All')),
        ],
        selected: {if (selectedSegment != -1) selectedSegment},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            if (newSelection.contains(0)) {
              selectedDate = DateTime.now();
              _isShowingAll = false;
            } else if (newSelection.contains(1)) {
              selectedDate = DateTime.now().add(const Duration(days: 1));
              _isShowingAll = false;
            } else if (newSelection.contains(2)) {
              _isShowingAll = true;
            }
          });
          _clearSelection();
          _loadMedicines();
        },
        emptySelectionAllowed: true,
      ),
    );
  }
}
