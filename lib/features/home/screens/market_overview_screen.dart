import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/open_data_service.dart';

class MarketOverviewScreen extends StatefulWidget {
  final UserModel user;

  const MarketOverviewScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MarketOverviewScreen> createState() => _MarketOverviewScreenState();
}

class _MarketOverviewScreenState extends State<MarketOverviewScreen> {
  bool _isLoading = true;
  
  Map<String, dynamic> _youthUnemployment = {};
  Map<String, double> _marketTrends = {};
  Map<String, Map<String, double>> _sruData = {};
  Map<String, dynamic> _marketStats = {};
  
  Map<String, dynamic> _talentPoolStats = {};
  Map<String, int> _topSkills = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final dbHelper = DatabaseHelper.instance;
    
    final results = await Future.wait([
      OpenDataService.fetchYouthUnemployment(),
      OpenDataService.fetchEmploymentBySector(),
      OpenDataService.fetchPremiumUnderemploymentData(),
      OpenDataService.fetchLabourMarketStats(),
      if (widget.user.role == 'corporate') dbHelper.getTalentPoolStats(),
      if (widget.user.role == 'corporate') dbHelper.getTopSkillsStats(),
    ]);

    if (mounted) {
      setState(() {
        _youthUnemployment = results[0] as Map<String, dynamic>;
        _marketTrends = results[1] as Map<String, double>;
        _sruData = results[2] as Map<String, Map<String, double>>;
        _marketStats = results[3] as Map<String, dynamic>;
        
        if (widget.user.role == 'corporate') {
          _talentPoolStats = results[4] as Map<String, dynamic>;
          _topSkills = results[5] as Map<String, int>;
        }
        
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        title: const Text('Market Intelligence', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blue),
            onPressed: _loadAllData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
          : RefreshIndicator(
              onRefresh: _loadAllData,
              color: Colors.blue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: widget.user.role == 'graduate' 
                    ? _buildGraduateInsights() 
                    : _buildCorporateInsights(),
              ),
            ),
    );
  }

  Widget _buildGraduateInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopMetricCard(
          title: 'Youth Unemployment',
          subtitle: 'Age 15 - 30 • Malaysia',
          value: '${_youthUnemployment['rate'] ?? 6.3}%',
          date: _youthUnemployment['date'] ?? 'LATEST',
          icon: Icons.person_search_rounded,
          colors: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
        ),
        const SizedBox(height: 28),
        _buildSectionHeader(Icons.trending_up_rounded, 'Career Market Trends'),
        _buildCareerMarketTrends(),
        const SizedBox(height: 28),
        _buildSectionHeader(Icons.psychology_outlined, 'Graduate Skill Match'),
        _buildSkillMatchSection(),
        const SizedBox(height: 28),
        _buildSectionHeader(Icons.public_rounded, 'Malaysia Labour Market'),
        _buildLabourMarketSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCorporateInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopMetricCard(
          title: 'Internal Talent Pool',
          subtitle: 'Active Graduates in EduTalent',
          value: '${_talentPoolStats['total'] ?? 0}',
          date: 'LIVE DATA',
          icon: Icons.groups_rounded,
          colors: [const Color(0xFF0F2027), const Color(0xFF203A43)],
        ),
        const SizedBox(height: 28),
        _buildSectionHeader(Icons.bolt_rounded, 'Top In-Demand Skills'),
        _buildTopSkillsSection(),
        const SizedBox(height: 28),
        _buildSectionHeader(Icons.analytics_outlined, 'National Talent Distribution'),
        _buildIndustryDistribution(),
        const SizedBox(height: 28),
        _buildSectionHeader(Icons.public_rounded, 'Malaysia Labour Market'),
        _buildLabourMarketSection(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[800]),
          const SizedBox(width: 10),
          Text(
            title, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.2)
          ),
        ],
      ),
    );
  }

  Widget _buildTopMetricCard({
    required String title,
    required String subtitle,
    required String value,
    required String date,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -2)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Updated: $date',
            style: const TextStyle(color: Colors.white30, fontSize: 11, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerMarketTrends() {
    final entries = _marketTrends.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _buildModernCard(
      child: Column(
        children: entries.map((e) => _buildModernProgressBar(e.key, e.value)).toList(),
      ),
    );
  }

  Widget _buildModernProgressBar(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label, 
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3436)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFF1F2F6), borderRadius: BorderRadius.circular(5)),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.blue, Color(0xFF74B9FF)]),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillMatchSection() {
    final sruRate = _sruData['rates']?['25-34'] ?? 31.8;
    return _buildModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Skill-Related', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('Underemployment', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
              Text('${sruRate.toStringAsFixed(1)}%', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.blue[800], letterSpacing: -1)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFF1F2F6), thickness: 1.5),
          ),
          const Text('Insight', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF2D3436))),
          const SizedBox(height: 10),
          const Text(
            'This metric indicates tertiary-educated workers in jobs below their qualification level. A lower % suggests better market alignment for graduates.',
            style: TextStyle(color: Color(0xFF636E72), fontSize: 13, height: 1.6, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLabourMarketSection() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0984E3),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMarketRow('Unemployment Rate', '${_marketStats['u_rate']}%', isLight: true),
          const SizedBox(height: 16),
          _buildMarketRow('Labour Participation', '${_marketStats['p_rate']}%', isLight: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white24, thickness: 1),
          ),
          _buildMarketRow('Unemployed Persons', '${_marketStats['unemployed']}k', isLight: true, isBold: true),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.update, color: Colors.white54, size: 12),
              const SizedBox(width: 6),
              Text(
                'Data from DOSM: ${_marketStats['date']}',
                style: const TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketRow(String label, String value, {bool isLight = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: TextStyle(color: isLight ? Colors.white70 : Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 14))),
        const SizedBox(width: 8),
        Text(
          value, 
          style: TextStyle(
            color: isLight ? Colors.white : Colors.black87, 
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w800, 
            fontSize: isBold ? 18 : 16
          )
        ),
      ],
    );
  }

  Widget _buildTalentPoolSnapshot() {
    final courses = (_talentPoolStats['courses'] as Map<String, int>?) ?? {};
    return _buildModernCard(
      padding: 0,
      child: Column(
        children: [
          ...courses.entries.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F2F6), width: 1))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3436), fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                  child: Text('${e.value}', style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTopSkillsSection() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: _topSkills.entries.map((e) => Container(
          width: 130,
          margin: const EdgeInsets.only(right: 16, bottom: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F2F6)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                e.key, 
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF2D3436)), 
                textAlign: TextAlign.center, 
                maxLines: 1, 
                overflow: TextOverflow.ellipsis
              ),
              const SizedBox(height: 8),
              Text(
                '${e.value}', 
                style: TextStyle(color: Colors.blue[600], fontSize: 16, fontWeight: FontWeight.w900)
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildIndustryDistribution() {
    final entries = _marketTrends.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _buildModernCard(
      child: Column(
        children: entries.take(5).map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      e.key, 
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF636E72)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${e.value.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: e.value / 100,
                  backgroundColor: const Color(0xFFF1F2F6),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildModernCard({required Widget child, double padding = 20}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF1F2F6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: child,
    );
  }
}
