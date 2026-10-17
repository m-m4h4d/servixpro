import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/notification_helper.dart';
import '../models/service_model.dart';
import '../../bookings/providers/booking_provider.dart';

class ServiceDetailsScreen extends ConsumerStatefulWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  ConsumerState<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends ConsumerState<ServiceDetailsScreen> {
  final _notesController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _bookService() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking date.')),
      );
      return;
    }

    final String bookingId;
    try {
      final booking = await ref.read(bookingControllerProvider.notifier).createBooking(
            serviceId: widget.service.id,
            bookingDate: _selectedDate!,
            notes: _notesController.text.trim(),
          );
      bookingId = booking.id;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send booking request. Please try again.')),
        );
      }
      return;
    }

    // Simulate sending a local notification
    await NotificationHelper.showNotification(
      id: bookingId.hashCode,
      title: 'Booking Requested',
      body: 'Your request for ${widget.service.title} has been sent.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBooking = ref.watch(bookingControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.service.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.service.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: Image.network(
                  widget.service.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Icon(Icons.handyman, size: 80, color: AppColors.primary),
              ),
            const SizedBox(height: 16),
            Text(
              widget.service.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(widget.service.category)),
            const SizedBox(height: 16),
            Text(
              '\$${widget.service.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.service.description),
            const Divider(height: 32),
            const Text('Book this Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                side: const BorderSide(color: Colors.grey),
              ),
              title: Text(_selectedDate == null ? 'Select Date' : _selectedDate!.toLocal().toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Additional Notes (Optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isBooking ? null : _bookService,
              child: isBooking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
