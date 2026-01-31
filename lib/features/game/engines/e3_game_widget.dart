import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';

class E3GameWidget extends StatelessWidget {
  final CardModel card;
  final bool isHost;
  final VoidCallback onNextCard;

  const E3GameWidget({
    super.key,
    required this.card,
    required this.isHost,
    required this.onNextCard,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy Logic for Sponsored Cards (in real app, this would be a property on CardModel)
    final isSponsored = card.id.hashCode % 5 == 0; 
    final cardColor = isSponsored ? const Color(0xFFE0F7FA) : Colors.white; // Light Cyan for Sponsored
    final borderColor = isSponsored ? Colors.amber : Colors.transparent;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Card Display
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: isSponsored ? 3 : 0),
            boxShadow: [
              BoxShadow(
                color: isSponsored ? Colors.amber.withAlpha(100) : AppTheme.primaryCyan.withAlpha(128),
                blurRadius: 30,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSponsored) ...[
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                       decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                       child: const Text('Ad', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                     )
                   ],
                 ),
                 const SizedBox(height: 8),
              ],
              if (card.category != null)
                Text(
                  card.category!.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.black54,
                    letterSpacing: 2,
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                card.text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              if (card.penalty != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryPink,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    card.penalty!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (isSponsored) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: const [
                     Icon(Icons.local_pizza, color: Colors.orange),
                     SizedBox(width: 8),
                     Text('Sponsored by Pizza Hut', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                   ],
                )
              ]
            ],
          ),
        ).animate(key: ValueKey(card.id)).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
        
        const SizedBox(height: 48),

        // Host Controls
        if (isHost)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                   // Haptic Feedback
                   onNextCard();
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('NEXT CARD'),
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        else
          const Text(
            'Waiting for Host...',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
      ],
    );
  }
}
