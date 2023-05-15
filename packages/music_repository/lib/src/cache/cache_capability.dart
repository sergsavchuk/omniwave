import 'package:common_models/common_models.dart';

mixin CacheCapability {
  Future<bool> albumsCacheOutdated(List<Album> albumsCache);
}
