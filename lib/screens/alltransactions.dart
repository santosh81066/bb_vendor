import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Models/bookinglistmodel.dart';
import 'package:bb_vendor/Widgets/tabbar.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  String filter = 'All';
  final List<BookingListModel> bookings = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 12; i++) {
      bookings.add(BookingListModel(
          name: "Transaction Id ",
          date: "Aug 7,2023 4:20 PM",
          address: "Relative Booking Id"));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BookingListModel> filteredBookings = bookings.where((booking) {
      if (filter != 'All' && booking.status != filter) {
        return false;
      }
      print("print1:" + searchQuery + "/n booking Id ${booking.name}");
      if (searchQuery.isNotEmpty && !booking.name!.contains(searchQuery)) {
        print("print:" + searchQuery);
        return false;
      }
      return true;
    }).toList();
    return Scaffold(
      backgroundColor: CoustColors.colrFill,
      appBar: AppBar(
        backgroundColor: CoustColors.colrFill,
        title: const coustText(
          sName: 'All Transactions',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: CoustTextfield(
              hint: "Search...",
              radius: 30.0,
              width: 10,
              isVisible: false,
              prefixIcon: const Icon(Icons.search),
              fillcolor: CoustColors.colrMainbg,
              filled: true,
              onChanged: (value) {
                setState(() {
                  searchQuery = value!;
                });
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CoustTabbar(
                  filter: filter,
                  length: 3,
                  tab0: "All",
                  tab1: "Credited",
                  tab2: "Refunded",
                  tab3: "hello",
                  onTap: (selected) {
                    setState(() {
                      switch (selected) {
                        case 0:
                          filter = "All";
                          print("Selected${selected}");
                          break;
                        case 1:
                          filter = "Credited";
                          print("Selected${selected}");
                          break;
                        case 2:
                          filter = "Refunded";
                          print("Selected${selected}");
                          break;
                        
                      }
                    });
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: CoustColors.colrMainbg,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      bool isTotal = false;
                      if (index.isEven) {
                        isTotal = true;
                      } else {
                        isTotal = false;
                      }
                      return _buildBookingItem(filteredBookings[index],
                          isTotal: isTotal);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(BookingListModel booking, {bool isTotal = false}) {
    return Column(
      children: [
        ListTile(
          title: coustText(
            sName: booking.name!,
            fontweight: FontWeight.bold,
            textsize: 18,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              coustText(
                sName: booking.date!,
                textsize: 14,
                txtcolor: CoustColors.colrEdtxt4,
              ),
              coustText(
                sName: booking.address!,
                textsize: 14,
                txtcolor: CoustColors.colrEdtxt4,
              ),
            ],
          ),
          trailing: coustText(
            sName: "2300",
            fontweight: FontWeight.bold,
            textsize: 18,
            txtcolor:
                isTotal ? CoustColors.paymenttext : CoustColors.refundtext,
          ),
          onTap: () {
             Navigator.of(context).pushNamed('/bookingdetails');
            // Handle booking item click

            print('${booking.name} clicked');
          },
        ),
        const Divider(
          height: 1,
          thickness: 2,
          color: CoustColors.colrEdtxt4,
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
