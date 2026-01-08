import 'package:flutter/material.dart';



class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    this.name,
    this.image,
    this.mail
  });

  final String? name;
  final String? mail;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 48,
            backgroundImage: image,
          ),
          const SizedBox(height: 12),
          Text(
              name!,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 6),
          Text(
            mail!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Edit profile'),
          ),
        ],
      ),
    );
  }
}
