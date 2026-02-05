import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:categorize_app/Widgets/AppAppBar.dart';
import 'package:categorize_app/bloc/AuthBloc/bloc.dart';
import 'package:categorize_app/bloc/AuthBloc/event.dart';
import 'package:categorize_app/bloc/AuthBloc/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



@RoutePage()
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (BuildContext context, AuthState state) {
            if (state.user.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.user.errorMessage!)),
              );
            }
            if (state.isAuthenticated) {
              context.router.replace(const ProfileRoute());
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (AuthState previous, AuthState current) => previous.user.email != current.user.email,
                  builder: (BuildContext context, AuthState state) {
                    return TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a login',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your login';
                        }
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
                  buildWhen: (AuthState previous, AuthState current) => previous.user.password != current.user.password,
                  builder: (BuildContext context, AuthState state) {
                    return TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter a password',
                      ),
                      validator: (String? value) {
                        if (value == null || value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                      onChanged: (String value) {
                        context.read<AuthBloc>().add(AuthPasswordChanged(value));
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (AuthState previous, AuthState current) =>
                  previous.user.isSubmitting != current.user.isSubmitting ||
                      previous.user.email != current.user.email ||
                      previous.user.password != current.user.password,
                  builder: (BuildContext context, AuthState state) {
                    if (state.user.isSubmitting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(AuthLoginSubmitted());
                            }
                          },
                          child: const Text('Login'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context.router.push(const RegisterRoute());
                          },
                          child: const Text("Don't have an Account?"),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}