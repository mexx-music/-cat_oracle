import 'package:flutter/material.dart';
import 'package:cat_oracle/features/astrology/data/demo_astrology_readings.dart';
import 'package:cat_oracle/features/astrology/logic/zodiac_calculator.dart';
import 'package:cat_oracle/features/astrology/models/astrology_reading.dart';
import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';

const List<String> _demoBirthPlaces = [
  'Wien',
  'Graz',
  'Salzburg',
  'München',
  'Berlin',
  'Hamburg',
  'Zürich',
  'Basel',
  'Paris',
  'London',
  'Rom',
  'Oslo',
  'Trondheim',
];

class AstrologyInputPage extends StatefulWidget {
  const AstrologyInputPage({super.key});

  @override
  State<AstrologyInputPage> createState() => _AstrologyInputPageState();
}

class _AstrologyInputPageState extends State<AstrologyInputPage> {
  late final TextEditingController _birthPlaceController;
  DateTime? _selectedBirthDate;
  TimeOfDay? _selectedBirthTime;
  ZodiacSign? _calculatedSunSign;
  AstrologyReading? _calculatedAstrologyReading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _birthPlaceController = TextEditingController();
    _birthPlaceController.addListener(_onBirthPlaceChanged);
  }

  @override
  void dispose() {
    _birthPlaceController.removeListener(_onBirthPlaceChanged);
    _birthPlaceController.dispose();
    super.dispose();
  }

  void _onBirthPlaceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day.$month.$year';
  }

  String _formatTime(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Geburtsdatum auswählen',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedBirthDate = pickedDate;
      _errorMessage = null;
      _calculatedSunSign = null;
      _calculatedAstrologyReading = null;
    });
  }

  Future<void> _pickBirthTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedBirthTime ?? TimeOfDay.now(),
      helpText: 'Geburtszeit auswählen',
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedBirthTime = pickedTime;
    });
  }

  void _calculateSunSign() {
    final birthDate = _selectedBirthDate;

    if (birthDate == null) {
      setState(() {
        _errorMessage = 'Bitte gib ein gültiges Datum ein.';
        _calculatedSunSign = null;
        _calculatedAstrologyReading = null;
      });
      return;
    }

    final sunSign = calculateSunSign(birthDate);
    final demoReading = demoAstrologyReadings.firstWhere(
      (reading) => reading.zodiacSign == sunSign,
      orElse: () => const AstrologyReading(
        zodiacSign: ZodiacSign.aries,
        title: 'Dein Sternzeichen',
        summary:
            'Dein Demo-Reading ist noch nicht hinterlegt. Die Sterne bleiben dennoch freundlich und voller Möglichkeiten.',
      ),
    );

    setState(() {
      _errorMessage = null;
      _calculatedSunSign = sunSign;
      _calculatedAstrologyReading = demoReading;
    });
  }

  String _getZodiacSignName(ZodiacSign sign) {
    const names = {
      ZodiacSign.aries: 'Widder',
      ZodiacSign.taurus: 'Stier',
      ZodiacSign.gemini: 'Zwillinge',
      ZodiacSign.cancer: 'Krebs',
      ZodiacSign.leo: 'Löwe',
      ZodiacSign.virgo: 'Jungfrau',
      ZodiacSign.libra: 'Waage',
      ZodiacSign.scorpio: 'Skorpion',
      ZodiacSign.sagittarius: 'Schütze',
      ZodiacSign.capricorn: 'Steinbock',
      ZodiacSign.aquarius: 'Wassermann',
      ZodiacSign.pisces: 'Fische',
    };

    return names[sign] ?? 'Unbekannt';
  }

  List<String> get _filteredBirthPlaceSuggestions {
    final query = _birthPlaceController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }

    return _demoBirthPlaces
        .where((place) => place.toLowerCase().contains(query))
        .take(5)
        .toList();
  }

  void _selectBirthPlace(String place) {
    _birthPlaceController.value = TextEditingValue(
      text: place,
      selection: TextSelection.collapsed(offset: place.length),
    );
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding.vertical;
    final contentTopSpacing = (screenHeight * 0.18)
        .clamp(96.0, 180.0)
        .toDouble();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF090611),
                  Color(0xFF130B20),
                  Color(0xFF091022),
                  Color(0xFF05070D),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: Opacity(
              opacity: 0.32,
              child: SizedBox.expand(
                child: Image.asset(
                  'assets/images/galaxy.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
          const IgnorePointer(child: _StarDustLayer()),
          IgnorePointer(
            child: Opacity(
              opacity: 0.48,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.68,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Image.asset(
                      'assets/images/starcat.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - safePadding - 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x33FFFFFF),
                          foregroundColor: const Color(0xFFF3E6BD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✨ Astrologie ✨',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: const Color(0xFFFFF2CC),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dein kosmischer Katzenblick',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFD8C8F7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentTopSpacing),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x3E120F1F),
                        border: Border.all(
                          color: const Color(0x88DAB86E),
                          width: 1.1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x54120F1E),
                            blurRadius: 26,
                            offset: Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Color(0x1F7A4DCC),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✦ 🐾 ✦',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: const Color(0xFFFFD98A),
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Die Sterne flüstern dir zu',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: const Color(0xFFFFE9B0),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Entdecke, was die Sterne heute fur dich und deine Seele bereithalten.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: const Color(0xFFF1E9FF),
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x36140F20),
                        border: Border.all(
                          color: const Color(0x66CFAF69),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4A120D1C),
                            blurRadius: 22,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Kosmische Angaben',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: const Color(0xFFFFE4A6),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 14),
                          _MysticPickerField(
                            label: 'Geburtsdatum',
                            value: _selectedBirthDate == null
                                ? 'TT.MM.JJJJ'
                                : _formatDate(_selectedBirthDate!),
                            onTap: _pickBirthDate,
                            icon: Icons.calendar_month_rounded,
                          ),
                          const SizedBox(height: 12),
                          _MysticPickerField(
                            label: 'Geburtszeit (optional)',
                            value: _selectedBirthTime == null
                                ? 'HH:mm'
                                : _formatTime(_selectedBirthTime!),
                            onTap: _pickBirthTime,
                            icon: Icons.schedule_rounded,
                          ),
                          const SizedBox(height: 12),
                          _MysticInputField(
                            hintText: 'Geburtsort',
                            controller: _birthPlaceController,
                          ),
                          if (_filteredBirthPlaceSuggestions.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _filteredBirthPlaceSuggestions
                                  .map(
                                    (place) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _BirthPlaceSuggestionTile(
                                        label: place,
                                        onTap: () => _selectBirthPlace(place),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _selectedBirthDate == null
                                  ? null
                                  : _calculateSunSign,
                              style: ElevatedButton.styleFrom(
                                disabledBackgroundColor: const Color(
                                  0x7FA27B35,
                                ),
                                disabledForegroundColor: const Color(
                                  0xFFEEDAA5,
                                ),
                                backgroundColor: const Color(0xFF7A5D2E),
                                foregroundColor: const Color(0xFFFFE9B0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Astrologie vorbereiten'),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0x3ACC6B6B),
                                border: Border.all(
                                  color: const Color(0xFFCC9999),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: const Color(0xFFFFCCCC)),
                              ),
                            ),
                          ],
                          if (_calculatedSunSign != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: const Color(0x3E2D1F4F),
                                border: Border.all(
                                  color: const Color(0x88B37ED8),
                                  width: 1.2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x3D7A4DCC),
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '🌟 Dein Sonnenzeichen 🌟',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: const Color(0xFFFFD98A),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _getZodiacSignName(_calculatedSunSign!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: const Color(0xFFFFE9B0),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _calculatedAstrologyReading?.summary ??
                                        'Die kosmischen Energien haben gesprochen.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: const Color(0xFFF1E9FF),
                                          height: 1.45,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _AstroOptionTile(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Tagesorakel',
                    ),
                    const SizedBox(height: 12),
                    const _AstroOptionTile(
                      icon: Icons.public_rounded,
                      title: 'Sternzeichen',
                    ),
                    const SizedBox(height: 12),
                    const _AstroOptionTile(
                      icon: Icons.favorite_rounded,
                      title: 'Liebe & Beziehungen',
                    ),
                    const SizedBox(height: 12),
                    const _AstroOptionTile(
                      icon: Icons.visibility_rounded,
                      title: 'Zukunftsausblick',
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MysticPickerField extends StatelessWidget {
  const _MysticPickerField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0x30191329),
            border: Border.all(color: const Color(0x55D0B16F)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFFFD98A)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xB8D8C8F7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFFF4E9FF),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_drop_down_rounded,
                color: Color(0xFFE5D0A0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MysticInputField extends StatelessWidget {
  const _MysticInputField({required this.hintText, required this.controller});

  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Color(0xFFF4E9FF)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xB8D8C8F7)),
        filled: true,
        fillColor: const Color(0x30191329),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x55D0B16F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x88F0D28D)),
        ),
      ),
    );
  }
}

class _BirthPlaceSuggestionTile extends StatelessWidget {
  const _BirthPlaceSuggestionTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0x2B161126),
            border: Border.all(color: const Color(0x66D5B46B), width: 0.9),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40100D1B),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 18,
                color: Color(0xFFFFD98A),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFF4E9FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarDustLayer extends StatelessWidget {
  const _StarDustLayer();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: double.infinity,
        height: 240,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 0.95,
            colors: [Color(0x228E5CCF), Color(0x008E5CCF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 28,
            runSpacing: 14,
            children: const [
              _StarDot(size: 2.2),
              _StarDot(size: 1.8),
              _StarDot(size: 2.4),
              _StarDot(size: 1.7),
              _StarDot(size: 2.0),
              _StarDot(size: 2.5),
              _StarDot(size: 1.9),
              _StarDot(size: 2.1),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarDot extends StatelessWidget {
  const _StarDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0x8CFFD78A),
      ),
    );
  }
}

class _AstroOptionTile extends StatelessWidget {
  const _AstroOptionTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x2B161126),
        border: Border.all(color: const Color(0x66D5B46B), width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40100D1B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x182F1F4F),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        dense: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x33432D63),
            border: Border.all(color: const Color(0x73E1C27A)),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFFFD98A)),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFFF4E9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFE5D0A0),
        ),
      ),
    );
  }
}
