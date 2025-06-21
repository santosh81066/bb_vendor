import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bb_vendor/Colors/coustcolors.dart';

class HallLocationWidget extends StatelessWidget {
  final String propertyName;
  final String? address;

  const HallLocationWidget({
    Key? key,
    required this.propertyName,
    this.address,
  }) : super(key: key);

  void _openInMaps(BuildContext context) async {
    if (address == null || address!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Address not available'),
          backgroundColor: CoustColors.rose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Uri uri;

    // If address is in lat,lng format, use directly
    if (RegExp(r'^-?\d+(\.\d+)?,-?\d+(\.\d+)?$').hasMatch(address!)) {
      uri = Uri.parse("geo:$address?q=$address($propertyName)");
    } else {
      // Otherwise, use search query
      final encoded = Uri.encodeComponent(address!);
      uri = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encoded");
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open maps'),
          backgroundColor: CoustColors.rose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: CoustColors.lightPurple.withOpacity(0.3)),
        color: CoustColors.veryLightPurple,
      ),
      child: InkWell(
        onTap: () => _openInMaps(context),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CoustColors.primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: CoustColors.darkPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CoustColors.darkPurple,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address ?? 'Address not available',
                      style: TextStyle(
                        color: CoustColors.darkPurple.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(
                    'View Map',
                    style: TextStyle(
                      color: CoustColors.darkPurple.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: CoustColors.darkPurple.withOpacity(0.7),
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}