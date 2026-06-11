import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/service_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/constants.dart';
import 'package:go_router/go_router.dart';

class ServicesTab extends ConsumerStatefulWidget {
  const ServicesTab({super.key});

  @override
  ConsumerState<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends ConsumerState<ServicesTab> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Home Cleaning',
    'Plumbing',
    'Electrical',
    'Tutoring',
    'Beautician',
    'Mechanic',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final isProvider = user?.role == 'Provider';
    
    final servicesAsync = isProvider 
        ? ref.watch(providerServicesProvider) 
        : ref.watch(allServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isProvider ? 'My Services' : 'Discover Services'),
      ),
      body: Column(
        children: [
          if (!isProvider) ...[
            Padding(
              padding: const EdgeInsets.all(AppConstants.padding),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Services',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.padding),
              child: Row(
                children: _categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          Expanded(
            child: servicesAsync.when(
              data: (services) {
                var filteredServices = services;
                if (!isProvider) {
                  filteredServices = services.where((s) {
                    final matchesSearch = s.title.toLowerCase().contains(_searchQuery);
                    final matchesCategory = _selectedCategory == 'All' || s.category == _selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();
                }

                if (filteredServices.isEmpty) {
                  return Center(child: Text(isProvider ? 'You have no services.' : 'No services found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.padding),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(service.category),
                            const SizedBox(height: 8),
                            Text('\$${service.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Icon(isProvider ? Icons.edit : Icons.arrow_forward_ios),
                        onTap: () {
                          if (!isProvider) {
                            context.push('/service-details', extra: service);
                          } else {
                            // Navigate to Edit screen
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: isProvider ? FloatingActionButton(
        onPressed: () => context.push('/add-service'),
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}
