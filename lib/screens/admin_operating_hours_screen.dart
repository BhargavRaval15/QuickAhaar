import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_ahaar/models/operating_hours.dart';
import 'package:quick_ahaar/providers/operating_hours_provider.dart';
import 'package:quick_ahaar/theme/app_theme.dart';

class AdminOperatingHoursScreen extends StatefulWidget {
  const AdminOperatingHoursScreen({super.key});

  @override
  State<AdminOperatingHoursScreen> createState() => _AdminOperatingHoursScreenState();
}

class _AdminOperatingHoursScreenState extends State<AdminOperatingHoursScreen> {
  late TimeOfDay _openTime;
  late TimeOfDay _closeTime;
  bool _isOpen = true;

  @override
  void initState() {
    super.initState();
    _loadOperatingHours();
  }

  Future<void> _loadOperatingHours() async {
    await context.read<OperatingHoursProvider>().loadOperatingHours();
    final hours = context.read<OperatingHoursProvider>().operatingHours;
    if (hours != null) {
      setState(() {
        _openTime = TimeOfDay(hour: hours.openHour, minute: hours.openMinute);
        _closeTime = TimeOfDay(hour: hours.closeHour, minute: hours.closeMinute);
        _isOpen = hours.isOpen;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpenTime ? _openTime : _closeTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  Future<void> _saveOperatingHours() async {
    final hours = OperatingHours(
      id: 'current',
      openHour: _openTime.hour,
      openMinute: _openTime.minute,
      closeHour: _closeTime.hour,
      closeMinute: _closeTime.minute,
      isOpen: _isOpen,
    );

    await context.read<OperatingHoursProvider>().updateOperatingHours(hours);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Operating hours updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operating Hours'),
      ),
      body: Consumer<OperatingHoursProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Canteen Status'),
                  subtitle: Text(_isOpen ? 'Open' : 'Closed'),
                  value: _isOpen,
                  onChanged: (value) {
                    setState(() {
                      _isOpen = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Opening Time'),
                  subtitle: Text(_openTime.format(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context, true),
                  ),
                ),
                ListTile(
                  title: const Text('Closing Time'),
                  subtitle: Text(_closeTime.format(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _selectTime(context, false),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveOperatingHours,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 