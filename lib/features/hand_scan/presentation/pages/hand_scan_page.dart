import 'package:flutter/material.dart';

class HandScanPage extends StatelessWidget {
  const HandScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding.vertical;

    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.68,
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/palmcat.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xD9090711),
                  Color(0xD9150E22),
                  Color(0xE00E0818),
                  Color(0xF206050C),
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
                          foregroundColor: const Color(0xFFF3DFA3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Handlesen',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: const Color(0xFFFFE9B0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Deine Hand erzahlt deine Geschichte',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFE6DDF8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: (screenHeight * 0.22)
                          .clamp(120.0, 220.0)
                          .toDouble(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x40110D1D),
                        border: Border.all(
                          color: const Color(0x88DAB86E),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x54110D1C),
                            blurRadius: 26,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Text(
                        'Lege deine Hand spater in den Scanbereich und die Katze liest deine Linien.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFF3ECFF),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAA7B2E),
                          foregroundColor: const Color(0xFF150C1F),
                        ),
                        child: const Text('Scan vorbereiten'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF5E7BF),
                          side: const BorderSide(color: Color(0x88DAB86E)),
                        ),
                        child: const Text('Demo-Handlesen'),
                      ),
                    ),
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
