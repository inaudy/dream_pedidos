import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dream_pedidos/main.dart';
import 'package:dream_pedidos/presentation/cubit/pos_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PosSelectionPage extends StatelessWidget {
  const PosSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final posOptions = [
      {
        "title": "Restaurante Areca",
        "pos": PosType.restaurant,
        "icon": Icons.restaurant,
      },
      {
        "title": "Beach Club",
        "pos": PosType.beachClub,
        "icon": Icons.beach_access,
      },
      {
        "title": "Bar Hall",
        "pos": PosType.bar,
        "icon": Icons.local_bar,
      },
      {
        "title": "Cafe del Mar",
        "pos": PosType.cafeDelMar,
        "icon": LucideIcons.sunset,
      },
      {
        "title": "Santa Rosa",
        "pos": PosType.santaRosa,
        "icon": LucideIcons.beef,
      },
    ];

    return Scaffold(
      body: Center(
        // ✅ Ensures everything is horizontally centered
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ No extra spacing
          crossAxisAlignment:
              CrossAxisAlignment.center, // ✅ Aligns content to center
          children: [
            // 🔹 Logo
            Image.asset(
              'assets/images/logo.png',
              height: 60,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported,
                    size: 60, color: Colors.grey);
              },
            ),
            const SizedBox(height: 20),

            // 🔹 Title
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                "Elige un Punto de Venta",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            // 🔹 Centered POS List
            SizedBox(
              width: 300, // ✅ Fixed width to center the list
              child: Column(
                children: posOptions.map((option) {
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(option["icon"] as IconData,
                            color: Colors.blueAccent),
                        title: Text(
                          option["title"] as String,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          final selectedPos = option["pos"] as PosType;
                          context
                              .read<PosSelectionCubit>()
                              .selectPos(selectedPos);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<PosSelectionCubit>(),
                                child: MyApp(selectedPos: selectedPos),
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(
                          height: 1, thickness: 1), // ✅ Clean separator
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
