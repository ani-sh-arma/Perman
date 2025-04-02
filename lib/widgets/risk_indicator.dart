import 'package:flutter/material.dart';

class RiskIndicator extends StatelessWidget {
  final String riskLevel;
  const RiskIndicator({super.key, required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    Color riskColor;
    switch (riskLevel) {
      case 'High':
        riskColor = Colors.red;
        break;
      case 'Medium':
        riskColor = Colors.orange;
        break;
      default:
        riskColor = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: riskColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Risk Level: $riskLevel",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
