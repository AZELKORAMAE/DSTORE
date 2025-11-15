import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../main.dart';

class SalesChart extends StatefulWidget {
  const SalesChart({super.key});

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).loadSalesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ventes des 30 derniers jours',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Consumer<DashboardProvider>(
              builder: (context, dashboardProvider, child) {
                final salesData = dashboardProvider.dailySales;
                
                if (salesData.isEmpty) {
                  return Container(
                    height: 200,
                    child: const Center(
                      child: Text('Aucune donnée de vente disponible'),
                    ),
                  );
                }
                
                return Container(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calculateInterval(salesData),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[300]!,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 5,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < salesData.length) {
                                final date = salesData[index].date;
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    '${date.day}/${date.month}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: _calculateInterval(salesData),
                            reservedSize: 60,
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  AppUtils.formatCurrency(value),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      minX: 0,
                      maxX: salesData.length.toDouble() - 1,
                      minY: 0,
                      maxY: _getMaxY(salesData),
                      lineBarsData: [
                        LineChartBarData(
                          spots: salesData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.amount,
                            );
                          }).toList(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withOpacity(0.3),
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: false,
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.3),
                                Theme.of(context).primaryColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueAccent,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;
                              final index = flSpot.x.toInt();
                              if (index >= 0 && index < salesData.length) {
                                final sale = salesData[index];
                                return LineTooltipItem(
                                  '${sale.date.day}/${sale.date.month}\n',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: AppUtils.formatCurrency(sale.amount),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\n${sale.invoiceCount} facture(s)',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return null;
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<DailySales> salesData) {
    if (salesData.isEmpty) return 100;
    final maxAmount = salesData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    return maxAmount * 1.2; // Ajouter 20% de marge
  }

  double _calculateInterval(List<DailySales> salesData) {
    if (salesData.isEmpty) return 10;
    final maxAmount = _getMaxY(salesData);
    return maxAmount / 5; // 5 intervalles
  }
}
