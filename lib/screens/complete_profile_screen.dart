import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User data
  String _selectedGender = 'Male';
  int _selectedAge = 20;
  String _selectedCollege = 'IIT Delhi';
  String _selectedMajor = 'Computer Science';
  String _selectedYear = '3rd Year';
  String _bio = '';
  List<String> _selectedInterests = [];
  bool _isLoading = false;

  final List<String> _colleges = [
    'IIT Delhi', 'IIT Bombay', 'IIT Madras', 'IIT Kanpur', 'BITS Pilani',
    'NIT Trichy', 'Delhi University', 'VIT Vellore', 'DTU', 'IIIT Hyderabad', 'Other',
  ];

  final List<String> _majors = [
    'Computer Science', 'Mechanical Engineering', 'Electrical Engineering',
    'Civil Engineering', 'Electronics', 'Biotechnology', 'Physics',
    'Mathematics', 'Business Administration', 'Psychology', 'Other',
  ];

  final List<String> _years = [
    '1st Year', '2nd Year', '3rd Year', '4th Year', 'Post Graduate',
  ];

  final List<String> _allInterests = [
    'Music', 'Gaming', 'Travel', 'Photography', 'Tech', 'Fitness',
    'Reading', 'Movies', 'Food', 'Art', 'Sports', 'Dancing',
    'Cooking', 'Writing', 'Yoga',
  ];

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _completeProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _completeProfile() async {
    if (_selectedInterests.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 3 interests'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    bool success = await userProvider.completeProfile(
      age: _selectedAge,
      gender: _selectedGender,
      college: _selectedCollege,
      major: _selectedMajor,
      year: _selectedYear,
      bio: _bio,
      interests: _selectedInterests,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousPage,
              )
            : null,
        title: const Text('Complete Profile'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index <= _currentPage
                          ? AppTheme.primaryColor
                          : AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPage1(),
                _buildPage2(),
                _buildPage3(),
              ],
            ),
          ),

          // Bottom button
          Padding(
            padding: const EdgeInsets.all(24),
            child: _isLoading
                ? const CircularProgressIndicator(color: AppTheme.primaryColor)
                : CustomButton(
                    text: _currentPage == 2 ? 'Complete Setup' : 'Continue',
                    onPressed: _nextPage,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Info',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // Age slider
          Text('Age: $_selectedAge years', style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _selectedAge.toDouble(),
            min: 18,
            max: 30,
            divisions: 12,
            activeColor: AppTheme.primaryColor,
            label: '$_selectedAge',
            onChanged: (value) => setState(() => _selectedAge = value.round()),
          ),
          const SizedBox(height: 20),

          // Gender selection
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: ['Male', 'Female', 'Other'].map((gender) {
              final isSelected = _selectedGender == gender;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = gender),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        gender,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkText,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Education',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // College dropdown
          DropdownButtonFormField<String>(
            value: _selectedCollege,
            decoration: const InputDecoration(labelText: 'College'),
            items: _colleges.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedCollege = v!),
          ),
          const SizedBox(height: 20),

          // Major dropdown
          DropdownButtonFormField<String>(
            value: _selectedMajor,
            decoration: const InputDecoration(labelText: 'Major'),
            items: _majors.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => _selectedMajor = v!),
          ),
          const SizedBox(height: 20),

          // Year dropdown
          DropdownButtonFormField<String>(
            value: _selectedYear,
            decoration: const InputDecoration(labelText: 'Year'),
            items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
            onChanged: (v) => setState(() => _selectedYear = v!),
          ),
          const SizedBox(height: 20),

          // Bio
          TextField(
            maxLines: 3,
            maxLength: 150,
            decoration: const InputDecoration(
              labelText: 'Bio (Optional)',
              hintText: 'Tell us about yourself...',
            ),
            onChanged: (v) => _bio = v,
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Interests',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select at least 3 (${_selectedInterests.length} selected)',
            style: const TextStyle(color: AppTheme.greyText),
          ),
          const SizedBox(height: 30),

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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkText,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}