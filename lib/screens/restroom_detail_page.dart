import 'package:flutter/material.dart';
import '../models/restroom.dart';
import '../utils/slide_route.dart';
import 'rate_restroom_page.dart';
import 'edit_restroom_page.dart';

class RestroomDetailPage extends StatelessWidget {
  final Restroom restroom;
  const RestroomDetailPage({super.key, required this.restroom});

  static const Map<String, IconData> _amenityIcons = {
    'Soap': Icons.soap,
    'Tissue': Icons.receipt_long,
    'Spacious': Icons.zoom_out_map,
    'PWD': Icons.accessible,
    'PWD Friendly': Icons.accessible,
    'Bidet': Icons.water_drop,
    'Clean': Icons.cleaning_services,
    'Lock': Icons.lock,
    'Accessible': Icons.accessible,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          restroom.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push<Object?>(
                context,
                slideRoute(
                  page: EditRestroomPage(restroom: restroom),
                  fromRight: true,
                ),
              );
              if (context.mounted) {
                if (result == 'deleted') {
                  Navigator.pop(context, 'deleted');
                } else if (result is Restroom) {
                  Navigator.pop(context, result);
                }
              }
            },
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Edit Restroom',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 240,
              width: double.infinity,
              child: Image(
                image: restroom.imageProvider,
                fit: BoxFit.cover,
                alignment: restroom.imageAlignment,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restroom.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < restroom.rating.toInt()
                              ? Colors.amber
                              : Colors.grey.shade300,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${restroom.rating}  (${restroom.reviewCount})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF1565C0),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              restroom.address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = constraints.maxWidth < 330
                              ? 52.0
                              : constraints.maxWidth < 420
                              ? 60.0
                              : 64.0;
                          final circleSize = constraints.maxWidth < 330
                              ? 44.0
                              : 52.0;
                          final iconSize = constraints.maxWidth < 330
                              ? 18.0
                              : 20.0;

                          return Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                [
                                  'Soap',
                                  'Tissue',
                                  'Spacious',
                                  'PWD',
                                  'Bidet',
                                  'Clean',
                                  'Lock',
                                  'Accessible',
                                ].map((amenity) {
                                  final isAvailable = restroom.amenities.any(
                                    (a) =>
                                        a.toLowerCase() ==
                                        amenity.toLowerCase(),
                                  );
                                  return SizedBox(
                                    width: itemWidth,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: circleSize,
                                          height: circleSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isAvailable
                                                  ? const Color(0xFF1565C0)
                                                  : Colors.grey.shade300,
                                              width: 2,
                                            ),
                                            color: isAvailable
                                                ? const Color(0xFF1565C0)
                                                : Colors.transparent,
                                          ),
                                          child: Icon(
                                            _amenityIcons[amenity] ??
                                                Icons.check_circle_outline,
                                            color: isAvailable
                                                ? Colors.white
                                                : Colors.grey.shade400,
                                            size: iconSize,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          amenity,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: isAvailable
                                                ? Colors.black87
                                                : Colors.grey.shade400,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          3,
                          (index) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade200,
                            ),
                            child: Image(
                              image: restroom.imageProvider,
                              fit: BoxFit.cover,
                              alignment: restroom.imageAlignment,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Get Directions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            slideRoute(
                              page: RateRestroomPage(restroom: restroom),
                              fromRight: true,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1565C0),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                              color: Color(0xFF1565C0),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Rate Restroom',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
