import '../../models/Mode.dart';

final List<Mode> modes = <Mode>[
  Mode(
      title: 'Online',
      description: 'Photos are sent to the server and categorized in the cloud.',
      pros: [
        'Processing is usually faster.',
        'Server-side categorization can be heavier.',
        'Good for large galleries when internet is stable.',
      ],
      cons: [
        'An account is required.',
        'Photos are uploaded for processing.',
      ]
  ),
  Mode(
      title: 'Offline',
      description: 'The app will process photos directly on your phone.',
      pros: [
        'No account is required.',
        'Photos are not uploaded to the server.',
        'Works without a stable internet connection.',
      ],
      cons: [
        'Categorization can take longer.',
        'Processing may use more battery.',
        'Best used from the focused processing screen.',
      ]
  )
];