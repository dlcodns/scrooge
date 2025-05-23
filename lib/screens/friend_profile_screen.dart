import 'package:flutter/material.dart';

class FriendProfileScreen extends StatefulWidget {
  final String name;
  final String firstPreference;
  final String secondPreference;
  final String thirdPreference;
  final bool isFavorite;

  const FriendProfileScreen({
    super.key,
    required this.name,
    required this.firstPreference,
    required this.secondPreference,
    required this.thirdPreference,
    required this.isFavorite,
  });

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _popWithResult() {
    Navigator.pop(context, {
      'name': widget.name,
      'first': widget.firstPreference,
      'second': widget.secondPreference,
      'third': widget.thirdPreference,
      'isFavorite': _isFavorite,
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _popWithResult();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithResult,
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: _toggleFavorite,
              tooltip: _isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
            ),
          ],
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: Center(
          // ✅ 중앙 정렬
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // ✅ 중앙 정렬
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${widget.name} 님은 ${widget.firstPreference}을 제일 좋아해요',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),
                if (widget.secondPreference.isNotEmpty)
                  Text('2순위  ${widget.secondPreference}'),
                if (widget.thirdPreference.isNotEmpty)
                  Text('3순위  ${widget.thirdPreference}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
