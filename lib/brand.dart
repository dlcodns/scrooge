import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'time.dart';
import 'group.dart';
import 'brand_gallery.dart';
import 'screens/friend_list_screen.dart';
import 'trash_manage.dart';
import 'mypage.dart';

class BrandGalleryItem {
  final String brand;
  final String thumbnailUrl;

  BrandGalleryItem({required this.brand, required this.thumbnailUrl});
}

Widget _buildRoundedBox(
  BuildContext context,
  Widget destinationPage,
  int number,
) {
  String imagePath;
  Color boxColor = Colors.grey.shade300;

  if (number == 1) {
    imagePath = 'assets/group.png';
  } else if (number == 2) {
    imagePath = 'assets/time.png';
  } else {
    imagePath = 'assets/brand.png';
    boxColor = const Color(0xFF7081F1);
  }

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => destinationPage,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    },
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}

class Brand extends StatefulWidget {
  const Brand({super.key});

  @override
  State<Brand> createState() => _BrandState();
}

class _BrandState extends State<Brand> {
  List<BrandGalleryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchBrandGallery();
  }

  Future<void> _fetchBrandGallery() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwtToken');

    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://172.30.1.54:8080/api/brand-gallery'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List brands = data['brands'];

      final List<BrandGalleryItem> tempItems = [];

      for (final item in brands) {
        final brandName = item['brand'];
        final gifticonNumbers = item['gifticonNumbers'] as List<dynamic>;

        if (gifticonNumbers.isEmpty) continue;

        final thumbId = gifticonNumbers.first;
        final detailRes = await http.get(
          Uri.parse('http://172.30.1.54:8080/api/gifticon/$thumbId'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (detailRes.statusCode == 200) {
          final gifticonData = jsonDecode(detailRes.body);
          final imageUrl = gifticonData['imageUrl'] ?? '';
          final fullUrl = imageUrl.startsWith('http')
              ? imageUrl
              : 'http://172.30.1.54:8080$imageUrl';

          tempItems.add(BrandGalleryItem(brand: brandName, thumbnailUrl: fullUrl));
        }
      }

      setState(() {
        _items = tempItems;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double itemSize = MediaQuery.of(context).size.width / 3.5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Image.asset('assets/trash.png'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TrashScreen()),
                  );
                },
              ),
              IconButton(
                icon: Image.asset('assets/heart.png'),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
              IconButton(
                icon: Image.asset('assets/account.png'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyPageScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildRoundedBox(context, Group(), 1),
                const SizedBox(width: 8),
                _buildRoundedBox(context, const Time(), 2),
                const SizedBox(width: 8),
                _buildRoundedBox(context, const Brand(), 3),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
                children: _items.map((item) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrandGalleryPage(brandName: item.brand),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Image.network(
                            item.thumbnailUrl,
                            width: itemSize,
                            height: itemSize,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.brand,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Center(
                  child: Image.asset('assets/conGall.png', height: 20),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FriendListScreen()),
                  );
                },
                child: Center(
                  child: Image.asset('assets/friendList.png', height: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
