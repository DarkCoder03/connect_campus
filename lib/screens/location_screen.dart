import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _locationEnabled = true;
  double _maxDistance = 25.0;
  String _selectedLocation = 'Delhi, India';

  final List<String> _recentLocations = [
    'Delhi, India',
    'IIT Delhi Campus',
    'Connaught Place, Delhi',
    'Hauz Khas, Delhi',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Location',
          style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Toggle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Location',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Allow app to access your location',
                          style: TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _locationEnabled,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      setState(() => _locationEnabled = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Current Location
            const Text(
              'Current Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedLocation,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _updateLocation(),
                    child: const Text(
                      'Update',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Maximum Distance
            const Text(
              'Maximum Distance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Show people within ${_maxDistance.round()} km',
              style: const TextStyle(color: AppTheme.greyText),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text('1 km'),
                Expanded(
                  child: Slider(
                    value: _maxDistance,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    activeColor: AppTheme.primaryColor,
                    inactiveColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    onChanged: (value) {
                      setState(() => _maxDistance = value);
                    },
                  ),
                ),
                const Text('100 km'),
              ],
            ),
            const SizedBox(height: 25),

            // Recent Locations
            const Text(
              'Recent Locations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(_recentLocations.length, (index) {
              final location = _recentLocations[index];
              final isSelected = location == _selectedLocation;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.location_on_outlined,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.greyText,
                ),
                title: Text(
                  location,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.darkText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  setState(() => _selectedLocation = location);
                },
              );
            }),
            const SizedBox(height: 25),

            // Location Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your exact location is never shared with other users. Only your approximate distance is shown.',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            CustomButton(
              text: 'Save Location Settings',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location settings saved! ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateLocation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {
        _selectedLocation = 'Delhi, India (Updated)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated! 📍'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}