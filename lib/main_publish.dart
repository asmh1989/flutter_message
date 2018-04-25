import 'utils/network.dart';
import 'main.dart' as other_main;

// This main chain-calls main.dart's main. This file is used for publishing
// the gallery and removes the 'PREVIEW' banner.
void main() {
  NetWork.isDebug = false;
  other_main.main();
}