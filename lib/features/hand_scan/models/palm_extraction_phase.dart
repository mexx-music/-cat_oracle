enum PalmExtractionPhase {
  imageLoaded,
  optimizing,
  palmDetected,
  edgeDetection,
  lineExtraction,
  geometricAnalysis,
  gattoConfirms,
  complete;

  static PalmExtractionPhase fromProgress(double progress) {
    if (progress < 1 / 8) return imageLoaded;
    if (progress < 2 / 8) return optimizing;
    if (progress < 3 / 8) return palmDetected;
    if (progress < 4 / 8) return edgeDetection;
    if (progress < 5 / 8) return lineExtraction;
    if (progress < 6 / 8) return geometricAnalysis;
    if (progress < 7 / 8) return gattoConfirms;
    return complete;
  }

  String get emoji => switch (this) {
        imageLoaded => '📷',
        optimizing => '🔧',
        palmDetected => '✋',
        edgeDetection => '🔍',
        lineExtraction => '〰️',
        geometricAnalysis => '📐',
        gattoConfirms => '🐾',
        complete => '✅',
      };
}
