import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar.dart';

class BookingFormScreen extends StatefulWidget {
  final int providerId;
  final int serviceId;

  const BookingFormScreen({
    super.key,
    required this.providerId,
    required this.serviceId,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _notesController = TextEditingController();
  List addresses = [];
  int? selectedAddressId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool loading = false;
  bool fetchingAddresses = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final res = await ApiService.get('/addresses');
      setState(() {
        addresses = res['addresses'];
        if (addresses.isNotEmpty) {
          selectedAddressId = addresses[0]['id'];
        }
        fetchingAddresses = false;
      });
    } catch (e) {
      setState(() => fetchingAddresses = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF06B6D4),
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF06B6D4),
          ),
        ),
        child: child!,
      ),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  Future<void> _book() async {
    if (selectedAddressId == null) {
      showError(context, 'Please select an address');
      return;
    }
    if (selectedDate == null || selectedTime == null) {
      showError(context, 'Please select date and time');
      return;
    }

    setState(() => loading = true);

    final scheduledAt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      await ApiService.post('/bookings', {
        'providerId': widget.providerId,
        'serviceId': widget.serviceId,
        'addressId': selectedAddressId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'notes': _notesController.text.trim(),
      });
      if (!mounted) return;
     showSuccess(context, 'Booking created successfully!');
      context.go('/bookings');
    } catch (e) {
      if (!mounted) return;
      showError(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/providers/${widget.providerId}'),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Book Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: fetchingAddresses
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF06B6D4)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Address
                          const Text('Select Address',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B))),
                          const SizedBox(height: 8),
                          if (addresses.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Text(
                                'No addresses found. Please add one in your profile.',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            )
                          else
                            ...addresses.map((address) => GestureDetector(
                                  onTap: () => setState(
                                      () => selectedAddressId = address['id']),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selectedAddressId == address['id']
                                            ? const Color(0xFF06B6D4)
                                            : const Color(0xFFE2E8F0),
                                        width: selectedAddressId == address['id']
                                            ? 2
                                            : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 18,
                                          color: selectedAddressId == address['id']
                                              ? const Color(0xFF06B6D4)
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                address['label'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              Text(
                                                '${address['address']}, ${address['city']}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),

                          const SizedBox(height: 20),

                          // Date & Time
                          const Text('Select Date & Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B))),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16,
                                            color: Color(0xFF06B6D4)),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedDate == null
                                              ? 'Pick date'
                                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: selectedDate == null
                                                ? Colors.grey
                                                : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickTime,
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time_rounded,
                                            size: 16,
                                            color: Color(0xFF06B6D4)),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedTime == null
                                              ? 'Pick time'
                                              : selectedTime!.format(context),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: selectedTime == null
                                                ? Colors.grey
                                                : const Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Notes
                          const Text('Notes (optional)',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF1E293B))),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Any special instructions...',
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Book Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading ? null : _book,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF06B6D4),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Confirm Booking',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}