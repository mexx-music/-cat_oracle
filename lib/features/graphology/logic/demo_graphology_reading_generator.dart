import 'dart:math';

import '../data/demo_graphology_traits.dart';
import '../models/graphology_trait.dart';

List<GraphologyTrait> generateDemoGraphologyReading() {
  final shuffled = List.of(demoGraphologyTraits)..shuffle(Random());
  return shuffled.take(3).toList();
}

String composeDemoGraphologyReading(List<GraphologyTrait> traits) {
  assert(traits.length == 3);
  final a = traits[0];
  final b = traits[1];
  final c = traits[2];
  final variant = Random().nextInt(3);

  switch (variant) {
    case 0:
      return 'Madame Gatto betrachtet die drei Zeichen und schweigt einen Moment. '
          '${a.title} spricht als erstes: eine Energie, die sich durch die gesamte Seite zieht '
          'und in Verbindung mit ${b.title} eine besondere Tiefe entfaltet. '
          '${c.title} fügt einen weiteren Klang hinzu – nicht als Widerspruch, sondern als Ergänzung. '
          'Madame Gatto murmelt: Selten liegen drei Zeichen so stimmig beieinander. '
          'Diese Deutung ist symbolisch – sie zeigt, was sichtbar ist, und lädt ein, genauer hinzuhören. '
          'Was deine Schrift dir wirklich sagen möchte, weißt letztlich nur du selbst.';
    case 1:
      return 'Drei Zeichen, drei Stimmen – ${a.title}, ${b.title} und ${c.title}. '
          'Sie sprechen nicht nacheinander, sondern gleichzeitig, und wer zuhört, hört eine einzige Geschichte. '
          '${a.title} legt den Ton fest, ${b.title} antwortet darauf – ergänzend, manchmal auch in einem leisen Gegensatz, '
          'der die Schrift lebendig macht. '
          '${c.title} schließt den Bogen: nicht als Ende, sondern als Öffnung. '
          'Madame Gatto legt das Blatt beiseite und sagt ruhig: Deine Schrift kennt dich gut.';
    default:
      return 'Madame Gatto legt die drei Zeichen nebeneinander: ${a.title}, ${b.title}, ${c.title}. '
          'Was zunächst wie drei einzelne Beobachtungen wirkt, entfaltet sich beim zweiten Blick zu einem Gesamtbild. '
          '${a.title} und ${b.title} stehen in einem inneren Dialog – '
          'die eine Qualität ruft die andere hervor, als würden sie sich seit Langem kennen. '
          '${c.title} ist der dritte Spiegel: er zeigt, was die anderen beiden noch nicht zeigen konnten. '
          'Diese Deutung ist ein Anfang, kein Abschluss – ein symbolischer Fingerzeig, kein Urteil.';
  }
}
