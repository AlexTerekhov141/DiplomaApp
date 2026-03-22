import 'package:categorize_app/bloc/AuthBloc/bloc.dart';
import 'package:categorize_app/bloc/AuthBloc/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginDetailsStep extends StatefulWidget {
  const LoginDetailsStep({
    super.key,
    required this.password,
    required this.onPasswordChanged,
    required this.onPasswordConfirmChanged,
  });

  final String password;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onPasswordConfirmChanged;

  @override
  State<LoginDetailsStep> createState() => _LoginDetailsStepState();
}

class _LoginDetailsStepState extends State<LoginDetailsStep> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: widget.key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.mail_outline_rounded),
            border: OutlineInputBorder(),
          ),
          validator: (String? value) {
            if (value == null || value.trim().isEmpty) {
              return 'Enter email';
            }

            final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegex.hasMatch(value)) {
              return 'Invalid email format';
            }

            return null;
          },
          onChanged: (String value) {
            context.read<AuthBloc>().add(AuthEmailChanged(value));
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: _hidePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() => _hidePassword = !_hidePassword);
              },
              icon: Icon(
                _hidePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) return 'Enter password';
            if (value.length < 8) return 'Minimum 8 characters';
            if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
              return 'Add at least one letter';
            }
            if (!RegExp(r'\d').hasMatch(value)) {
              return 'Add at least one digit';
            }
            return null;
          },
          onChanged: widget.onPasswordChanged,
        ),
        const SizedBox(height: 8),
        Text(
          'Use at least 8 characters, including a letter and a number.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: _hideConfirmPassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Confirm password',
            prefixIcon: const Icon(Icons.verified_user_outlined),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              onPressed: () {
                setState(
                      () => _hideConfirmPassword = !_hideConfirmPassword,
                );
              },
              icon: Icon(
                _hideConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
          ),
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Confirm password';
            }
            if (value != widget.password) {
              return 'The passwords do not match';
            }
            return null;
          },
          onChanged: widget.onPasswordConfirmChanged,
        ),
      ],
    );
  }
}