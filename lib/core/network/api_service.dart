import 'dart:math';

class ApiService {
  static const List<Map<String, dynamic>> _serviceTips = [
    {
      'title': 'Plumbing Maintenance',
      'body': 'Check your pipes regularly for minor leaks to prevent major water damage and save on bills.',
    },
    {
      'title': 'Electrical Safety',
      'body': 'Never overload your power outlets. If you experience frequent breaker trips, call a professional electrician.',
    },
    {
      'title': 'Deep Cleaning Hacks',
      'body': 'Baking soda and vinegar are your best friends for cleaning tough grout and eliminating household odors naturally.',
    },
    {
      'title': 'Appliance Longevity',
      'body': 'Clean the lint trap in your dryer after every use and vacuum your refrigerator coils twice a year to extend their lifespans.',
    },
    {
      'title': 'Pest Control Prevention',
      'body': 'Seal cracks around doors and windows and keep food stored in airtight containers to naturally deter household pests.',
    },
    {
      'title': 'AC Efficiency',
      'body': 'Replace your HVAC filters every 1-3 months to ensure optimal airflow and reduce energy consumption.',
    },
    {
      'title': 'Roof Inspections',
      'body': 'Have your roof inspected annually, especially after severe weather, to catch missing shingles before leaks occur.',
    },
    {
      'title': 'Painting Like a Pro',
      'body': 'Always use painter’s tape and high-quality brushes. Two thin coats are always better than one thick coat.',
    },
  ];

  Future<List<Map<String, dynamic>>> fetchServiceTips() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final random = Random();
    final shuffled = List<Map<String, dynamic>>.from(_serviceTips)..shuffle(random);
    return shuffled.take(5).toList();
  }
}
