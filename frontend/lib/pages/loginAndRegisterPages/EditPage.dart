import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Widgets/AppAppBar.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/bloc/AuthBloc/bloc.dart';
import 'package:categorize_app/bloc/AuthBloc/event.dart';
import 'package:categorize_app/bloc/AuthBloc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class EditPage extends StatelessWidget {
  EditPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          final String? errorMessage =
              state.errorMessage ?? state.user.errorMessage;
          if (errorMessage != null) {
            _showErrorSnackBar(context, errorMessage);
          }
          if (state.user.isSuccess) {
            context.router.maybePop();
          }
        },
        child: ResponsiveFrame(
          maxWidth: 680,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (BuildContext context, AuthState state) {
                      return GestureDetector(
                        onTap: () async {
                          final XFile? pickedFile = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            context.read<AuthBloc>().add(
                              AuthProfileImageUpdate(
                                imagePath: pickedFile.path,
                              ),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: const AssetImage(
                            'assets/profiles/profile.png',
                          ),
                          foregroundImage: _resolveAvatarImage(
                            state.user.imagePath,
                          ),
                          onForegroundImageError: (_, __) {},
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) =>
                        previous.user.email != current.user.email,
                    builder: (BuildContext context, AuthState state) {
                      return TextFormField(
                        initialValue: state.user.email,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? value) {
                          if (value == null || value.isEmpty)
                            return 'Please enter email';
                          return null;
                        },
                        onChanged: (String value) {
                          context.read<AuthBloc>().add(AuthEmailChanged(value));
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) =>
                        previous.user.username != current.user.username,
                    builder: (BuildContext context, AuthState state) {
                      return TextFormField(
                        initialValue: state.user.username,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                        onChanged: (String value) {
                          context.read<AuthBloc>().add(
                            AuthUsernameChanged(value),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) =>
                        previous.user.firstName != current.user.firstName,
                    builder: (BuildContext context, AuthState state) {
                      return TextFormField(
                        initialValue: state.user.firstName,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'First Name',
                        ),
                        onChanged: (String value) {
                          context.read<AuthBloc>().add(
                            AuthFirstNameChanged(value),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) =>
                        previous.user.lastName != current.user.lastName,
                    builder: (BuildContext context, AuthState state) {
                      return TextFormField(
                        initialValue: state.user.lastName,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Last Name',
                        ),
                        onChanged: (String value) {
                          context.read<AuthBloc>().add(
                            AuthLastNameChanged(value),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (BuildContext context, AuthState state) {
                      if (state.user.isSubmitting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(AuthProfileUpdate());
                          }
                        },
                        child: const Text('Save Changes'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showErrorSnackBar(BuildContext context, String message) {
  final String clearMessage = message.replaceFirst('Exception: ', '');
  final ColorScheme colorScheme = Theme.of(context).colorScheme;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: colorScheme.errorContainer,
      content: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              clearMessage,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    ),
  );
}

ImageProvider _resolveAvatarImage(String imagePath) {
  const AssetImage fallback = AssetImage('assets/profiles/profile.png');

  if (imagePath.isEmpty) {
    return fallback;
  }

  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return NetworkImage(imagePath);
  }

  final File file = File(imagePath);
  if (file.existsSync()) {
    return FileImage(file);
  }

  if (imagePath.startsWith('assets/')) {
    return AssetImage(imagePath);
  }

  return fallback;
}
