enum ScannedHand { left, right, unknown }

extension ScannedHandLabel on ScannedHand {
  String get storageName => switch (this) {
    ScannedHand.left => 'left',
    ScannedHand.right => 'right',
    ScannedHand.unknown => 'unknown',
  };
}
