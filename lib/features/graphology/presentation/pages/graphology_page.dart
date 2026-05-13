import 'package:flutter/material.dart';

class GraphologyPage extends StatelessWidget {
  const GraphologyPage({super.key});

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
          SizedBox.expand(
            child: Image.asset(
              'assets/images/grafologiecat.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x3307040D),
                  Color(0x220C0814),
                  Color(0xAA100A1A),
                  Color(0xE00B0612),
                ],
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
                      '✒️ Grafologie',
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
                      'Deine Schrift flüstert leise',
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
                      child: Text(
                        'Lade später eine Schriftprobe hoch und Madame Gatto liest Form, Rhythmus und Energie deiner Zeilen.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFF1E9FF),
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _GraphologyOptionTile(title: 'Schriftprobe'),
                    const SizedBox(height: 12),
                    const _GraphologyOptionTile(title: 'Charakter-Impuls'),
                    const SizedBox(height: 12),
                    const _GraphologyOptionTile(title: 'Stimmung & Ausdruck'),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0x2D160F25),
                        border: Border.all(
                          color: const Color(0x88DABA72),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Grafologie-Orakel erwacht bald',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFFFFECB8),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
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

class _GraphologyOptionTile extends StatelessWidget {
  const _GraphologyOptionTile({required this.title});

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x33432D63),
            border: Border.all(color: const Color(0x73E1C27A)),
          ),
          child: const Icon(
            Icons.edit_note_rounded,
            size: 20,
            color: Color(0xFFFFD98A),
          ),
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
