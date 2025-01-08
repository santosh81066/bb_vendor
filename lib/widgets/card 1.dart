import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PublicationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen size using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: EdgeInsets.only(
          bottom: screenWidth * 0.03), // Responsive bottom margin
      color:
          Color.fromARGB(255, 255, 255, 255), // Light background for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile image positioned on the left side of the row
                CircleAvatar(
                  radius:
                      screenWidth * 0.08, // Adjust radius based on screen width
                  backgroundImage: AssetImage('assets/Ellipse.png'),
                ),
                SizedBox(
                    width: screenWidth *
                        0.05), // Space between the profile image and text

                // Column for doctor's name and specialty
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Guruva Reddy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth *
                            0.045, // Adjust font size based on screen width
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Orthopaedic | DNB-Orth',
                      style: TextStyle(
                        fontSize: screenWidth *
                            0.04, // Adjust font size based on screen width
                        color: Color(0xFF656569),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.more_vert, color: Colors.grey),
              ],
            ),
            SizedBox(height: screenHeight * 0.02), // Adjust space dynamically
            // Image and Doctor details
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/icon.png',
                        width: double.infinity,
                        height: screenHeight *
                            0.25, // Adjust height based on screen size
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        child: Container(
                          width: screenWidth *
                              0.3, // Adjust width based on screen size
                          height: 35,
                          padding: EdgeInsets.only(top: 0, right: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(0),
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(100),
                            ),
                            color: Color(0xFF0055AA),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/verfied.png',
                                  color: Colors.white,
                                  width: 16,
                                  height: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Ionized',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth *
                                        0.035, // Adjust font size based on screen width
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.025), // Adjust space dynamically
            // Title and Publishing Date
            Text(
              'Your Simple title goes by truth about analytics',
              style: GoogleFonts.mukta(
                fontSize: screenWidth *
                    0.045, // Adjust font size based on screen width
                fontWeight: FontWeight.w400,
                height: 1.66,
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Adjust space dynamically
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Review (22)'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color(0xFF1F1F38),
                      backgroundColor: Color(0xFFEAEAFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04), // Adjust space dynamically
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Publish'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF0055AA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02), // Adjust space dynamically
            Divider(color: Colors.grey, thickness: 1),
            SizedBox(height: screenHeight * 0.02), // Adjust space dynamically
            Row(
              children: [
                Text(
                  'Publishing on: Dec 28 2024 | 10:30 AM',
                  style: GoogleFonts.mukta(
                    fontSize: screenWidth *
                        0.030, // Adjust font size based on screen width
                    fontWeight: FontWeight.w400,
                    height: 1.66,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: screenWidth * 0.1), // Adjust space dynamically
                Text(
                  '2 Days Left',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.mukta(
                    fontSize: screenWidth *
                        0.032, // Adjust font size based on screen width
                    fontWeight: FontWeight.w400,
                    height: 1.66,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
            SizedBox(height: screenHeight * 0.02), // Adjust space dynamically
          ],
        ),
      ),
    );
  }
}
