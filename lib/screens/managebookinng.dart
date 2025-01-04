import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:bb_vendor/Models/bookinglistmodel.dart';
import 'package:bb_vendor/Widgets/tabbar.dart';
import 'package:bb_vendor/Widgets/text.dart';
import 'package:bb_vendor/Widgets/textfield.dart';
import 'package:flutter/material.dart';

class ManageBookingScreen extends StatefulWidget {
  const ManageBookingScreen({super.key});

  @override
  State<ManageBookingScreen> createState() => _ManageBookingScreenState();
}

class _ManageBookingScreenState extends State<ManageBookingScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  String filter = 'All';
  final List<BookingListModel> bookings = [];
 
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 12; i++) {
      bookings.add(BookingListModel(
          name: "swagath grand", date: "24 jan", status: "Upcoming"));
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
          sName: 'Manage Bookings',
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
           
              child:CoustTextfield(
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
            child: CoustTabbar(filter: filter,length: 4,tab0: "All",tab1: "Current",tab2: "Upcoming",tab3: "Refunded",
            onTap: (selected) {
          setState(() {
            switch (selected) {
              case 0:
                filter = "All";
                print("Selected${selected}");
                break;
              case 1:
                filter =  "Current";
                print("Selected${selected}");
                break;
              case 2:
                filter =  "Upcoming";
                print("Selected${selected}");
                break;
              case 3:
                filter = "Refunded";
                print("Selected${selected}");
                break;
            }
          });
          return null;
        },),
        
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
                      return _buildBookingItem(filteredBookings[index]);
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

  Widget _buildBookingItem(BookingListModel booking) {
    Color statusColor;
    switch (booking.status) {
      case 'Upcoming':
        statusColor = Colors.purple.shade100;
        break;
      case 'Refunded':
        statusColor = Colors.red.shade100;
        break;
      case 'Completed':
        statusColor = Colors.green.shade100;
        break;
      default:
        statusColor = Colors.grey.shade200;
    }

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            color: CoustColors.colrEdtxt4,
          ),
          title: coustText(sName :booking.name!,fontweight: FontWeight.bold,textsize: 18,),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              coustText(sName :booking.date!,textsize: 14,txtcolor: CoustColors.colrEdtxt4,),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child:coustText(sName :booking.status!,textsize: 16,),
              ),
            ],
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 10,
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
