import 'package:flutter/material.dart';

import 'models/restroom.dart';
import 'screens/about_page.dart';
import 'screens/add_restroom_page.dart';
import 'screens/map_page.dart';
import 'screens/profile_page.dart';
import 'screens/rate_restroom_page.dart';
import 'screens/restroom_detail_page.dart';
import 'services/restroom_api_service.dart';
import 'utils/slide_route.dart';

void main() {
  runApp(const PottyPalApp());
}

class PottyPalApp extends StatelessWidget {
  final Future<List<Restroom>> Function()? restroomLoader;

  const PottyPalApp({super.key, this.restroomLoader});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PottyPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        useMaterial3: true,
      ),
      home: HomeScreen(restroomLoader: restroomLoader),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Future<List<Restroom>> Function()? restroomLoader;

  const HomeScreen({super.key, this.restroomLoader});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  int _selectedFilter = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _pageController = PageController();
  List<Restroom> _restrooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRestrooms();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Restroom> get _filtered {
    switch (_selectedFilter) {
      case 1:
        return _restrooms.where((r) => r.isOpen).toList();
      case 2:
        return [..._restrooms]..sort((a, b) => b.rating.compareTo(a.rating));
      default:
        return _restrooms;
    }
  }

  Future<void> _loadRestrooms({bool showLoading = true}) async {
    setState(() {
      if (showLoading) {
        _isLoading = true;
      }
      _errorMessage = null;
    });

    try {
      final loader = widget.restroomLoader ?? RestroomApiService.fetchRestrooms;
      final restrooms = await loader();

      if (!mounted) return;

      setState(() {
        _restrooms = restrooms;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load restroom data right now. $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery;
      return r.name.toLowerCase().contains(q) ||
          r.address.toLowerCase().contains(q) ||
          r.amenities.any((a) => a.toLowerCase().contains(q));
    }).toList();
    final openCount = _restrooms.where((r) => r.isOpen).length;
    final avgRating = _restrooms.isEmpty
        ? '0.0'
        : (_restrooms.fold(0.0, (s, r) => s + r.rating) / _restrooms.length)
              .toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        toolbarHeight: 64,
        titleSpacing: 8,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/pottypal-logo.webp', height: 70),
            const SizedBox(width: 5),
            const Text(
              'PottyPal',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 34,
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase().trim()),
                    decoration: const InputDecoration(
                      hintText: 'Search restrooms...',
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Icons.search, color: Colors.blueGrey),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  children: [
                    _StatCard(
                      icon: Icons.wc,
                      value: '${_restrooms.length}',
                      label: 'Nearby',
                      color: const Color(0xFF1565C0),
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.access_time,
                      value: '$openCount',
                      label: 'Open Now',
                      color: Colors.green[700]!,
                    ),
                    const SizedBox(width: 10),
                    _StatCard(
                      icon: Icons.star,
                      value: avgRating,
                      label: 'Avg Rating',
                      color: Colors.amber[700]!,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Restrooms Near You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[850],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChipWidget(
                            label: 'All',
                            index: 0,
                            selected: _selectedFilter,
                            onTap: (i) => setState(() => _selectedFilter = i),
                          ),
                          const SizedBox(width: 8),
                          _FilterChipWidget(
                            label: 'Open Now',
                            index: 1,
                            selected: _selectedFilter,
                            onTap: (i) => setState(() => _selectedFilter = i),
                          ),
                          const SizedBox(width: 8),
                          _FilterChipWidget(
                            label: 'Top Rated',
                            index: 2,
                            selected: _selectedFilter,
                            onTap: (i) => setState(() => _selectedFilter = i),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildRestroomContent(filtered)),
            ],
          ),
          const MapPage(),
          const AboutPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) {
          setState(() => _currentTab = i);
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1565C0),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Restrooms',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            slideRoute(page: const AddRestroomPage(), fromRight: true),
          );
          if (result != null && result is Restroom) {
            setState(() {
              _restrooms.add(result);
            });
          }
        },
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildRestroomContent(List<Restroom> filtered) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadRestrooms,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'No restroom results found from the API.',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadRestrooms(showLoading: false),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final restroom = filtered[index];
          final restroomIndex = _restrooms.indexWhere(
            (r) => identical(r, restroom),
          );

          return RestroomCard(
            restroom: restroom,
            onTap: () async {
              final result = await Navigator.push<Object?>(
                context,
                slideRoute(
                  page: RestroomDetailPage(restroom: restroom),
                  fromRight: true,
                ),
              );
              if (!context.mounted) return;
              if (result == 'deleted') {
                setState(() {
                  if (restroomIndex != -1) {
                    _restrooms.removeAt(restroomIndex);
                  }
                });
              } else if (result is Restroom) {
                setState(() {
                  if (restroomIndex != -1) {
                    _restrooms[restroomIndex] = result;
                  }
                });
              }
            },
          );
        },
      ),
    );
  }
}

class RestroomCard extends StatelessWidget {
  final Restroom restroom;
  final VoidCallback? onTap;

  const RestroomCard({super.key, required this.restroom, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          onTap ??
          () => Navigator.push(
            context,
            slideRoute(
              page: RestroomDetailPage(restroom: restroom),
              fromRight: true,
            ),
          ),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: restroom.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: Image(
                    image: restroom.imageProvider,
                    fit: BoxFit.cover,
                    alignment: restroom.imageAlignment,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restroom.distance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: restroom.isOpen ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          restroom.isOpen
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          restroom.isOpen ? 'Open' : 'Closed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        '${restroom.rating}  (${restroom.reviewCount})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restroom.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.bookmark_border,
                          color: Colors.blueGrey,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Color(0xFF1565C0),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restroom.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: restroom.amenities
                        .map((a) => _AmenityChip(label: a))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Getting directions to ${restroom.name}...',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions, size: 16),
                          label: const Text('Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            slideRoute(
                              page: RateRestroomPage(restroom: restroom),
                              fromRight: true,
                            ),
                          ),
                          icon: const Icon(Icons.star_outline, size: 16),
                          label: const Text('Rate'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            side: const BorderSide(color: Color(0xFF1565C0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final int index;
  final int selected;
  final void Function(int) onTap;

  const _FilterChipWidget({
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;

  const _AmenityChip({required this.label});

  static const Map<String, IconData> _icons = {
    'Bidet': Icons.water_drop,
    'Soap': Icons.soap,
    'Tissue': Icons.receipt_long,
    'Spacious': Icons.zoom_out_map,
    'Clean': Icons.cleaning_services,
    'Lock': Icons.lock,
    'PWD': Icons.accessible,
    'Accessible': Icons.accessible,
    'No Fee': Icons.money_off,
    'Free': Icons.money_off,
  };

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        _icons[label] ?? Icons.check_circle_outline,
        size: 14,
        color: const Color(0xFF1976D2),
      ),
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF1976D2), width: 0.8),
    );
  }
}
