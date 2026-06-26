enum LifeLine { short, medium, long }

enum HeartLine { soft, balanced, deep }

enum HeadLine { straight, curved, mixed }

enum FateLine { faint, visible, strong }

enum MountVenus { flat, balanced, full }

enum HandShape { earth, air, water, fire }

class PalmistryAnalysisProfile {
  const PalmistryAnalysisProfile({
    required this.lifeLine,
    required this.heartLine,
    required this.headLine,
    required this.fateLine,
    required this.mountVenus,
    required this.handShape,
  });

  final LifeLine lifeLine;
  final HeartLine heartLine;
  final HeadLine headLine;
  final FateLine fateLine;
  final MountVenus mountVenus;
  final HandShape handShape;
}
