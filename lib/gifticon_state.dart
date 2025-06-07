import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

class GifticonState extends ChangeNotifier {
  List<AssetEntity> gifticons = [];

  void update(List<AssetEntity> items) {
    gifticons = items;
    notifyListeners();
  }
}
