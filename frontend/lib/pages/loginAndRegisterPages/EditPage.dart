import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/Widgets/AppAppBar.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState state) {
            if (state.user.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.user.errorMessage!)),
              );
            }
            if (state.user.isSuccess) {
              context.router.replace(const ProfileRoute());
            }
          },
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
                          /*final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            context.read<AuthBloc>().add(
                              AuthProfileImageUpdate(imagePath: pickedFile.path),
                            );
                          }*/
                        },
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: state.user.imagePath.isNotEmpty
                              ? FileImage(File(state.user.imagePath))
                              : const AssetImage('assets/profiles/profile.png') as ImageProvider,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) => previous.user.email != current.user.email,
                    builder: (BuildContext context, AuthState state) {
                      return TextFormField(
                        initialValue: state.user.email,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) return 'Please enter email';
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
                    buildWhen: (AuthState previous, AuthState current) => previous.user.username != current.user.username,
                    builder: (BuildContext context, AuthState state) {
                      return TextFormField(
                        initialValue: state.user.username,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                        onChanged: (String value) {
                          context.read<AuthBloc>().add(AuthUsernameChanged(value));
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) => previous.user.firstName != current.user.firstName,
                    builder: (BuildContext context, AuthState state) {
                      return TextFormField(
                        initialValue: state.user.firstName,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'First Name',
                        ),
                        onChanged: (String value) {
                          context.read<AuthBloc>().add(AuthFirstNameChanged(value));
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) => previous.user.lastName != current.user.lastName,
                    builder: (BuildContext context, AuthState state) {
                      return TextFormField(
                        initialValue: state.user.lastName,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Last Name',
                        ),
                        onChanged: (String value) {
                          context.read<AuthBloc>().add(AuthLastNameChanged(value));
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
