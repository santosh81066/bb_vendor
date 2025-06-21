import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bb_vendor/Colors/coustcolors.dart';
import '../models/get_properties_model.dart';
import '../providers/addpropertynotifier.dart';
import '../providers/auth.dart'; // Import auth provider

class VendorVenueScreen extends ConsumerStatefulWidget {
  const VendorVenueScreen({super.key});

  @override
  ConsumerState<VendorVenueScreen> createState() => _VendorVenueScreenState();
}

class _VendorVenueScreenState extends ConsumerState<VendorVenueScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load data with error handling
    try {
      ref.read(propertyNotifierProvider.notifier).getproperty();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyState = ref.watch(propertyNotifierProvider).data ?? [];
    final authState = ref.watch(authprovider);
    final currentUserId = authState.data?.userId;

    // Filter properties that belong to the current vendor only
    final vendorProperties = propertyState.where((property) {
      // First check if this property belongs to the current vendor
      final belongsToVendor = property.vendorId != null &&
          currentUserId != null &&
          property.vendorId == currentUserId;

      if (!belongsToVendor) return false;

      // Then apply search filter if one exists
      final matchesSearch = _searchQuery.isEmpty ||
          (property.propertyName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (property.address?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      return matchesSearch;
    }).toList();

    // Sort properties by property name
    vendorProperties.sort((a, b) =>
        (a.propertyName ?? '').compareTo(b.propertyName ?? ''));

    return Scaffold(
      backgroundColor: CoustColors.veryLightPurple,
      body: RefreshIndicator(
        color: CoustColors.primaryPurple,
        backgroundColor: Colors.white,
        strokeWidth: 3,
        onRefresh: () async {
          try {
            await ref.read(propertyNotifierProvider.notifier).getproperty();
          } catch (e) {
            debugPrint('Error refreshing data: $e');
          }
        },
        child: SizedBox(
          child: CustomScrollView(
            slivers: [
              // App Bar with Search
              SliverToBoxAdapter(
                child: _buildAppBarWithSearch(),
              ),

              // Main Content
              vendorProperties.isNotEmpty
                  ? SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: AnimationLimiter(
                  child: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: VendorPropertyCard(
                                property: vendorProperties[index],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: vendorProperties.length,
                    ),
                  ),
                ),
              )
                  : SliverFillRemaining(
                child: _buildEmptyState(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarWithSearch() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            CoustColors.gradientStart,
            CoustColors.gradientMiddle,
            CoustColors.gradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.3),
            offset: const Offset(0, 5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                "My Properties",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: CoustColors.lightPurple.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CoustColors.darkPurple.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search my properties...',
                  hintStyle: GoogleFonts.poppins(
                    color: CoustColors.darkPurple.withOpacity(0.4),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: CoustColors.primaryPurple.withOpacity(0.7),
                    size: 24,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: CoustColors.darkPurple.withOpacity(0.5),
                    ),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final authState = ref.watch(authprovider);
    final isLoggedIn = authState.data?.userId != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CoustColors.lightPurple.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CoustColors.lightPurple.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.house_outlined,
                size: 64,
                color: CoustColors.darkPurple.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No properties found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CoustColors.darkPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isLoggedIn
                  ? (_searchQuery.isNotEmpty
                  ? 'Try adjusting your search terms'
                  : 'You haven\'t added any properties yet')
                  : 'Please login to view your properties',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: CoustColors.darkPurple.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (isLoggedIn && _searchQuery.isEmpty) ...[
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CoustColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/addproperty');
                  },
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: const Text(
                    'Add Property',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CoustColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class VendorPropertyCard extends StatelessWidget {
  final Data property;

  const VendorPropertyCard({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CoustColors.lightPurple.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CoustColors.primaryPurple.withOpacity(0.12),
            offset: const Offset(0, 6),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/hallscalendar',
                arguments: {'property': property, 'isVendor': true},
              );
            },
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'property_image_${property.propertyId}',
                      child: _buildPropertyImage(),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [CoustColors.emerald, CoustColors.teal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: CoustColors.emerald.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "My Property",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [CoustColors.primaryPurple, CoustColors.accentPurple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: CoustColors.primaryPurple.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.meeting_room_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${property.halls?.length ?? 0}",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.propertyName ?? 'No Name',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: CoustColors.darkPurple,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: CoustColors.primaryPurple,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              property.address ?? 'No Address',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: CoustColors.darkPurple.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPropertyFeatures(),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: CoustColors.primaryPurple.withOpacity(0.25),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/hallscalendar',
                              arguments: {'property': property, 'isVendor': true},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: CoustColors.primaryPurple,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          child: Text(
                            "View & Book Halls",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyImage() {
    final imageUrl = property.coverPic != null
        ? 'http://www.gocodedesigners.com/banquetbookingz/${property.coverPic}'
        : null;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: CoustColors.veryLightPurple,
        border: Border(
          bottom: BorderSide(
            color: CoustColors.lightPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: imageUrl != null
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: AlwaysStoppedAnimation<Color>(CoustColors.primaryPurple),
              strokeWidth: 3,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_rounded,
                  color: CoustColors.darkPurple.withOpacity(0.4),
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  "Image not available",
                  style: GoogleFonts.poppins(
                    color: CoustColors.darkPurple.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_rounded,
              color: CoustColors.darkPurple.withOpacity(0.4),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              "No image",
              style: GoogleFonts.poppins(
                color: CoustColors.darkPurple.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyFeatures() {
    final features = [
      {'icon': Icons.group_rounded, 'text': 'Capacity', 'color': CoustColors.teal},
      {'icon': Icons.local_parking_rounded, 'text': 'Parking', 'color': CoustColors.magenta},
      {'icon': Icons.restaurant_rounded, 'text': 'Food', 'color': CoustColors.gold},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features
          .map((feature) => _buildFeatureItem(
        feature['icon'] as IconData,
        feature['text'] as String,
        feature['color'] as Color,
      ))
          .toList(),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.15),
            accentColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: CoustColors.darkPurple.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}