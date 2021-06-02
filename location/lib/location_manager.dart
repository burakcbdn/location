import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

/*
    Kullanmak için pubspec.yaml dosyasına 'geolocator: ^7.0.3' paketini ekleyin

    Android ayarlar

    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    Bu 3 izni andorid/src/main/AndroidManifest.xml dosyasında application tagının dışına ekleyin

    IOS ayarlar

    <key>NSLocationWhenInUseUsageDescription</key>
	  <string>This app needs access to location when open.</string>
	  <key>NSLocationAlwaysUsageDescription</key>
	  <string>This app needs access to location when in the background.</string>

    Bu 2 keyi ios/Runner/info.plist dosyasına ekleyin ve uygulamanın neden konum iznine gerek duyduğunu açıklayın

*/

class LocationManager {
  static bool locationEnabled;

  static LocationPermission permission;

  // bu değişkeni kullanıcıya uyarı göstermek için ya da 
  // konumun kullanılıp kullanılamayacığını tespit etmek için kullanabilirsiniz
  // Örnek kullanım:
  // LocationManager.canUseLocation
  // true ya da false değerini döndürür
  static bool get canUseLocation {
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Konum servislerini ayarlar.
  /// Bu fonksiyonu ana sayfanın initState metodunda veya main fonksiyonda çağırabilirsiniz
  // Örnek kullanım:
  // await LocationManager.initializeLocationServices()
  static Future initializeLocationServices() async {
    locationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!locationEnabled) {
      /// Konum bilgisi açık değil
      /// Kod içinde bu hatayı yakalayıp bir uyarı gösterilebilir.
      return Future.error("location-services-disabled");
    }

    permission = await Geolocator.checkPermission();

    // konum servisleri kabul edilmemişse izin isteniyor.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        /// Konum servisleri reddedildi kullanıcıya bir uyarı gösterebilirsiniz.
        return Future.error("permission-denied");
      }

      if (permission == LocationPermission.deniedForever) {
        /// konumlara hiçbir şekilde izin verilmediği için uygulama içinden tekrar izin istenemez.
        /// kullanıcıya bir uyarı gösterek manuel etkinleştirmesini ve izin vermesini sağlayabilirsiniz.
        return Future.error("denied-forever");
      }
    }
  }

  /// Pro appde konum pinlemek için kullanılacak fonksiyon
  /// örnek kullanım:
  /// await LocationManager.getCurrentPosition()
  static Future getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    /// Konum doğruluğu en iyiye ayarlı
    /// Aşağıdaki seçeneklerden birini parametre olarak verebilirsiniz
    // LocationAccuracy.lowest (Android 500m IOS 3000m)
    // LocationAccuracy.low (Android 500m IOS 1000m)
    // LocationAccuracy.medium (Android 100-500m IOS 100m)
    // LocationAccuracy.high (Android 0-100m IOS 10m)
    // LocationAccuracy.bestForNavigation (Android 0-100m IOS -)
    // LocationAccuray.best (Android 0-100m IOS ~0m)

    // Position objesinin latitute ve longitude parametresini kullanarak işlemlerinizi gerçekleştirebilirisniz

    return position;
  }

  // User appde konum değişiklerini dinlemek için kullanıcalak fonksiyon
  /// örnek kullanım:
  /// await LocationManager.getPositionListener((Position) {
  ///  // do sth with position...
  /// });
  static Future<StreamSubscription<Position>> getPositionListener(
      Function(Position) onPositionChanged) async {
    /// uygulamanın gerekli yerinde bu listeneri çağırıp gelen pozisyon bilgisinin parameterlerini kullanarak işlemleri yapabilirsiniz
    /// lat long dışında heading parametresi de mevcut işe yarayabilir

    return Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best, distanceFilter: 0,

      /// location change fonksiyonun tetiklenmesi için gereken minimum hareket miktarı (metre cinsinden)
    ).listen(onPositionChanged);
  }
  /// Örnek kullanım
  /// await LocationManager.forceSettings()
  static Future forceSettings() async {
    /// kullanıcı izinleri vermediyse uyarı vererek uygulama ayarlarına yönlendirebilirsiniz
    try {
      if (Platform.isIOS) {
        await Geolocator.openAppSettings();
      } else if (Platform.isAndroid) {
        Geolocator.openLocationSettings();
      }
    } on Exception catch (_) {
      await Geolocator.openAppSettings();
    } catch (_) {
      await Geolocator.openAppSettings();
    }
  }

  /// iki konum arasındaki mesafeyi metre cinsinden hesaplar
  /// Örnek kullanım:
  /// LocationManager.getDistanceBetweenLocations(
  ///  startLatitude: 34.75
  ///  startLongitude: 42.52
  ///  endLatitude: 38.33
  ///  endLongitude: 45.53
  /// );
  static double getDistanceBetweenLocations(
      {startLatitude, startLongitude, endLatitude, endLongitude}) {
    return Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
  }
}
