import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/Widgets/AppAppBar.dart';
import 'package:categorize_app/Widgets/ResponsiveFrame.dart';
import 'package:categorize_app/bloc/AuthBloc/bloc.dart';
import 'package:categorize_app/bloc/AuthBloc/event.dart';
import 'package:categorize_app/bloc/AuthBloc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cards/registercards/LoginDetailsStep.dart';
import '../../cards/registercards/PersonalDataStep.dart';
import '../../cards/registercards/RegisterActionBar.dart';
import '../../cards/registercards/RegisterProgressHeader.dart';
import '../../cards/registercards/RegisterShellCard.dart';


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
    final AuthState authState = context.watch<AuthBloc>().state;

    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.replaceAll(<PageRouteInfo<dynamic>>[
            const AppRoute(),
            const ProfileRoute(),
          ]);
        }
      });
    }

    return Scaffold(
      appBar: AppAppBar(),
      body: ResponsiveFrame(
        maxWidth: 720,
        child: BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState state) {
            if (state.errorMessage != null) {
              _showErrorSnackBar(context, state.errorMessage!);
            }

            if (state.isAuthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.router.replaceAll(<PageRouteInfo<dynamic>>[
                    const AppRoute(),
                    const ProfileRoute(),
                  ]);
                }
              });
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: RegisterShellCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      RegisterProgressHeader(currentStep: _currentStep),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _currentStep == 0
                            ? const PersonalDataStep(
                          key: ValueKey<String>('personal_step'),
                        )
                            : LoginDetailsStep(
                          key: const ValueKey<String>('login_step'),
                          password: _password,
                          onPasswordChanged: (String value) {
                            setState(() => _password = value);
                            context.read<AuthBloc>().add(
                              AuthPasswordChanged(value),
                            );
                          },
                          onPasswordConfirmChanged: (String value) {
                            setState(() => _passwordConfirm = value);
                            context.read<AuthBloc>().add(
                              AuthPasswordConfirmChanged(value),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 28),
                      RegisterActionBar(
                        currentStep: _currentStep,
                        isLoading: authState.isLoading,
                        onBack: _handleBack,
                        onContinue: _handleContinue,
                      ),
                      const SizedBox(height: 16),
                      _AuthFooter(
                        onLoginTap: () {
                          context.router.maybePop();
                        },
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

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _handleContinue() {
    final bool isLastStep = _currentStep == 1;

    if (!isLastStep) {
      setState(() => _currentStep++);
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterSubmitted());
    }
  }
}

class _AuthFooter extends StatelessWidget {
  const _AuthFooter({required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: <Widget>[
          Text(
            'Already have an account?',
            style: textTheme.bodyMedium,
          ),
          TextButton(
            onPressed: onLoginTap,
            child: const Text('Sign in'),
          ),
        ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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