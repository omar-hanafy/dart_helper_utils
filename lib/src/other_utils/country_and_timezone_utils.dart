// ignore_for_file: depend_on_referenced_packages

/// This file contains a collection of globally accessible constants and utility
/// functions that can be used throughout your Dart project.
library;

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:meta/meta.dart';

/// Represents a currency with its code, name, and symbol.
/// For example, (code: "USD", name: "United States dollar", symbol: "$").
typedef Currency = ({String code, String name, String symbol});

/// Represents a native name of the country in different languages.
/// For example, (language: "eng", official: "Republic of Zimbabwe", common: "Zimbabwe").
typedef NativeName = ({String language, String official, String common});

/// Represents a language with its code and name.
/// For example, (code: "en", name: "English").
typedef Language = ({String code, String name});

/// A type for country search algorithms that takes a list of countries and a query string,
/// and returns a filtered list of countries.
typedef CountrySearchAlgorithm = List<DHUCountry> Function(
  List<DHUCountry> countries,
  String query,
);

/// Represents geographical coordinates with latitude and longitude.
/// For example, (latitude: -20.0, longitude: 30.0).
typedef Coordinates = ({double latitude, double longitude});

/// Top-level codec helpers
Coordinates coordinatesFromJson(Map<String, dynamic> json) {
  final lat = json.getDouble('latitude', alternativeKeys: ['lat']);
  final lon = json.getDouble('longitude', alternativeKeys: ['lon']);
  return (latitude: lat, longitude: lon);
}

/// toJson methods on the Coordinates record via an extension
extension CoordinatesOps on Coordinates {
  /// Converts the [Coordinates] object to a JSON map representation.
  ///
  /// Returns a [Map] containing the latitude and longitude values.
  /// For example: {'latitude': -20.0, 'longitude': 30.0}
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

/// A class representing country information including names, codes, region, and other details.
@immutable
class DHUCountry {
  /// Creates a [DHUCountry] object with the given data.
  ///
  /// This constructor is used to initialize a country with various attributes such as names, codes, currencies, languages, etc.
  const DHUCountry({
    required this.commonName,
    required this.officialName,
    required this.nativeNames,
    required this.iso2,
    required this.iso3,
    required this.phoneCode,
    required this.region,
    required this.subregion,
    required this.coordinates,
    required this.capital,
    required this.currencies,
    required this.languages,
    required this.flagEmoji,
    required this.borders,
    required this.tld,
    required this.area,
    required this.timezones,
  });

  /// Creates a [DHUCountry] object from a [Map] of key-value pairs.
  ///
  /// The map should include various country attributes like `commonName`, `iso2`, `region`, etc.
  factory DHUCountry.fromMap(Map<String, dynamic> map) {
    final nativeNames = toMap<String, dynamic>(map['nativeNames']);
    final currencies = toMap<String, dynamic>(map['currencies']);
    final coordinates = toList<dynamic>(map['latlng']);
    return DHUCountry(
      commonName: toText(map['commonName']),
      officialName: toText(map['officialName']),
      nativeNames: nativeNames.entries.map((entry) {
        final data = toMap<String, dynamic>(entry.value);
        return (
          language: toText(entry.key),
          official: toText(data['official']),
          common: toText(data['common']),
        );
      }).toList(),
      iso2: toText(map['iso2']),
      iso3: toText(map['iso3']),
      phoneCode: toText(map['phoneCode']),
      region: toText(map['region']),
      subregion: toText(map['subregion']),
      coordinates: (
        latitude: toDouble(coordinates[0]),
        longitude: toDouble(coordinates[1]),
      ),
      capital: tryToText(map['capital']),
      currencies: currencies.entries.map((map) {
        final currency = toMap<String, dynamic>(map.value);
        return (
          code: toText(map.value),
          name: toText(currency['name']),
          symbol: toText(currency['symbol']),
        );
      }).toList(),
      languages: toMap<String, String>(map['languages'])
          .entries
          .map((map) => (code: map.key, name: map.value))
          .toList(),
      flagEmoji: toText(map['flag']),
      borders: toList<String>(map['borders']),
      tld: toText(map['tld']),
      area: toDouble(map['area']),
      timezones: toList<String>(map['timezones']),
    );
  }

