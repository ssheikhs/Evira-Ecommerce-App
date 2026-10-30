import 'package:ecommerce_app/core/utils/formatters.dart';
import 'package:ecommerce_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.bdPhone', () {
    test('accepts valid Bangladeshi mobile numbers', () {
      expect(Validators.bdPhone('01712345678'), isNull);
      expect(Validators.bdPhone('+8801912345678'), isNull);
      expect(Validators.bdPhone('017-1234-5678'), isNull);
    });

    test('rejects empty, short and wrong-prefix numbers', () {
      expect(Validators.bdPhone(''), isNotNull);
      expect(Validators.bdPhone('0171234'), isNotNull);
      expect(Validators.bdPhone('01212345678'), isNotNull);
    });
  });

  group('Validators.postalCode', () {
    test('accepts 4 to 6 digits only', () {
      expect(Validators.postalCode('1207'), isNull);
      expect(Validators.postalCode('12'), isNotNull);
      expect(Validators.postalCode('12ab'), isNotNull);
    });
  });

  group('Formatters', () {
    test('price uses two decimals', () {
      expect(Formatters.price(12.5), '\$12.50');
      expect(Formatters.price(0), '\$0.00');
    });

    test('titleCase turns slugs into labels', () {
      expect(Formatters.titleCase('home-decoration'), 'Home Decoration');
      expect(Formatters.titleCase('mens_shirts'), 'Mens Shirts');
    });

    test('dateTime uses a 12-hour clock', () {
      expect(
        Formatters.dateTime(DateTime(2026, 10, 25, 21, 5)),
        '25 Oct 2026, 9:05 PM',
      );
    });
  });
}
