import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/core.dart';
import '../widgets/domain.dart';

class _Step {
  final IconData icon;
  final String tag;
  final String title;
  final String body;
  final String demo;
  const _Step(this.icon, this.tag, this.title, this.body, this.demo);
}

const _steps = <_Step>[
  _Step(Icons.scale, 'ΣΥΓΚΡΙΣΗ', 'Η πραγματική τιμή, ανά κιλό',
      'Κατατάσσουμε κάθε σούπερ μάρκετ με βάση το πραγματικό €/kg και €/L — έτσι η μεγάλη συσκευασία που φαίνεται ακριβότερη βγαίνει συχνά φθηνότερη. Οι τιμές της ετικέτας ξεγελούν· οι τιμές ανά μονάδα όχι.',
      'unit'),
  _Step(Icons.call_split, 'ΒΕΛΤΙΣΤΟΠΟΙΗΣΗ', 'Ένα καλάθι, τα φθηνότερα μαγαζιά',
      'Φτιάξε την εβδομαδιαία λίστα σου και το πόσο κάνει τη μοιράζει: όλα σε μία αλυσίδα, ή ένα έξυπνο πλάνο 2 στάσεων που σε γλιτώνει τα περισσότερα.',
      'basket'),
  _Step(Icons.trending_down, 'ΠΑΡΑΚΟΛΟΥΘΗΣΗ', 'Αληθινές προσφορές, όχι ψεύτικες',
      'Το ιστορικό τιμών δείχνει το χαμηλότερο 30 ημερών — έτσι μια «έκπτωση» που δεν ήταν ποτέ πραγματικά φθηνότερη ξεσκεπάζεται. Βάλε ειδοποίηση και την παρακολουθούμε.',
      'history'),
];

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final s = _steps[_i];
    final last = _i == _steps.length - 1;
    final wide = MediaQuery.of(context).size.width >= 900;

    final art = _Art(step: s);
    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.tag, style: PkText.eyebrow(size: PkFont.xs, color: pk.dealText)),
        const SizedBox(height: 12),
        Text(s.title, style: PkText.display(size: wide ? 38 : 28, weight: FontWeight.w800, color: pk.textPrimary)),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(s.body, style: PkText.body(size: wide ? 17 : 15, color: pk.textSecondary, height: 1.55)),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            for (var k = 0; k < _steps.length; k++)
              GestureDetector(
                onTap: () => setState(() => _i = k),
                child: AnimatedContainer(
                  duration: PkDur.base,
                  margin: const EdgeInsets.only(right: 8),
                  width: k == _i ? 26 : 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: k == _i ? pk.primary : pk.borderStrong,
                    borderRadius: BorderRadius.circular(PkRadius.pill),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            if (_i > 0) ...[
              PkButton(
                label: 'Πίσω',
                variant: PkButtonVariant.ghost,
                onPressed: () => setState(() => _i--),
                iconLeft: Icon(Icons.chevron_left, size: 18, color: pk.textPrimary),
              ),
              const SizedBox(width: 10),
            ],
            PkButton(
              label: last ? 'Ξεκίνα να γλιτώνεις' : 'Επόμενο',
              onPressed: () => last ? widget.onDone() : setState(() => _i++),
              iconRight: last ? null : const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      backgroundColor: pk.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Logo(size: 22),
                  TextButton(
                    onPressed: widget.onDone,
                    child: Text('Παράλειψη', style: PkText.label(size: 14, weight: FontWeight.w600, color: pk.textMuted)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1060),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: art),
                              const SizedBox(width: 48),
                              Expanded(child: copy),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [art, const SizedBox(height: 32), copy],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Art extends StatelessWidget {
  final _Step step;
  const _Art({required this.step});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return AspectRatio(
      aspectRatio: 5 / 4,
      child: Container(
        decoration: BoxDecoration(
          color: pk.surface,
          border: Border.all(color: pk.borderSubtle),
          borderRadius: BorderRadius.circular(PkRadius.xxl),
          boxShadow: pk.shadowMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -80,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [pk.primarySoft, pk.primarySoft.withValues(alpha: 0)], stops: const [0, 0.65]),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: pk.primary,
                    borderRadius: BorderRadius.circular(PkRadius.xl),
                    boxShadow: [BoxShadow(color: pk.primary.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 6))],
                  ),
                  child: Icon(step.icon, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 22),
                _Demo(kind: step.demo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Demo extends StatelessWidget {
  final String kind;
  const _Demo({required this.kind});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    Widget card(Widget child) => Container(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: pk.surfaceRaised,
            border: Border.all(color: pk.borderSubtle),
            borderRadius: BorderRadius.circular(PkRadius.lg),
            boxShadow: pk.shadowSm,
          ),
          child: child,
        );

    if (kind == 'unit') {
      return card(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _unitRow(context, 'sklavenitis', '400g', 2.49, 6.23, false),
          const SizedBox(height: 10),
          _unitRow(context, 'masoutis', '1kg', 5.49, 5.49, true),
          const SizedBox(height: 8),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_awesome, size: 13, color: pk.saveText),
            const SizedBox(width: 6),
            Text('το 1kg είναι φθηνότερο ανά γραμμάριο', style: PkText.mono(size: 12, color: pk.saveText)),
          ]),
        ],
      ));
    }
    if (kind == 'basket') {
      return card(Column(
        children: [
          _splitRow(context, 'lidl', '4 προϊόντα'),
          const SizedBox(height: 8),
          _splitRow(context, 'sklavenitis', '3 προϊόντα'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: pk.saveSoft, borderRadius: BorderRadius.circular(PkRadius.md)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Πλάνο 2 στάσεων', style: PkText.body(size: 14, color: pk.saveText)),
                Text('γλιτώνεις €8.40', style: PkText.price(size: 18, color: pk.saveText)),
              ],
            ),
          ),
        ],
      ));
    }
    return card(Column(
      children: [
        const Sparkline(data: [3.1, 3.1, 2.99, 2.69, 2.49, 2.49, 2.39, 2.49, 2.49], width: 248, height: 70),
        const SizedBox(height: 8),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.trending_down, size: 13, color: pk.saveText),
          const SizedBox(width: 6),
          Text('χαμηλότερο σε 30 ημέρες · €2.39', style: PkText.mono(size: 12, color: pk.saveText)),
        ]),
      ],
    ));
  }

  Widget _unitRow(BuildContext context, String slug, String pack, double price, double unit, bool best) {
    final pk = context.pk;
    return Row(
      children: [
        StoreChip(slug: slug, size: PkStoreChipSize.sm, showName: false),
        const SizedBox(width: 10),
        Expanded(child: Text(pack, style: PkText.mono(size: 12, color: pk.textMuted))),
        PriceDisplay(amount: price, size: PkPriceSize.sm),
        const SizedBox(width: 10),
        UnitPriceTag(value: unit, best: best),
      ],
    );
  }

  Widget _splitRow(BuildContext context, String slug, String label) {
    final pk = context.pk;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: pk.surfaceSunken, borderRadius: BorderRadius.circular(PkRadius.md)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StoreChip(slug: slug, size: PkStoreChipSize.sm),
          Text(label, style: PkText.mono(size: 12, color: pk.textSecondary)),
        ],
      ),
    );
  }
}