  /// The commonly used name of the country.
  /// For example, "Zimbabwe".
  final String commonName;

  /// The official name of the country as recognized in formal contexts.
  /// For example, "Republic of Zimbabwe".
  final String officialName;

  /// A list of native names in different languages.
  /// Each entry includes the language code, official name, and common name.
  final List<NativeName> nativeNames;

  /// The ISO 3166-1 alpha-2 code representing the country.
  /// For example, "ZW" for Zimbabwe.
  final String iso2;

  /// The ISO 3166-1 alpha-3 code representing the country.
  /// For example, "ZWE" for Zimbabwe.
  final String iso3;

  /// The international phone calling code of the country.
  /// For example, +263 for Zimbabwe.
  final String phoneCode;

  /// The general geographical region where the country is located.
  /// For example, "Africa".
  final String region;

  /// The more specific subregion within the continent or region.
  /// For example, "Eastern Africa".
  final String subregion;

  /// Geographical coordinates representing the country's location.
  /// Contains latitude and longitude values.
  final Coordinates coordinates;

  /// The capital city of the country.
  /// For example, "Harare" for Zimbabwe.
  final String? capital;

  /// A list of currencies used in the country.
  /// Each currency includes its code, name, and symbol.
  final List<Currency> currencies;

  /// A list of languages spoken in the country, each with its code and name.
  final List<Language> languages;

  /// The flag emoji representing the country visually.
  /// For example, "🇿🇼" for Zimbabwe.
  final String flagEmoji;

  /// A list of ISO codes representing countries that border this country.
  /// For example, ["BWA", "MOZ", "ZAF", "ZMB"] for Zimbabwe.
  final List<String> borders;

  /// The top-level internet domain associated with the country.
  /// For example, ".zw" for Zimbabwe.
  final String tld;

  /// The total area of the country in square kilometers.
  /// For example, 390757 for Zimbabwe.
  final double area;

  /// A list of time zones applicable to the country.
  /// For example, ["Africa/Cairo"].
  final List<String> timezones;

  /// Returns a list of detailed timezone information for the country.
  List<DHUTimezone> getTimezonesDetails() {
    final tz = getTimezonesRawData();
    final list = <DHUTimezone>[];
    for (final e in timezones) {
      final founded = tz[e];
      if (founded != null) list.add(DHUTimezone.fromMap(founded));
    }
    return list;
  }

  /// Generates a list of [DHUCountry] objects from raw data.
  static List<DHUCountry> generate([
    List<Map<String, dynamic>>? rawData,
  ]) =>
      (rawData ?? getRawCountriesData()).map(DHUCountry.fromMap).toList();

  /// Fetches a country by its name.
  ///
  /// Returns the first matching country based on common name, official name, or native names.
  static DHUCountry? getByName(
    String name, [
    List<Map<String, dynamic>>? rawData,
  ]) {
    final countries = rawData ?? getRawCountriesData();
    final cName = name.toLowerCase();

    // Find the first match in the country list
    final map = countries.firstWhereOrNull((country) {
      // Check commonName and officialName
      final commonName = tryToText(country['commonName'])?.toLowerCase();
      final officialName = tryToText(country['officialName'])?.toLowerCase();

      // Check if any native names match
      final nativeNames =
          tryToMap<String, Map<String, String>>(country['nativeNames']) ?? {};
      final nativeMatch = nativeNames.values.any((native) {
        final nativeCommon = tryToText(native['common'])?.toLowerCase();
        final nativeOfficial = tryToText(native['official'])?.toLowerCase();
        return nativeCommon == cName || nativeOfficial == cName;
      });

      // Return true if any name matches
      return commonName == cName || officialName == cName || nativeMatch;
    });

    return map == null ? null : DHUCountry.fromMap(map);
  }

