import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/api_service.dart';
import '../../register/widgets/register_field_heading.dart';
import '../../register/widgets/register_primary_button.dart';
import '../../register/widgets/register_text_input.dart';

class AddNewMusicScreen extends StatefulWidget {
  const AddNewMusicScreen({required this.onTrackCreated, super.key});

  final VoidCallback onTrackCreated;

  @override
  State<AddNewMusicScreen> createState() => _AddNewMusicScreenState();
}

class _AddNewMusicScreenState extends State<AddNewMusicScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _albumController = TextEditingController();
  final _durationController = TextEditingController();
  final _releaseDateController = TextEditingController();

  final List<String> _genres = const [
    'Pop',
    'Rock',
    'Electronic',
    'Jazz',
    'Hip Hop',
    'More',
  ];

  String _selectedGenre = 'Pop';
  bool _isSubmitting = false;
  PlatformFile? _audioFile;
  PlatformFile? _videoFile;
  PlatformFile? _coverImage;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _durationController.dispose();
    _releaseDateController.dispose();
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

  Future<void> _pickReleaseDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );

    if (date == null) {
      return;
    }

    _releaseDateController.text =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp3', 'wav', 'm4a', 'aac', 'flac'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _audioFile = result.files.first;
      });
    }
  }

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['mp4', 'mov', 'mkv', 'avi', 'webm'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _videoFile = result.files.first;
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _coverImage = result.files.first;
      });
    }
  }

  Future<void> _saveTrack() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_audioFile?.bytes == null) {
      _showMessage('Please upload an audio file.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.createSong(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        album: _albumController.text.trim(),
        genre: _selectedGenre == 'More' ? '' : _selectedGenre,
        durationSeconds: _durationController.text.trim(),
        releaseDate: _releaseDateController.text.trim(),
        audioBytes: _audioFile!.bytes!,
        audioFileName: _audioFile!.name,
        videoBytes: _videoFile?.bytes,
        videoFileName: _videoFile?.name,
        coverBytes: _coverImage?.bytes,
        coverFileName: _coverImage?.name,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      widget.onTrackCreated();
      Navigator.of(context).pop();
      _showMessage('Track created successfully');
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
      _showMessage('Unable to save the track right now.');
    }
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RegisterFieldHeading(text: label),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    final input = RegisterTextInput(
      controller: controller,
      hintText: hintText,
      prefixIcon: icon,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: TextInputAction.next,
      suffix: readOnly
          ? const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            )
          : null,
    );

    if (!readOnly) {
      return input;
    }

    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(child: input),
    );
  }

  Widget _buildUploadBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required PlatformFile? file,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD6CCF5), width: 1.2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6D28D9), size: 28),
            const SizedBox(height: 10),
            Text(
              file?.name ?? title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFCFF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6D28D9)),
        ),
        title: const Text(
          'Add New Music',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF6D28D9)),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F4FF),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFCFF), Color(0xFFF2ECFF)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('TRACK TITLE'),
                _buildInput(
                  controller: _titleController,
                  hintText: 'e.g. Blinding Lights',
                  icon: Icons.title_rounded,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Enter track title.'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('ARTIST'),
                          _buildInput(
                            controller: _artistController,
                            hintText: 'The Weeknd',
                            icon: Icons.person_rounded,
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? 'Enter artist.'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('ALBUM'),
                          _buildInput(
                            controller: _albumController,
                            hintText: 'After Hours',
                            icon: Icons.album_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionLabel('GENRE'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _genres.map((genre) {
                    final isSelected = _selectedGenre == genre;
                    return ChoiceChip(
                      selected: isSelected,
                      label: Text(genre),
                      onSelected: (_) {
                        setState(() {
                          _selectedGenre = genre;
                        });
                      },
                      selectedColor: const Color(0xFF6D28D9),
                      backgroundColor: const Color(0xFFFFFFFF),
                      side: const BorderSide(color: Color(0xFFD6CCF5)),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('DURATION (SEC)'),
                          _buildInput(
                            controller: _durationController,
                            hintText: '200',
                            icon: Icons.schedule_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('RELEASE DATE'),
                          _buildInput(
                            controller: _releaseDateController,
                            hintText: 'yyyy-mm-dd',
                            icon: Icons.calendar_month_rounded,
                            readOnly: true,
                            onTap: _pickReleaseDate,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('AUDIO FILE'),
                          _buildUploadBox(
                            title: 'MP3 UPLOAD',
                            subtitle: 'Required',
                            icon: Icons.music_note_rounded,
                            onTap: _pickAudioFile,
                            file: _audioFile,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel('VIDEO FILE'),
                          _buildUploadBox(
                            title: 'MP4 UPLOAD',
                            subtitle: 'Optional',
                            icon: Icons.video_library_rounded,
                            onTap: _pickVideoFile,
                            file: _videoFile,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSectionLabel('AUDIO PROFILE / COVER ART'),
                _buildUploadBox(
                  title: 'Upload Cover Image',
                  subtitle: 'JPG, PNG up to 10MB',
                  icon: Icons.add_a_photo_rounded,
                  onTap: _pickCoverImage,
                  file: _coverImage,
                ),
                const SizedBox(height: 24),
                RegisterPrimaryButton(
                  label: 'Save Track',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _saveTrack,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
