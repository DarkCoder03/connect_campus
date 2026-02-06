import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  // User data
  String _selectedGender = 'Male';
  int _selectedAge = 20;
  String _selectedCollege = 'IIT Delhi';
  String _selectedMajor = 'Computer Science';
  String _selectedYear = '3rd Year';
  List<String> _selectedInterests = [];

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final List<String> _colleges = [
    'IIT Delhi',
    'IIT Bombay',
    'IIT Madras',
    'IIT Kanpur',
    'BITS Pilani',
    'NIT Trichy',
    'Delhi University',
    'VIT Vellore',
    'DTU',
    'IIIT Hyderabad',
    'Other',
  ];

  final List<String> _majors = [
    'Computer Science',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Electronics',
    'Biotechnology',
    'Chemical Engineering',
    'Physics',
    'Mathematics',
    'Business Administration',
    'Psychology',
    'Other',
  ];

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Post Graduate',
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

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      if (!_validatePage1()) return;
    } else if (_currentPage == 1) {
      if (!_validatePage2()) return;
    }

    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _signUp();
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

  bool _validatePage1() {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showError('Please enter a valid email');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validatePage2() {
    if (_nameController.text.isEmpty) {
      _showError('Please enter your name');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _signUp() async {
    if (_selectedInterests.length < 3) {
      _showError('Please select at least 3 interests');
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    bool success = await userProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      age: _selectedAge,
      gender: _selectedGender,
      college: _selectedCollege,
      major: _selectedMajor,
      year: _selectedYear,
      bio: _bioController.text.trim(),
      interests: _selectedInterests,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      _showError(userProvider.error ?? 'Signup failed');
      userProvider.clearError();
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
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
                onPressed: _previousPage,
              )
            : IconButton(
                icon: const Icon(Icons.close, color: AppTheme.darkText),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'Create Account',
          style: const TextStyle(color: AppTheme.darkText),
        ),
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
                    text: _currentPage == 2 ? 'Create Account' : 'Continue',
                    onPressed: _nextPage,
                  ),
          ),
        ],
      ),
    );
  }

  // Page 1: Email & Password
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let\'s get started!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your account to find your campus connection',
            style: TextStyle(color: AppTheme.greyText),
          ),
          const SizedBox(height: 30),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your college email',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: AppTheme.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              filled: true,
              fillColor: AppTheme.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() =>
                      _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
              filled: true,
              fillColor: AppTheme.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 2: Personal Info
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us find better matches for you',
            style: TextStyle(color: AppTheme.greyText),
          ),
          const SizedBox(height: 30),

          // Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your name',
              prefixIcon: const Icon(Icons.person_outline),
              filled: true,
              fillColor: AppTheme.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Age
          Row(
            children: [
              const Text('Age: ', style: TextStyle(fontWeight: FontWeight.w600)),
              Expanded(
                child: Slider(
                  value: _selectedAge.toDouble(),
                  min: 18,
                  max: 30,
                  divisions: 12,
                  label: '$_selectedAge',
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() => _selectedAge = value.round());
                  },
                ),
              ),
              Text(
                '$_selectedAge years',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gender
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        gender,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.darkText,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // College dropdown
          DropdownButtonFormField<String>(
            value: _selectedCollege,
            decoration: InputDecoration(
              labelText: 'College',
              filled: true,
              fillColor: AppTheme.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            items: _colleges.map((college) {
              return DropdownMenuItem(value: college, child: Text(college));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCollege = value!),
          ),
          const SizedBox(height: 20),

          // Major dropdown
          DropdownButtonFormField<String>(
            value: _selectedMajor,
            decoration: InputDecoration(
              labelText: 'Major',
              filled: true,
              fillColor: AppTheme.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            items: _majors.map((major) {
              return DropdownMenuItem(value: major, child: Text(major));
            }).toList(),
            onChanged: (value) => setState(() => _selectedMajor = value!),
          ),
          const SizedBox(height: 20),

          // Year dropdown
          DropdownButtonFormField<String>(
            value: _selectedYear,
            decoration: InputDecoration(
              labelText: 'Year',
              filled: true,
              fillColor: AppTheme.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            items: _years.map((year) {
              return DropdownMenuItem(value: year, child: Text(year));
            }).toList(),
            onChanged: (value) => setState(() => _selectedYear = value!),
          ),
          const SizedBox(height: 20),

          // Bio
          TextFormField(
            controller: _bioController,
            maxLines: 3,
            maxLength: 150,
            decoration: InputDecoration(
              labelText: 'Bio',
              hintText: 'Write something about yourself...',
              filled: true,
              fillColor: AppTheme.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Page 3: Interests
  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you into?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select at least 3 interests (${_selectedInterests.length} selected)',
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
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(25),
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
                    interest,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkText,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
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