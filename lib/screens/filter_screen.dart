import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic> currentFilters;

  const FilterScreen({super.key, required this.currentFilters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late RangeValues _ageRange;
  late double _maxDistance;
  late List<String> _selectedColleges;
  late List<String> _selectedInterests;
  late String _yearFilter;
  late bool _showVerifiedOnly;

  final List<String> _allColleges = [
    'IIT Delhi',
    'IIT Bombay',
    'BITS Pilani',
    'NIT Trichy',
    'Delhi University',
    'VIT Vellore',
    'DTU',
    'IIIT Hyderabad',
    'IIT Madras',
    'IIT Kanpur',
  ];

  final List<String> _allInterests = [
    'Music',
    'Gaming',
    'Travel',
    'Photography',
    'Tech',
    'Fitness',
    'Reading',
    'Movies',
    'Food',
    'Art',
    'Sports',
    'Dancing',
    'Cooking',
    'Writing',
    'Yoga',
  ];

  final List<String> _yearOptions = ['All', '1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  void initState() {
    super.initState();
    _ageRange = RangeValues(
      widget.currentFilters['minAge'].toDouble(),
      widget.currentFilters['maxAge'].toDouble(),
    );
    _maxDistance = widget.currentFilters['maxDistance'].toDouble();
    _selectedColleges = List<String>.from(widget.currentFilters['colleges']);
    _selectedInterests = List<String>.from(widget.currentFilters['interests']);
    _yearFilter = widget.currentFilters['yearFilter'];
    _showVerifiedOnly = widget.currentFilters['showVerifiedOnly'];
  }

  void _resetFilters() {
    setState(() {
      _ageRange = const RangeValues(18, 30);
      _maxDistance = 50;
      _selectedColleges = [];
      _selectedInterests = [];
      _yearFilter = 'All';
      _showVerifiedOnly = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filters reset to default'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'minAge': _ageRange.start.round(),
      'maxAge': _ageRange.end.round(),
      'maxDistance': _maxDistance.round(),
      'colleges': _selectedColleges,
      'interests': _selectedInterests,
      'yearFilter': _yearFilter,
      'showVerifiedOnly': _showVerifiedOnly,
    });
  }

  bool _hasActiveFilters() {
    return _ageRange.start != 18 ||
        _ageRange.end != 30 ||
        _maxDistance != 50 ||
        _selectedColleges.isNotEmpty ||
        _selectedInterests.isNotEmpty ||
        _yearFilter != 'All' ||
        _showVerifiedOnly;
  }

  String _getInterestEmoji(String interest) {
    switch (interest.toLowerCase()) {
      case 'music':
        return '🎵';
      case 'gaming':
        return '🎮';
      case 'travel':
        return '✈️';
      case 'photography':
        return '📷';
      case 'tech':
        return '💻';
      case 'fitness':
        return '💪';
      case 'reading':
        return '📚';
      case 'movies':
        return '🎬';
      case 'food':
        return '🍕';
      case 'art':
        return '🎨';
      case 'sports':
        return '⚽';
      case 'dancing':
        return '💃';
      case 'cooking':
        return '👨‍🍳';
      case 'writing':
        return '✍️';
      case 'yoga':
        return '🧘';
      default:
        return '⭐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filters',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Age Range
                  _buildSectionTitle('Age Range'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Show people aged',
                              style: TextStyle(color: AppTheme.greyText),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_ageRange.start.round()} - ${_ageRange.end.round()} years',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        RangeSlider(
                          values: _ageRange,
                          min: 18,
                          max: 40,
                          divisions: 22,
                          activeColor: AppTheme.primaryColor,
                          inactiveColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          labels: RangeLabels(
                            _ageRange.start.round().toString(),
                            _ageRange.end.round().toString(),
                          ),
                          onChanged: (values) {
                            setState(() {
                              _ageRange = values;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '18',
                              style: TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '40',
                              style: TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Distance
                  _buildSectionTitle('Maximum Distance'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Show people within',
                              style: TextStyle(color: AppTheme.greyText),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_maxDistance.round()} km',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Slider(
                          value: _maxDistance,
                          min: 1,
                          max: 100,
                          divisions: 99,
                          activeColor: AppTheme.primaryColor,
                          inactiveColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          onChanged: (value) {
                            setState(() {
                              _maxDistance = value;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '1 km',
                              style: TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '100 km',
                              style: TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Year Filter
                  _buildSectionTitle('Year'),
                  const SizedBox(height: 5),
                  Text(
                    'Filter by academic year',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _yearOptions.map((year) {
                      final isSelected = _yearFilter == year;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _yearFilter = year;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            year,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.darkText,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),

                  // Colleges
                  _buildSectionTitle('Colleges'),
                  const SizedBox(height: 5),
                  Text(
                    'Select preferred colleges (${_selectedColleges.length} selected)',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _allColleges.map((college) {
                      final isSelected = _selectedColleges.contains(college);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedColleges.remove(college);
                            } else {
                              _selectedColleges.add(college);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(Icons.check, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                              ],
                              const Icon(Icons.school, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                college,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.darkText,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),

                  // Interests
                  _buildSectionTitle('Interests'),
                  const SizedBox(height: 5),
                  Text(
                    'Match with people who share these interests (${_selectedInterests.length} selected)',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _allInterests.map((interest) {
                      final isSelected = _selectedInterests.contains(interest);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedInterests.remove(interest);
                            } else {
                              _selectedInterests.add(interest);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getInterestEmoji(interest),
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                interest,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.darkText,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check, color: Colors.white, size: 14),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),

                  // Verified Only Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified, color: Colors.blue),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verified Profiles Only',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Show only verified users for extra safety',
                                style: TextStyle(
                                  color: AppTheme.greyText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _showVerifiedOnly,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _showVerifiedOnly = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Active Filters Summary
                  if (_hasActiveFilters())
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.filter_list, color: AppTheme.primaryColor, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Active Filters',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_countActiveFilters()} active',
                                style: TextStyle(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.7),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _buildActiveFilterChips(),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Preview count
                  if (_hasActiveFilters())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            color: AppTheme.greyText,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Estimated ${_getEstimatedCount()} matches',
                            style: TextStyle(
                              color: AppTheme.greyText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      // Clear button
                      if (_hasActiveFilters())
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resetFilters,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              side: BorderSide(color: AppTheme.greyText.withValues(alpha: 0.3)),
                            ),
                            child: const Text('Clear All'),
                          ),
                        ),
                      if (_hasActiveFilters()) const SizedBox(width: 12),
                      // Apply button
                      Expanded(
                        flex: _hasActiveFilters() ? 2 : 1,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _hasActiveFilters() ? 'Apply Filters' : 'Show All Profiles',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
      ],
    );
  }

  int _countActiveFilters() {
    int count = 0;
    if (_ageRange.start != 18 || _ageRange.end != 30) count++;
    if (_maxDistance != 50) count++;
    if (_yearFilter != 'All') count++;
    if (_showVerifiedOnly) count++;
    count += _selectedColleges.length;
    count += _selectedInterests.length;
    return count;
  }

  List<Widget> _buildActiveFilterChips() {
    List<Widget> chips = [];

    if (_ageRange.start != 18 || _ageRange.end != 30) {
      chips.add(_buildFilterChip(
        '${_ageRange.start.round()}-${_ageRange.end.round()} yrs',
        Icons.cake,
        () {
          setState(() {
            _ageRange = const RangeValues(18, 30);
          });
        },
      ));
    }

    if (_maxDistance != 50) {
      chips.add(_buildFilterChip(
        '< ${_maxDistance.round()} km',
        Icons.location_on,
        () {
          setState(() {
            _maxDistance = 50;
          });
        },
      ));
    }

    if (_yearFilter != 'All') {
      chips.add(_buildFilterChip(
        _yearFilter,
        Icons.school,
        () {
          setState(() {
            _yearFilter = 'All';
          });
        },
      ));
    }

    if (_showVerifiedOnly) {
      chips.add(_buildFilterChip(
        'Verified',
        Icons.verified,
        () {
          setState(() {
            _showVerifiedOnly = false;
          });
        },
      ));
    }

    for (var college in _selectedColleges) {
      chips.add(_buildFilterChip(
        college,
        Icons.account_balance,
        () {
          setState(() {
            _selectedColleges.remove(college);
          });
        },
      ));
    }

    for (var interest in _selectedInterests) {
      chips.add(_buildFilterChip(
        interest,
        Icons.favorite,
        () {
          setState(() {
            _selectedInterests.remove(interest);
          });
        },
      ));
    }

    return chips;
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 12,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getEstimatedCount() {
    // Simulate estimated count based on filters
    int base = 50;
    
    // Age range reduces pool
    double ageRange = _ageRange.end - _ageRange.start;
    base = (base * (ageRange / 22)).round();
    
    // Distance affects count
    base = (base * (_maxDistance / 100)).round();
    
    // College filter
    if (_selectedColleges.isNotEmpty) {
      base = (base * 0.3 * _selectedColleges.length).round();
    }
    
    // Interest filter
    if (_selectedInterests.isNotEmpty) {
      base = (base * 0.4 * _selectedInterests.length).round();
    }
    
    // Year filter
    if (_yearFilter != 'All') {
      base = (base * 0.25).round();
    }
    
    // Verified only
    if (_showVerifiedOnly) {
      base = (base * 0.4).round();
    }
    
    return base > 0 ? '$base+' : '0';
  }
}