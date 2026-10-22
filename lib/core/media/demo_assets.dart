/// Central registry of the bundled demo pictures.
///
/// These assets were downloaded from freely-licensed photo sources to give the
/// UI a realistic, commercial feel. When the backend exposes real Cloudinary
/// URLs, products carry their own `imageUrl`; the bundled assets below are only
/// a fallback so the app never displays a bare icon placeholder.
abstract final class DemoAssets {
  static const String supplierDashboardHero =
      'assets/images/misc/farm_hero.jpg';
  static const String supplierProfilePhoto =
      'assets/images/misc/farm_profile.jpg';

  /// Hero picture used on the supplier dashboard header.
  static const String dashboardHero = supplierDashboardHero;

  /// Per-product demo photos, keyed by product id when available.
  static String? photoForProduct(String? id) => switch (id) {
    'p_1001' ||
    'p_3001' ||
    'p_3007' ||
    'p_3022' => 'assets/images/products/tomates.jpg',
    'p_1002' || 'p_3002' || 'p_3026' => 'assets/images/products/oignons.jpg',
    'p_1003' ||
    'p_3003' ||
    'p_3012' ||
    'p_3013' => 'assets/images/products/manioc.jpg',
    'p_1004' || 'p_3015' || 'p_3016' => 'assets/images/products/arachides.jpg',
    'p_1005' ||
    'p_3006' ||
    'p_3014' ||
    'p_1010' => 'assets/images/products/piment.jpg',
    'p_3004' => 'assets/images/products/riz.jpg',
    'p_3005' ||
    'p_3010' ||
    'p_3011' ||
    'p_3017' ||
    'p_3018' ||
    'p_3019' ||
    'p_1009' => 'assets/images/products/ananas.jpg',
    'p_3020' || 'p_3021' => 'assets/images/products/avocat.jpg',
    'p_3008' || 'p_3009' || 'p_1007' => 'assets/images/products/mais.jpg',
    _ => null,
  };

  /// Whether a reference is a remote URL (Cloudinary / backend) or a bundled
  /// asset. Bundled assets are served through [AssetImage], remote ones via
  /// [NetworkImage].
  static bool isRemote(String reference) =>
      reference.startsWith('http://') || reference.startsWith('https://');
}
