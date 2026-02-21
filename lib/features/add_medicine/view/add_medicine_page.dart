import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../cubit/add_medicine_cubit.dart';
import '../cubit/add_medicine_state.dart';
import '../../../models/medicine_model.dart';

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
      appBar: AppBar(title: Text(widget.medicine != null ? 'Edit Medicine' : 'Add Medicine')),
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
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                      child: _imagePath == null 
                        ? const Icon(Icons.add_a_photo, size: 40)
                        : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage (e.g. 1 pill)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Please enter dosage' : null,
                ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Repeat Interval'),
                  value: _isInterval,
                  onChanged: (val) {
                    setState(() {
                      _isInterval = val;
                    });
                  },
                ),
                ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(DateFormat.jm().format(_startTime)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                ),
                if (_isInterval) ...[
                   const SizedBox(height: 16),
                   DropdownButtonFormField<int>(
                     decoration: const InputDecoration(
                       labelText: 'Frequency',
                       border: OutlineInputBorder(),
                     ),
                     value: _intervalHours,
                     items: [4, 6, 8, 12, 24].map((e) => DropdownMenuItem(
                       value: e,
                       child: Text('Every $e hours'),
                     )).toList(),
                     onChanged: (val) => setState(() => _intervalHours = val),
                     validator: (val) => _isInterval && val == null ? 'Select frequency' : null,
                   ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (Days)',
                    hintText: 'Leave empty for just today',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _durationDays = int.tryParse(val);
                    });
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Save Medicine'),
                    ),
                  ),
                ),
              ],
            ),
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
