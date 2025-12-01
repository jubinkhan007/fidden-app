import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/consultation_controller.dart';

class ConsultationCreateScreen extends StatefulWidget {
  const ConsultationCreateScreen({super.key});

  @override
  State<ConsultationCreateScreen> createState() => _ConsultationCreateScreenState();
}

class _ConsultationCreateScreenState extends State<ConsultationCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationMinutes = 30;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      Get.snackbar('Error', 'Please select a date');
      return;
    }
    if (_selectedTime == null) {
      Get.snackbar('Error', 'Please select a time');
      return;
    }

    final controller = Get.find<ConsultationController>();
    final dateStr = '${_selectedDate!.year.toString().padLeft(4, '0')}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';
    final timeStr = '${_selectedTime!.hour.toString().padLeft(2, '0')}:'
        '${_selectedTime!.minute.toString().padLeft(2, '0')}:00';
    
    controller.createConsultation(
      customerName: _nameController.text.trim(),
      customerEmail: _emailController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      date: dateStr,
      time: timeStr,
      durationMinutes: _durationMinutes,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConsultationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Consultation'),
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Customer Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Customer Email *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Customer Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Customer Phone *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date Picker
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(_selectedDate == null 
                    ? 'Select Date *'
                    : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _selectDate,
              ),
              
              const SizedBox(height: 16),
              
              // Time Picker
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                leading: const Icon(Icons.access_time),
                title: Text(_selectedTime == null 
                    ? 'Select Time *'
                    : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _selectTime,
              ),
              
              const SizedBox(height: 16),
              
              // Duration
              DropdownButtonFormField<int>(
                value: _durationMinutes,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                items: [15, 30, 45, 60, 90, 120].map((minutes) {
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text('$minutes minutes'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _durationMinutes = value);
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Design preferences, reference images needed, etc.',
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              ElevatedButton(
                onPressed: controller.isLoading.value ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Schedule Consultation', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
