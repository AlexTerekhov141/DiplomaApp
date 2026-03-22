import 'package:categorize_app/bloc/AuthBloc/bloc.dart';
import 'package:categorize_app/bloc/AuthBloc/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalDataStep extends StatelessWidget {
  const PersonalDataStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Name',
            prefixIcon: Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter your name';
            }
            return null;
          },
          onChanged: (String value) {
            context.read<AuthBloc>().add(AuthFirstNameChanged(value));
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Surname',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter your surname';
            }
            return null;
          },
          onChanged: (String value) {
            context.read<AuthBloc>().add(AuthLastNameChanged(value));
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.alternate_email_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter username';
            }
            return null;
          },
          onChanged: (String value) {
            context.read<AuthBloc>().add(AuthUsernameChanged(value));
          },
        ),
      ],
    );
  }
}