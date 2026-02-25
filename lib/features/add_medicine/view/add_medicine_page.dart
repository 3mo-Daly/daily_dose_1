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
  String? _imagePath;
  
  bool _isInterval = false;
  DateTime _startTime = DateTime.now();
  int? _intervalHours;
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
      _durationDays = med.durationDays;
      if (_durationDays != null) {
        _durationController.text = _durationDays.toString();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
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
                                    value: _intervalHours,
                                    items: [4, 6, 8, 12, 24].map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Align(alignment: Alignment.centerRight, child: Text('Every $e hours', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary, fontSize: 15))),
                                      );
                                    }).toList(),
                                    onChanged: (val) => setState(() => _intervalHours = val),
                                    hint: Align(alignment: Alignment.centerRight, child: Text("Select", style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
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
         );
       }
    }
  }
}
