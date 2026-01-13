import 'package:equatable/equatable.dart';

class Tags extends Equatable {
  const Tags({
    this.amount = 0,
  });

  final int amount;

  Tags copyWith({
    int? size,
  }) {
    return Tags(
      amount: size ?? amount,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    amount,
  ];
}