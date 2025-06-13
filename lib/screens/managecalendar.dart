import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color(0xFFF5F5F8),
      body: RefreshIndicator(
        color: const Color(0xFF6418C3),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6418C3), Color(0xFF8547D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),
            offset: Offset(0, 3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "My Properties",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x15000000),
                    offset: Offset(0, 2),
                    blurRadius: 6,
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
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF6418C3).withOpacity(0.7),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
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
                    vertical: 15,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.house_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLoggedIn
                ? (_searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : 'You haven\'t added any properties yet')
                : 'Please login to view your properties',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (isLoggedIn && _searchQuery.isEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/addproperty');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Property'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6418C3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/hallscalendar',
                arguments: {'property': property, 'isVendor': true},
              );
            },
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
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.business,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
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
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6418C3).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.meeting_room,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.propertyName ?? 'No Name',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF6418C3),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.address ?? 'No Address',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPropertyFeatures(),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            '/hallscalendar',
                            arguments: {'property': property, 'isVendor': true},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF6418C3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(
                          "Book Halls",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
      height: 200,
      width: double.infinity,
      color: Colors.grey[200],
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6418C3)),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  "Image not available",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      )
          : Center(
        child: Icon(
          Icons.image,
          color: Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }

  Widget _buildPropertyFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureItem(Icons.group, "Capacity"),
        _buildFeatureItem(Icons.local_parking, "Parking"),
        _buildFeatureItem(Icons.restaurant, "Food"),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6418C3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6418C3).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF6418C3),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}