  /// Fetches a country by its ISO code (either ISO2 or ISO3).
  static DHUCountry? getByCode(
    String iso, [
    List<Map<String, dynamic>>? rawData,
  ]) {
    final countries = rawData ?? getRawCountriesData();
    final isoCode = iso.toUpperCase();

    // Find the first country where the ISO code matches either iso2 or iso3
    final map = countries.firstWhereOrNull((country) {
      final iso2 = tryToText(country['iso2'])?.toUpperCase();
      final iso3 = tryToText(country['iso3'])?.toUpperCase();

      return iso2 == isoCode || iso3 == isoCode;
    });

    return map == null ? null : DHUCountry.fromMap(map);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DHUCountry &&
          runtimeType == other.runtimeType &&
          iso2 == other.iso2 &&
          iso3 == other.iso3;

  @override
  int get hashCode => iso2.hashCode ^ iso3.hashCode;
}

/// A dart helper util class representing timezone information including the timezone name,
/// raw offset, abbreviation, and daylight saving time (DST) offset.
@immutable
class DHUTimezone {
  /// Creates a [DHUTimezone] object with the given data.
  const DHUTimezone({
    required this.timezone,
    required this.rawOffset,
    required this.abbreviation,
    required this.dstOffset,
  });

  /// Creates a [DHUTimezone] object from a [Map] of key-value pairs.
  ///
  /// The map should contain the keys:
  /// - `timezone`: The name of the timezone.
  /// - `raw_offset`: The raw offset from UTC in seconds.
  /// - `abbreviation`: The timezone abbreviation.
  /// - `dst_offset`: The DST offset in seconds.
  factory DHUTimezone.fromMap(Map<String, dynamic> map) {
    return DHUTimezone(
      timezone: toText(map['timezone']),
      rawOffset: toInt(map['raw_offset']),
      abbreviation: toText(map['abbreviation']),
      dstOffset: toInt(map['dst_offset']),
    );
  }

  /// The name of the timezone in IANA format.
  /// For example, "Africa/Maputo".
  final String timezone;

  /// The raw offset from UTC in seconds without considering DST.
  /// For example, 7200 means the timezone is 2 hours ahead of UTC.
  final int rawOffset;

  /// The abbreviation of the timezone.
  /// For example, "CAT" stands for Central Africa Time.
  final String abbreviation;

  /// The offset in seconds during Daylight Saving Time (DST).
  /// For example, 0 if DST is not observed.
  final int dstOffset;

  /// Returns a list of countries that use this timezone.
  List<DHUCountry> getCountries() {
    final countriesMap = getRawCountriesData();
    final matchingCountries = <DHUCountry>[];

    for (final map in countriesMap) {
      final tz = toList<String>(map['timezones']);
      if (tz.contains(timezone)) {
        matchingCountries.add(DHUCountry.fromMap(map));
      }
    }

    return matchingCountries;
  }

  /// generates a list of [DHUTimezone] objects from raw data.
  static List<DHUTimezone> generate([
    Map<String, Map<String, dynamic>>? rawData,
  ]) =>
      (rawData ?? getTimezonesRawData())
          .values
          .map(DHUTimezone.fromMap)
          .toList();

  /// Gets timezone by identifier, e.g., 'Africa/Cairo'.
  static DHUTimezone? byIdentifier(
    String timezone, [
    Map<String, Map<String, dynamic>>? rawData,
  ]) {
    final tz = (rawData ?? getTimezonesRawData())[timezone];
    if (tz == null) return null;
    return DHUTimezone.fromMap(tz);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DHUTimezone &&
          runtimeType == other.runtimeType &&
          timezone == other.timezone;

  @override
  int get hashCode => timezone.hashCode;
}

/// A service class that performs country searches based on a query string.
class CountrySearchService {
  /// Creates a [CountrySearchService] with a list of countries and an optional similarity function.
  const CountrySearchService(
    this.countries, {
    this.similarityFunction,
  });

  /// The list of countries to search through.
  final List<DHUCountry> countries;

