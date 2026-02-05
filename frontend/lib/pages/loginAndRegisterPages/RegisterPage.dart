import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/Widgets/AppAppBar.dart';
import 'package:categorize_app/bloc/AuthBloc/bloc.dart';
import 'package:categorize_app/bloc/AuthBloc/event.dart';
import 'package:categorize_app/bloc/AuthBloc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  String _password = '';
  String _passwordConfirm = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state.user.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.user.errorMessage!)),
            );
          }
          if (state.user.isSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.router.replace(const ProfileRoute());
            });
          }
        },
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () async {
              if (_currentStep < 1) {
                setState(() => _currentStep++);
              } else {
                if (_formKey.currentState!.validate()) {

                  context.read<AuthBloc>().add(AuthRegisterSubmitted());
                  final AuthBloc bloc = context.read<AuthBloc>();
                  final AuthState success = await bloc.stream.firstWhere((AuthState state) => state.isAuthenticated);

                  if (success.isAuthenticated) {
                    if (mounted) {
                      context.router.replace(const ProfileRoute());
                    }
                  }
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            steps: <Step>[
              Step(
                title: const Text('Personal data'),
                isActive: _currentStep >= 0,
                content: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Name',
                      ),
                      validator: (String? v) => v == null || v.isEmpty ? 'Enter your name' : null,
                      onChanged: (String v) => context.read<AuthBloc>().add(AuthFirstNameChanged(v)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Surname',
                      ),
                      validator: (String? v) => v == null || v.isEmpty ? 'Enter your surname' : null,
                      onChanged: (String v) => context.read<AuthBloc>().add(AuthLastNameChanged(v)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'UserName',
                      ),
                      validator: (String? v) => v == null || v.isEmpty ? 'Enter username' : null,
                      onChanged: (String v) => context.read<AuthBloc>().add(AuthUsernameChanged(v)),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Login details'),
                isActive: _currentStep >= 1,
                content: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email / Login',
                      ),
                      validator: (String? v) {
                        if (v == null || v.isEmpty) return 'Enter email';
                        final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(v)) return 'Invalid email format';
                        return null;
                      },
                      onChanged: (String v) => context.read<AuthBloc>().add(AuthEmailChanged(v)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                      validator: (String? v) {
                        if (v == null || v.isEmpty) return 'Enter password';
                        if (v.length < 8) return 'Minimum 8 characters';
                        if (!RegExp(r'[A-Za-z]').hasMatch(v)) return 'Add at least one letter';
                        if (!RegExp(r'\d').hasMatch(v)) return 'Add at least one digit';
                        return null;
                      },
                      onChanged: (String v) {
                        _password = v;
                        context.read<AuthBloc>().add(AuthPasswordChanged(v));
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm your password',
                      ),
                      validator: (String? v) {
                        if (v == null || v.isEmpty) return 'Confirm password';
                        if (v != _password) return "The passwords don't match";
                        return null;
                      },
                      onChanged: (String v) {
                        _passwordConfirm = v;
                        context.read<AuthBloc>().add(AuthPasswordConfirmChanged(v));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
