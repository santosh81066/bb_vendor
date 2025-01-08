import 'package:bb_vendor/screens/editprofile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bb_vendor/Colors/coustcolors.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    print("screenwidth$screenWidth");
    print("screenheight$screenHeight");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125), // Adjust height as needed
        child: Container(
          // padding: const EdgeInsets.only(top: 32.0),
          decoration: const BoxDecoration(
            color: Color(0xff6418c3),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadiusDirectional.only(
              bottomEnd: Radius.circular(25),
              bottomStart: Radius.circular(25),
            ),
          ),
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Banquet Bookz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 35,
                    ),
                    onPressed: () {
                      // Notification action
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Color(0xff6418c3),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suresh Ramesh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditprofileSceren(),
                            ),
                          );
                        },
                        child: const Text(
                          'View Profile',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Main Content Section
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Color(0xff6418c3)),
                          SizedBox(width: 8),
                          Text(
                            'Search with booking ID',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Quick Actions
                    const Text(
                      'Quick actions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStateCard(Icons.person, 'Manage Bookings',
                              screenWidth, screenHeight),
                          SizedBox(width: screenWidth * 0.02),
                          _buildStateCard(Icons.storefront, 'Manage Properties',
                              screenWidth, screenHeight),
                          SizedBox(width: screenWidth * 0.02),
                          _buildStateCard(Icons.currency_rupee,
                              'Manage Transactions', screenWidth, screenHeight),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Stats Section
                    const Text(
                      'Stats',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                            Icons.storefront,
                            '10 bookings',
                            'received\nin last 7 days',
                            screenWidth,
                            screenHeight),
                        SizedBox(width: screenWidth * 0.02),
                        _buildStatCard(
                            Icons.currency_rupee,
                            '₹ 89,928',
                            'earned\nin last 7 days',
                            screenWidth,
                            screenHeight),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Last 5 Transactions Card
                    _buildTransactionCard(screenWidth, screenHeight),

                    SizedBox(height: screenHeight * 0.02),

                    // Listing Stats Card
                    _buildListingStatsCard(screenWidth, screenHeight),

                    SizedBox(height: screenHeight * 0.02),

                    // Footer
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'BanquetBookz vendor Dashboard',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xff6418c3),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Made with ❤️ in India by GoCode Creations',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateCard(
      IconData icon, String label, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.3,
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xff6418c3), size: screenWidth * 0.08),
          SizedBox(height: screenHeight * 0.01),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String subtitle,
      double screenWidth, double screenHeight) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.02),
        height: screenHeight * 0.10,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.02),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                size: screenWidth * 0.08, color: const Color(0xff6418c3)),
            SizedBox(width: screenWidth * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(double screenWidth, double screenHeight) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      color: const Color(0xff6418c3),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Last 5 Transactions',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 5,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white54),
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '15dfdf45dfdf4d12',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '15 Feb, 2024 at 04:55 PM',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      '₹ 11,000',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingStatsCard(double screenWidth, double screenHeight) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Listing stats',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: screenHeight * 0.02),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Listed Properties', style: TextStyle(fontSize: 14)),
                Text('5', style: TextStyle(fontSize: 14)),
              ],
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active', style: TextStyle(fontSize: 14)),
                Text('5', style: TextStyle(fontSize: 14)),
              ],
            ),
            const Divider(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Inactive', style: TextStyle(fontSize: 14)),
                Text('0', style: TextStyle(fontSize: 14)),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),

            // manage
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff6418c3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02)),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.01,
                    horizontal: screenWidth * 0.04,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Manage'),
                    Icon(Icons.play_arrow, size: 16),
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
