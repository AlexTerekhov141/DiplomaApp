import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:flutter/material.dart';



class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.name,
    this.mail,
    required this.image,
    this.onEdit,
    this.hasAccount = true,
  });

  final String? name;
  final String? mail;
  final ImageProvider image;
  final VoidCallback? onEdit;
  final bool hasAccount;

  @override
  Widget build(BuildContext context) {
    const AssetImage fallbackAvatar = AssetImage('assets/profiles/profile.png');

    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 48,
            backgroundImage: fallbackAvatar,
            foregroundImage: image,
            onForegroundImageError: (_, __) {},
          ),
          const SizedBox(height: 12),
          hasAccount
              ? Text(
            name ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          )
              : const Text(
            'No account yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          hasAccount
              ? Text(
            mail ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  context.router.push(const RegisterRoute());
                },
                child: const Text('Create Account'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  context.router.push(LoginRoute());
                },
                child: const Text('Login'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasAccount)
            OutlinedButton(
              onPressed: onEdit,
              child: const Text('Edit profile'),
            ),
        ],
      ),
    );
  }
}
