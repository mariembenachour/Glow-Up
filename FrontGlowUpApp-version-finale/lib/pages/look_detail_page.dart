import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LookDetailPage extends StatelessWidget {
  final Map<String, dynamic> look;

  const LookDetailPage({super.key, required this.look});

  @override
  Widget build(BuildContext context) {
    final vetements = (look["vetements"] ?? []) as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(look["nom"] ?? "Détail du look"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image principale ---
            if (vetements.isNotEmpty)
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(vetements[0]["image"] ?? ""),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // --- Infos du look ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    look["nom"] ?? "Sans nom",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Catégorie : ${look["categorie"] ?? "Inconnue"}",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    look["description"] ?? "Aucune description disponible",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "👗 Vêtements inclus :",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- Grille d’images des vêtements ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 images par ligne
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: vetements.length,
                itemBuilder: (context, index) {
                  final vet = vetements[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: vet["image"] != null
                              ? Image.network(
                            vet["image"],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                              : const Icon(Icons.image_not_supported, color: Colors.grey, size: 80),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            vet["nom"] ?? "Vêtement",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "${vet["type"] ?? ''} • ${vet["couleur"] ?? ''} • Taille ${vet["taille"] ?? ''}",
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
