import 'package:flutter/material.dart';

class PredictionPanel extends StatelessWidget {
  final Map<String, dynamic> prediction;
  final VoidCallback onClose;

  const PredictionPanel({
    super.key,
    required this.prediction,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final successProb = (prediction['success_probability'] as num).toDouble() * 100;
    final riskLevel = prediction['risk_level'] as String;
    final posFactors = List<String>.from(prediction['top_positive_factors'] as List);
    final negFactors = List<String>.from(prediction['top_negative_factors'] as List);

    final riskColor = riskLevel == 'LOW'
        ? Colors.green
        : riskLevel == 'MEDIUM'
            ? Colors.orange
            : Colors.red;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Location Insights',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Market Score',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '${successProb.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: successProb / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          successProb > 70 ? Colors.green : successProb > 40 ? Colors.orange : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.1),
                  border: Border.all(color: riskColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      riskLevel == 'LOW'
                          ? Icons.check_circle
                          : riskLevel == 'MEDIUM'
                              ? Icons.warning
                              : Icons.error,
                      color: riskColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Feasibility: $riskLevel Risk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (posFactors.isNotEmpty) ...[
                const Text(
                  'Key Advantages',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...posFactors.map(
                  (factor) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(factor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (negFactors.isNotEmpty) ...[
                const Text(
                  'Potential Challenges',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...negFactors.map(
                  (factor) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.close, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(factor)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