  /// An optional similarity function for comparing strings.
  /// Defaults to a Dice Coefficient-based similarity function.
  final double Function(String, String)? similarityFunction;

  /// Performs a search based on the given query string.
  ///
  /// Returns a list of countries that match the query, sorted by relevance.
  List<DHUCountry> search(String query) {
    final scoredCountries = countries.map((country) {
      var score = 0;

      // Define search fields and their weights
      final fields = {
        'commonName': 100,
        'officialName': 90,
        'nativeNames': 80,
        'capital': 70,
        'iso2': 100,
        'iso3': 100,
        'phoneCode': 60,
        'region': 50,
        'subregion': 40,
        'currencies': 60,
        'languages': 60,
        'timezones': 30,
      };

      int calculateFieldScore(
        String fieldValue,
        int weight,
        double Function(String, String) simFunction,
      ) {
        final fv = fieldValue.toLowerCase();
        final queryLower = query.toLowerCase();

        if (fv.startsWith(queryLower)) {
          return weight;
        } else if (fv.contains(queryLower)) {
          return (weight * 0.8).toInt();
        } else {
          final similarity = simFunction(fv, queryLower);

          if (similarity > 0.8) {
            return (weight * similarity).toInt();
          } else if (similarity > 0.5) {
            return (weight * similarity * 0.5).toInt();
          }
        }
        return 0;
      }

      // Use the provided similarity function or the default one
      final simFunction =
          similarityFunction ?? StringSimilarity.diceCoefficient;

      // Calculate scores for each field
      score += calculateFieldScore(
        country.commonName,
        fields['commonName']!,
        simFunction,
      );
      score += calculateFieldScore(
        country.officialName,
        fields['officialName']!,
        simFunction,
      );

      // Native names
      for (final native in country.nativeNames) {
        score += calculateFieldScore(
          native.common,
          fields['nativeNames']!,
          simFunction,
        );
        score += calculateFieldScore(
          native.official,
          fields['nativeNames']!,
          simFunction,
        );
      }

      // Capital
      if (country.capital != null) {
        score += calculateFieldScore(
          country.capital!,
          fields['capital']!,
          simFunction,
        );
      }

      // ISO codes
      score += calculateFieldScore(country.iso2, fields['iso2']!, simFunction);
      score += calculateFieldScore(country.iso3, fields['iso3']!, simFunction);

      // Phone code
      score += calculateFieldScore(
        country.phoneCode,
        fields['phoneCode']!,
        simFunction,
      );

      // Region and subregion
      score +=
          calculateFieldScore(country.region, fields['region']!, simFunction);
      score += calculateFieldScore(
        country.subregion,
        fields['subregion']!,
        simFunction,
      );

      // Currencies
      for (final currency in country.currencies) {
        score += calculateFieldScore(
          currency.name,
          fields['currencies']!,
          simFunction,
        );
        score += calculateFieldScore(
          currency.code,
          fields['currencies']!,
          simFunction,
        );
        score += calculateFieldScore(
          currency.symbol,
          fields['currencies']!,
          simFunction,
        );
      }

      // Languages
      for (final language in country.languages) {
        score += calculateFieldScore(
          language.name,
          fields['languages']!,
          simFunction,
        );
        score += calculateFieldScore(
          language.code,
          fields['languages']!,
          simFunction,
        );
      }

      // Timezones
      for (final timezone in country.timezones) {
        score +=
            calculateFieldScore(timezone, fields['timezones']!, simFunction);
      }

      return _ScoredCountry(country, score);
    }).toList();

    // Filter and sort countries based on scores
    final filtered = scoredCountries.where((sc) => sc.score > 0).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    // Optionally limit the number of results
    return filtered.take(50).map((sc) => sc.country).toList();
  }
}

/// A class used to store a country and its search score for sorting purposes.
class _ScoredCountry {
  /// Creates a [_ScoredCountry] with the given [country] and [score].
  const _ScoredCountry(this.country, this.score);

  /// The country object.
  final DHUCountry country;

  /// The score assigned to this country based on the search query.
  final int score;
}
