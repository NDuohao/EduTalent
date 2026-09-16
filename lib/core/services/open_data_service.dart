import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenDataService {
  static const String _baseUrl = 'https://api.data.gov.my/data-catalogue';

  static Future<Map<String, dynamic>> fetchYouthUnemployment() async {
    final url = Uri.parse('$_baseUrl?id=lfs_month_youth&limit=5&sort=-date');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final latest = data.first;
          final previous = data.length > 1 ? data[1] : latest;
          return {
            'rate': double.tryParse(latest['u_rate_15_30'].toString()) ?? 6.3,
            'date': latest['date'] ?? 'May 2026',
            'change': (double.tryParse(latest['u_rate_15_30'].toString()) ?? 0) - 
                       (double.tryParse(previous['u_rate_15_30'].toString()) ?? 0),
          };
        }
      }
      return {'rate': 6.3, 'date': 'May 2026', 'change': -0.2};
    } catch (e) {
      return {'rate': 6.3, 'date': 'May 2026', 'change': -0.2};
    }
  }

  static Future<Map<String, double>> fetchEmploymentBySector() async {
    final url = Uri.parse('$_baseUrl?id=employment_sector&limit=20&sort=-date');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        Map<String, double> sectors = {};
        if (data.isNotEmpty) {
          String latestDate = data.first['date'];
          for (var item in data) {
            if (item['date'] == latestDate && item['sex'] == 'both') {
              sectors[item['sector']] = double.tryParse(item['proportion'].toString()) ?? 0.0;
            }
          }
        }
        if (sectors.isNotEmpty) return sectors;
      }
      return {'Services': 52.0, 'Industry': 35.0, 'Agriculture': 13.0};
    } catch (e) {
      return {'Services': 52.0, 'Industry': 35.0, 'Agriculture': 13.0};
    }
  }

  static Future<Map<String, dynamic>> fetchLabourMarketStats() async {
    final url = Uri.parse('$_baseUrl?id=lfs_month&limit=1&sort=-date');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final latest = data.first;
          return {
            'u_rate': double.tryParse(latest['u_rate'].toString()) ?? 3.0,
            'p_rate': double.tryParse(latest['p_rate'].toString()) ?? 70.9,
            'unemployed': latest['lf_unemployed'] ?? 513.4,
            'date': latest['date'] ?? 'May 2026',
          };
        }
      }
      return {'u_rate': 3.0, 'p_rate': 70.9, 'unemployed': 513.4, 'date': 'May 2026'};
    } catch (e) {
      return {'u_rate': 3.0, 'p_rate': 70.9, 'unemployed': 513.4, 'date': 'May 2026'};
    }
  }

  static Future<Map<String, Map<String, double>>> fetchPremiumUnderemploymentData() async {
    final url = Uri.parse('$_baseUrl?id=lfs_qtr_sru_age&limit=20&sort=-date');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        final List<dynamic> data = (decoded is Map && decoded.containsKey('data')) 
            ? decoded['data'] 
            : (decoded is List ? decoded : []);
        
        String latestDate = "";
        for (var item in data) {
          String d = item['date'] ?? "";
          if (d.compareTo(latestDate) > 0) latestDate = d;
        }

        Map<String, double> rates = {};
        Map<String, double> persons = {};
        
        for (var item in data) {
          if (item['date'] == latestDate) {
            String age = item['age'] ?? 'Unknown';
            if (age == 'overall') continue;
            
            double value = double.tryParse(item['sru']?.toString() ?? '0') ?? 0;
            if (item['variable'] == "rate") {
              rates[age] = value;
            } else {
              persons[age] = value;
            }
          }
        }
        if (rates.isNotEmpty) return {"rates": rates, "persons": persons};
      }
      return _getMockPremiumData();
    } catch (e) {
      return _getMockPremiumData();
    }
  }

  static Map<String, Map<String, double>> _getMockPremiumData() {
    return {
      "rates": {'15-24': 74.3, '25-34': 39.5, '35-44': 28.2, '45+': 22.1},
      "persons": {'15-24': 466.5, '25-34': 786.8, '35-44': 447.8, '45+': 260.4}
    };
  }
}
