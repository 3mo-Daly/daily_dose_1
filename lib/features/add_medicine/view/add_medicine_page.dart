import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../cubit/add_medicine_cubit.dart';
import '../cubit/add_medicine_state.dart';
import '../../../models/medicine_model.dart';
import '../../../core/theme/app_theme.dart';
import 'package:daily_dose/l10n/app_localizations.dart';

class AddMedicinePage extends StatefulWidget {
  final String profileId;
  final String profileName;
  final Medicine? medicine;
  const AddMedicinePage({super.key, required this.profileId, required this.profileName, this.medicine});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _customIntervalController = TextEditingController();
  final _noteController = TextEditingController();
  String? _imagePath;
  
  bool _isInterval = false;
  DateTime _startTime = DateTime.now();
  int? _intervalHours;
  int? _dropdownSelection;
  int? _durationDays;
  
  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      final med = widget.medicine!;
      _nameController.text = med.name;
      _dosageController.text = med.dosage;
      _imagePath = med.imagePath;
      _isInterval = med.isInterval;
      _startTime = med.isInterval ? med.startTime : (med.fixedTime ?? med.startTime);
      _intervalHours = med.intervalHours;
      if (_intervalHours != null) {
        if ([4, 6, 8, 12, 24].contains(_intervalHours)) {
          _dropdownSelection = _intervalHours;
        } else {
          _dropdownSelection = -1;
          _customIntervalController.text = _intervalHours.toString();
        }
      }
      _durationDays = med.durationDays;
      if (_durationDays != null) {
        _durationController.text = _durationDays.toString();
      }
      if (med.note != null) {
        _noteController.text = med.note!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _customIntervalController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.medicine != null ? AppLocalizations.of(context)!.editMedicineTitle : AppLocalizations.of(context)!.addMedicineTitle)),
      body: BlocListener<AddMedicineCubit, AddMedicineState>(
        listener: (context, state) {
          if (state is AddMedicineSuccess) {
            Navigator.pop(context);
          } else if (state is AddMedicineError) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.message)),
             );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: Theme.of(context).brightness == Brightness.dark ? null : AppColors.softShadow,
                        image: _imagePath != null ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover) : null,
                      ),
                      child: _imagePath == null
                        ? Icon(Icons.image_outlined, color: (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black).withOpacity(0.3), size: 32)
                        : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.medicineName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterName : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.dosage,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? AppLocalizations.of(context)!.pleaseEnterDosage : null,
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: Theme.of(context).brightness == Brightness.dark ? null : AppColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _pickTime,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Start Time', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(DateFormat.jm().format(_startTime), style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary, fontSize: 15)),
                                ],
                              ),
                              Icon(Icons.access_time_filled_rounded, color: Theme.of(context).colorScheme.primary.withOpacity(0.8), size: 22),
                            ],
                          ),
                        ),
                      ),
                      Divider(color: Theme.of(context).scaffoldBackgroundColor, height: 1, thickness: 1.5, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Daily Repeat", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            Row(
                              children: [
                                Switch(
                                  value: _isInterval,
                                  onChanged: (val) {
                                    setState(() => _isInterval = val);
                                  },
                                  activeColor: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.repeat_rounded, color: Theme.of(context).colorScheme.primary.withOpacity(0.8), size: 22),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_isInterval) ...[
                        Divider(color: Theme.of(context).scaffoldBackgroundColor, height: 1, thickness: 1.5, indent: 16, endIndent: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Frequency", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    alignment: Alignment.centerRight,
                                    isExpanded: true,
                                    isDense: true,
                                    icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary.withOpacity(0.8)),
                                    underline: const SizedBox(),
                                    value: _dropdownSelection,
                                    items: [4, 6, 8, 12, 24, -1].map((e) {
                                      if (e == -1) {
                                        return DropdownMenuItem(
                                          value: e,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerRight,
                                              child: Text('Custom', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary, fontSize: 15))
                                            )
                                          ),
                                        );
                                      }
                                      int timesPerDay = (24 / e).ceil();
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerRight,
                                            child: Text('Every $e hours ($timesPerDay times a day)', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary, fontSize: 14))
                                          )
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        _dropdownSelection = val;
                                        if (val != -1) {
                                          _intervalHours = val;
                                        } else {
                                          _intervalHours = int.tryParse(_customIntervalController.text);
                                        }
                                      });
                                    },
                                    hint: Align(alignment: Alignment.centerRight, child: Text("Select", style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_dropdownSelection == -1) ...[
                          Divider(color: Theme.of(context).scaffoldBackgroundColor, height: 1, thickness: 1.5, indent: 16, endIndent: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: TextFormField(
                              controller: _customIntervalController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Custom Interval (Hours)',
                                border: const OutlineInputBorder(),
                                hintText: 'Enter hours (max 24)',
                              ),
                              onChanged: (val) {
                                int? parsed = int.tryParse(val);
                                if (parsed != null && parsed > 24) {
                                  _customIntervalController.text = '24';
                                  _customIntervalController.selection = TextSelection.fromPosition(TextPosition(offset: _customIntervalController.text.length));
                                  parsed = 24;
                                }
                                setState(() {
                                  _intervalHours = parsed;
                                });
                              },
                            ),
                          ),
                        ],
                        if (_intervalHours != null && _intervalHours! > 0) ...[
                          Divider(color: Theme.of(context).scaffoldBackgroundColor, height: 1, thickness: 1.5, indent: 16, endIndent: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Schedule Preview", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate((24 / _intervalHours!).ceil(), (index) {
                                    final doseTime = _startTime.add(Duration(hours: _intervalHours! * index));
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Dose ${index + 1}: ${DateFormat.jm().format(doseTime)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.durationDays,
                    hintText: AppLocalizations.of(context)!.optional,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _durationDays = int.tryParse(val);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.noteLabel,
                    hintText: AppLocalizations.of(context)!.noteHint,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 65,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (time != null) {
      final now = DateTime.now();
      setState(() {
        _startTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
       if (widget.medicine != null) {
         context.read<AddMedicineCubit>().editMedicine(
           id: widget.medicine!.id,
           profileId: widget.profileId,
           profileName: widget.profileName,
           name: _nameController.text,
           dosage: _dosageController.text,
           imagePath: _imagePath,
           isInterval: _isInterval,
           startTime: _startTime,
           intervalHours: _isInterval ? _intervalHours : null,
           fixedTime: !_isInterval ? _startTime : null,
           durationDays: _durationDays,
           note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
         );
       } else {
         context.read<AddMedicineCubit>().addMedicine(
           profileId: widget.profileId,
           profileName: widget.profileName,
           name: _nameController.text,
           dosage: _dosageController.text,
           imagePath: _imagePath,
           isInterval: _isInterval,
           startTime: _startTime,
           intervalHours: _isInterval ? _intervalHours : null,
           fixedTime: !_isInterval ? _startTime : null,
           durationDays: _durationDays,
           note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
         );
       }
    }
  }
}
