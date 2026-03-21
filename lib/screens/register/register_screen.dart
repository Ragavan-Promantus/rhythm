import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import 'widgets/register_field_heading.dart';
import 'widgets/register_intro.dart';
import 'widgets/register_primary_button.dart';
import 'widgets/register_text_input.dart';
import 'widgets/register_top_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _imagePicker = ImagePicker();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  Uint8List? _profileImageBytes;
  String? _profileImageFileName;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1F2937),
          content: Text(message),
        ),
      );
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) {
      return 'Please enter your username.';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters.';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Please enter your email address.';
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please create a password.';
    }

    if (value!.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  String? _validateMobile(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) {
      return 'Please enter your mobile number.';
    }

    if (mobile.length < 8) {
      return 'Mobile number must be at least 8 digits.';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Please confirm your password.';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }

    return null;
  }

  Future<void> _pickProfileImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 80,
      );

      if (file == null) {
        return;
      }

      final bytes = await file.readAsBytes();
      Uint8List selectedBytes = bytes;

      try {
        final compressedBytes = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 512,
          minHeight: 512,
          quality: 45,
          format: CompressFormat.jpeg,
        );

        if (compressedBytes.isNotEmpty) {
          selectedBytes = Uint8List.fromList(compressedBytes);
        }
      } catch (error) {
        debugPrint('Profile image compression failed: $error');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImageBytes = selectedBytes;
        _profileImageFileName =
            'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      });
    } catch (error) {
      debugPrint('Profile image picker failed: $error');
      _showMessage(
        'Unable to open the gallery. Please allow photo access and try again.',
      );
    }
  }

  void _clearProfileImage() {
    setState(() {
      _profileImageBytes = null;
      _profileImageFileName = null;
    });
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final message = await ApiService.register(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        mobile: _mobileController.text.trim(),
        profileImage: _profileImageBytes?.toList() ?? const [],
        profileImageFilename: _profileImageFileName,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(message);
      Navigator.of(context).maybePop();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });
      _showMessage(
        'Unable to reach ${ApiService.baseUrl}. On a real phone, use your computer LAN IP with --dart-define=API_BASE_URL=http://192.168.x.x:5000.',
      );
    }
  }

  void _goBackToLogin() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4FF),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFCFF), Color(0xFFF2ECFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RegisterTopBar(onBackPressed: _goBackToLogin),
                      const SizedBox(height: 44),
                      const RegisterIntro(),
                      const SizedBox(height: 52),
                      const RegisterFieldHeading(text: 'Username'),
                      const SizedBox(height: 14),
                      RegisterTextInput(
                        controller: _usernameController,
                        hintText: 'Enter your username',
                        prefixIcon: Icons.person_rounded,
                        textInputAction: TextInputAction.next,
                        validator: _validateUsername,
                      ),
                      const SizedBox(height: 28),
                      const RegisterFieldHeading(text: 'Profile Picture'),
                      const SizedBox(height: 14),
                      _ProfileImageField(
                        imageBytes: _profileImageBytes,
                        onPickImage: _pickProfileImage,
                        onClearImage: _profileImageBytes == null
                            ? null
                            : _clearProfileImage,
                      ),
                      const SizedBox(height: 28),
                      const RegisterFieldHeading(text: 'Email'),
                      const SizedBox(height: 14),
                      RegisterTextInput(
                        controller: _emailController,
                        hintText: 'Enter your email',
                        prefixIcon: Icons.mail_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 28),
                      const RegisterFieldHeading(text: 'Mobile'),
                      const SizedBox(height: 14),
                      RegisterTextInput(
                        controller: _mobileController,
                        hintText: 'Enter your mobile number',
                        prefixIcon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: _validateMobile,
                      ),
                      const SizedBox(height: 28),
                      const RegisterFieldHeading(text: 'Password'),
                      const SizedBox(height: 14),
                      RegisterTextInput(
                        controller: _passwordController,
                        hintText: 'Create a password',
                        prefixIcon: Icons.lock_rounded,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        validator: _validatePassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const RegisterFieldHeading(text: 'Confirm Password'),
                      const SizedBox(height: 14),
                      RegisterTextInput(
                        controller: _confirmPasswordController,
                        hintText: 'Repeat your password',
                        prefixIcon: Icons.shield_outlined,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        validator: _validateConfirmPassword,
                        onFieldSubmitted: (_) =>
                            _isSubmitting ? null : _handleSignUp(),
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      RegisterPrimaryButton(
                        label: 'Sign Up',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _handleSignUp,
                      ),
                      const SizedBox(height: 42),
                      Center(
                        child: TextButton(
                          onPressed: _goBackToLogin,
                          child: const Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyle(
                                    color: Color(0xFF6D28D9),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileImageField extends StatelessWidget {
  const _ProfileImageField({
    required this.imageBytes,
    required this.onPickImage,
    required this.onClearImage,
  });

  final Uint8List? imageBytes;
  final VoidCallback onPickImage;
  final VoidCallback? onClearImage;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD6CCF5), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xFFF2ECFF),
                backgroundImage: hasImage ? MemoryImage(imageBytes!) : null,
                child: hasImage
                    ? null
                    : const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF6D28D9),
                        size: 34,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasImage
                          ? 'Profile picture selected'
                          : 'Upload a profile picture',
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose an image from your gallery and preview it before signing up.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onPickImage,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text(hasImage ? 'Change Photo' : 'Choose Photo'),
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: onClearImage,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
