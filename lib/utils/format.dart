import '../models/models.dart';

/// plural(2, 'membre') -> "2 membres" ; plural(1, 'membre') -> "1 membre"
String plural(int n, String word) => n > 1 ? '$n ${word}s' : '$n $word';

String personStats(Person p) {
  final n = p.dislikedFoods.length;
  return n == 0 ? 'Aucune restriction' : '${plural(n, 'aliment')} à éviter';
}

String familyStats(Family f) {
  final n = f.dislikedFoodsByFood.length;
  return '${plural(f.members.length, 'membre')}'
      ' · ${plural(n, 'aliment')} ${n > 1 ? 'évités' : 'évité'}';
}
