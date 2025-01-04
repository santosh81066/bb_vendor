import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Providers/stateproviders.dart';
import 'package:bb_vendor/Widgets/elevatedbutton.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  const BookingDetailsScreen({super.key});

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  _onWillPop(bool pop) async {
    ref.read(refundissued.notifier).state = false;
    ref.read(canclebuttonprovider.notifier).state = CoustColors.colrButton2;
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onWillPop,
      child: Scaffold(
        backgroundColor: CoustColors.colrFill,
        appBar: AppBar(
          backgroundColor: CoustColors.colrFill,
          title: const coustText(
            sName: 'Bookings Details',
            txtcolor: CoustColors.colrEdtxt2,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: CoustColors.colrHighlightedText,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CoustColors.colrMainbg,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const coustText(
                              sName: "Booking Details",
                              textsize: 18,
                              fontweight: FontWeight.bold,
                            ),
                            const Divider(),
                            bookingDetailRow(
                                'Booking Date & Time:', '10 Feb 2024, 04:55AM'),
                            bookingDetailRow('Booking ID:', 'sdsd454gf5gcv45'),
                            const SizedBox(height: 10),
                            const coustText(
                              sName: "Event Details",
                              textsize: 18,
                              fontweight: FontWeight.bold,
                            ),
                            const Divider(),
                            bookingDetailRow('Venue:', 'Swagat Grand Hotel'),
                            bookingDetailRow('Event Type:', 'Wedding'),
                            bookingDetailRow('Event Name:', 'Ravi & Swetha'),
                            bookingDetailRow(
                                'Event Start Date:', '12 Mar 2024, 12:00PM'),
                            bookingDetailRow(
                                'Event End Date:', '13 Mar 2024, 12:00PM'),
                            const SizedBox(height: 10),
                            const coustText(
                              sName: "Payment Details",
                              textsize: 18,
                              fontweight: FontWeight.bold,
                            ),
                            const Divider(),
                            bookingDetailRow(
                                'Transaction ID:', '4554dsds54ds8547'),
                            bookingDetailRow('Payment:', '₹24,000.00'),
                            bookingDetailRow('GST:', '₹2000.00'),
                            const Divider(),
                            bookingDetailRow('Total Payment:', '₹24,000.00',
                                isTotal: true, color: CoustColors.paymenttext),
                            bookingDetailRow('Mode of Payment:', 'Credit Card',
                                isTotal: true, color: CoustColors.paymenttext),
                            bookingDetailRow(
                                'Card Number:', 'XXX XXXX XXXX 1023',
                                isTotal: true, color: CoustColors.paymenttext),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ref.watch(refundissued)
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CoustColors.colrMainbg,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const coustText(
                                    sName: "Refund Details",
                                    textsize: 18,
                                    fontweight: FontWeight.bold,
                                  ),
                                  const Divider(),
                                  bookingDetailRow('Refund Transaction ID:',
                                      '4554dsds54ds8547'),
                                  bookingDetailRow(
                                    'Total Amount:',
                                    '₹24,000.00',
                                  ),
                                  bookingDetailRow('Cancellation fee:', '2000'),
                                  bookingDetailRow(
                                      'Total Refund:', '₹22,000.00',
                                      isTotal: true,
                                      color: CoustColors.refundtext),
                                  const Divider(),
                                  const coustText(
                                    overflow: TextOverflow.visible,
                                    sName:
                                        "Refund has been initiated to Credit card ending with 1023 refund amount will be credited within 3-4 business days",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Text(""),
                  CoustElevatedButton(
                    buttonName: "Cancle & Refund",
                    width: double.infinity,
                    bgColor: (ref.watch(canclebuttonprovider)),
                    radius: 8,
                    FontSize: 20,
                    onPressed: () {
                      ref.read(refundissued.notifier).state = true;
                      ref.read(canclebuttonprovider.notifier).state =
                          CoustColors.colrButton1;
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget bookingDetailRow(String title, String detail,
      {bool isTotal = false, Color color = CoustColors.colrMainText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: coustText(
              overflow: TextOverflow.visible,
              sName: title,
              fontweight: isTotal ? FontWeight.bold : FontWeight.normal,
              txtcolor: isTotal ? color : Colors.black,
            ),
          ),
          Expanded(
            child: coustText(
              overflow: TextOverflow.visible,
              sName: detail,
              fontweight: isTotal ? FontWeight.bold : FontWeight.normal,
              txtcolor: isTotal ? color : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
