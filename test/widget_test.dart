import 'package:flutter_test/flutter_test.dart';
import 'package:kapsul_dolap/main.dart';

void main() {
  testWidgets('KapsülDolap temel yükleme testi', (WidgetTester tester) async {
    // Uygulamayı başlat
    await tester.pumpWidget(const KapsulDolapApp());

    // Giriş ekranındaki KAPSÜL başlığının varlığını doğrula
    expect(find.text('KAPSÜL'), findsWidgets);
  });
}
