class City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory City.fromJson(Map<String, dynamic> json) => City(
    name: json['name'] as String,
    country: json['country'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          country == other.country;

  @override
  int get hashCode => name.hashCode ^ country.hashCode;
}

const City defaultCity = City(
  name: 'İstanbul',
  country: 'Türkiye',
  latitude: 41.0082,
  longitude: 28.9784,
);

final List<City> allPredefinedCities = [
  // Türkiye 81 İl
  const City(name: 'Adana', country: 'Türkiye', latitude: 37.0000, longitude: 35.3213),
  const City(name: 'Adıyaman', country: 'Türkiye', latitude: 37.7648, longitude: 38.2786),
  const City(name: 'Afyonkarahisar', country: 'Türkiye', latitude: 38.7507, longitude: 30.5567),
  const City(name: 'Ağrı', country: 'Türkiye', latitude: 39.7191, longitude: 43.0503),
  const City(name: 'Aksaray', country: 'Türkiye', latitude: 38.3687, longitude: 34.0370),
  const City(name: 'Amasya', country: 'Türkiye', latitude: 40.6534, longitude: 35.8331),
  const City(name: 'Ankara', country: 'Türkiye', latitude: 39.9334, longitude: 32.8597),
  const City(name: 'Antalya', country: 'Türkiye', latitude: 36.8969, longitude: 30.7133),
  const City(name: 'Ardahan', country: 'Türkiye', latitude: 41.1105, longitude: 42.7022),
  const City(name: 'Artvin', country: 'Türkiye', latitude: 41.1828, longitude: 41.8183),
  const City(name: 'Aydın', country: 'Türkiye', latitude: 37.8560, longitude: 27.8416),
  const City(name: 'Balıkesir', country: 'Türkiye', latitude: 39.6484, longitude: 27.8826),
  const City(name: 'Bartın', country: 'Türkiye', latitude: 41.6344, longitude: 32.3375),
  const City(name: 'Batman', country: 'Türkiye', latitude: 37.8812, longitude: 41.1293),
  const City(name: 'Bayburt', country: 'Türkiye', latitude: 40.2552, longitude: 40.2249),
  const City(name: 'Bilecik', country: 'Türkiye', latitude: 40.1451, longitude: 29.9799),
  const City(name: 'Bingöl', country: 'Türkiye', latitude: 38.8854, longitude: 40.4983),
  const City(name: 'Bitlis', country: 'Türkiye', latitude: 38.4006, longitude: 42.1095),
  const City(name: 'Bolu', country: 'Türkiye', latitude: 40.7350, longitude: 31.6061),
  const City(name: 'Burdur', country: 'Türkiye', latitude: 37.7203, longitude: 30.2908),
  const City(name: 'Bursa', country: 'Türkiye', latitude: 40.1885, longitude: 29.0610),
  const City(name: 'Çanakkale', country: 'Türkiye', latitude: 40.1553, longitude: 26.4142),
  const City(name: 'Çankırı', country: 'Türkiye', latitude: 40.6013, longitude: 33.6134),
  const City(name: 'Çorum', country: 'Türkiye', latitude: 40.5506, longitude: 34.9556),
  const City(name: 'Denizli', country: 'Türkiye', latitude: 37.7765, longitude: 29.0864),
  const City(name: 'Diyarbakır', country: 'Türkiye', latitude: 37.9144, longitude: 40.2306),
  const City(name: 'Düzce', country: 'Türkiye', latitude: 40.8438, longitude: 31.1565),
  const City(name: 'Edirne', country: 'Türkiye', latitude: 41.6772, longitude: 26.5557),
  const City(name: 'Elazığ', country: 'Türkiye', latitude: 38.6810, longitude: 39.2264),
  const City(name: 'Erzincan', country: 'Türkiye', latitude: 39.7500, longitude: 39.5000),
  const City(name: 'Erzurum', country: 'Türkiye', latitude: 39.9043, longitude: 41.2678),
  const City(name: 'Eskişehir', country: 'Türkiye', latitude: 39.7767, longitude: 30.5206),
  const City(name: 'Gaziantep', country: 'Türkiye', latitude: 37.0662, longitude: 37.3833),
  const City(name: 'Giresun', country: 'Türkiye', latitude: 40.9128, longitude: 38.3895),
  const City(name: 'Gümüşhane', country: 'Türkiye', latitude: 40.4600, longitude: 39.4700),
  const City(name: 'Hakkari', country: 'Türkiye', latitude: 37.5833, longitude: 43.7333),
  const City(name: 'Hatay', country: 'Türkiye', latitude: 36.4018, longitude: 36.3498),
  const City(name: 'Iğdır', country: 'Türkiye', latitude: 39.9196, longitude: 44.0450),
  const City(name: 'Isparta', country: 'Türkiye', latitude: 37.7648, longitude: 30.5566),
  const City(name: 'İstanbul', country: 'Türkiye', latitude: 41.0082, longitude: 28.9784),
  const City(name: 'İzmir', country: 'Türkiye', latitude: 38.4192, longitude: 27.1287),
  const City(name: 'Kahramanmaraş', country: 'Türkiye', latitude: 37.5858, longitude: 36.9371),
  const City(name: 'Karabük', country: 'Türkiye', latitude: 41.2061, longitude: 32.6204),
  const City(name: 'Karaman', country: 'Türkiye', latitude: 37.1759, longitude: 33.2287),
  const City(name: 'Kars', country: 'Türkiye', latitude: 40.6167, longitude: 43.1000),
  const City(name: 'Kastamonu', country: 'Türkiye', latitude: 41.3887, longitude: 33.7827),
  const City(name: 'Kayseri', country: 'Türkiye', latitude: 38.7312, longitude: 35.4787),
  const City(name: 'Kilis', country: 'Türkiye', latitude: 36.7184, longitude: 37.1212),
  const City(name: 'Kırıkkale', country: 'Türkiye', latitude: 39.8468, longitude: 33.5153),
  const City(name: 'Kırklareli', country: 'Türkiye', latitude: 41.7333, longitude: 27.2167),
  const City(name: 'Kırşehir', country: 'Türkiye', latitude: 39.1425, longitude: 34.1709),
  const City(name: 'Kocaeli', country: 'Türkiye', latitude: 40.8533, longitude: 29.8815),
  const City(name: 'Konya', country: 'Türkiye', latitude: 37.8667, longitude: 32.4833),
  const City(name: 'Kütahya', country: 'Türkiye', latitude: 39.4167, longitude: 29.9833),
  const City(name: 'Malatya', country: 'Türkiye', latitude: 38.3552, longitude: 38.3095),
  const City(name: 'Manisa', country: 'Türkiye', latitude: 38.6191, longitude: 27.4289),
  const City(name: 'Mardin', country: 'Türkiye', latitude: 37.3212, longitude: 40.7245),
  const City(name: 'Mersin', country: 'Türkiye', latitude: 36.8000, longitude: 34.6333),
  const City(name: 'Muğla', country: 'Türkiye', latitude: 37.2153, longitude: 28.3636),
  const City(name: 'Muş', country: 'Türkiye', latitude: 38.7432, longitude: 41.5064),
  const City(name: 'Nevşehir', country: 'Türkiye', latitude: 38.6244, longitude: 34.7142),
  const City(name: 'Niğde', country: 'Türkiye', latitude: 37.9667, longitude: 34.6833),
  const City(name: 'Ordu', country: 'Türkiye', latitude: 40.9839, longitude: 37.8764),
  const City(name: 'Osmaniye', country: 'Türkiye', latitude: 37.0742, longitude: 36.2472),
  const City(name: 'Rize', country: 'Türkiye', latitude: 41.0201, longitude: 40.5234),
  const City(name: 'Sakarya', country: 'Türkiye', latitude: 40.7569, longitude: 30.3783),
  const City(name: 'Samsun', country: 'Türkiye', latitude: 41.2928, longitude: 36.3313),
  const City(name: 'Şanlıurfa', country: 'Türkiye', latitude: 37.1591, longitude: 38.7969),
  const City(name: 'Siirt', country: 'Türkiye', latitude: 37.9333, longitude: 41.9500),
  const City(name: 'Sinop', country: 'Türkiye', latitude: 42.0231, longitude: 35.1531),
  const City(name: 'Şırnak', country: 'Türkiye', latitude: 37.5164, longitude: 42.4611),
  const City(name: 'Sivas', country: 'Türkiye', latitude: 39.7477, longitude: 37.0179),
  const City(name: 'Tekirdağ', country: 'Türkiye', latitude: 40.9833, longitude: 27.5167),
  const City(name: 'Tokat', country: 'Türkiye', latitude: 40.3167, longitude: 36.5500),
  const City(name: 'Trabzon', country: 'Türkiye', latitude: 41.0015, longitude: 39.7178),
  const City(name: 'Tunceli', country: 'Türkiye', latitude: 39.1079, longitude: 39.5401),
  const City(name: 'Uşak', country: 'Türkiye', latitude: 38.6823, longitude: 29.4082),
  const City(name: 'Van', country: 'Türkiye', latitude: 38.4891, longitude: 43.4089),
  const City(name: 'Yalova', country: 'Türkiye', latitude: 40.6550, longitude: 29.2769),
  const City(name: 'Yozgat', country: 'Türkiye', latitude: 39.8181, longitude: 34.8147),
  const City(name: 'Zonguldak', country: 'Türkiye', latitude: 41.4564, longitude: 31.7987),

  // İslam Dünyası & Dünya Şehirleri
  const City(name: 'Mekke-i Mükerreme', country: 'Suudi Arabistan', latitude: 21.4225, longitude: 39.8262),
  const City(name: 'Medine-i Münevvere', country: 'Suudi Arabistan', latitude: 24.5247, longitude: 39.5692),
  const City(name: 'Kudüs (Mescid-i Aksa)', country: 'Filistin', latitude: 31.7767, longitude: 35.2345),
  const City(name: 'Lefkoşa', country: 'KKTC', latitude: 35.1856, longitude: 33.3823),
  const City(name: 'Bakü', country: 'Azerbaycan', latitude: 40.4093, longitude: 49.8671),
  const City(name: 'Saraybosna', country: 'Bosna-Hersek', latitude: 43.8563, longitude: 18.4131),
  const City(name: 'Üsküp', country: 'Kuzey Makedonya', latitude: 41.9973, longitude: 21.4280),
  const City(name: 'Berlin', country: 'Almanya', latitude: 52.5200, longitude: 13.4050),
  const City(name: 'Köln', country: 'Almanya', latitude: 50.9375, longitude: 6.9603),
  const City(name: 'Londra', country: 'Birleşik Krallık', latitude: 51.5074, longitude: -0.1278),
  const City(name: 'Paris', country: 'Fransa', latitude: 48.8566, longitude: 2.3522),
  const City(name: 'Viyana', country: 'Avusturya', latitude: 48.2082, longitude: 16.3738),
  const City(name: 'New York', country: 'ABD', latitude: 40.7128, longitude: -74.0060),
];
