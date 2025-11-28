import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoutineDetailPage extends StatelessWidget {
  final Map<String, dynamic> routine;

  const RoutineDetailPage({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final produits = (routine["produits"] ?? []) as List<dynamic>;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Routine",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xff5C4033),
            fontSize: 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/bg-prod.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// filtre beige
          Container(color: const Color(0xAAFFF4E6)),

          /// CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 110, 16, 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ⭐ DETAILS ROUTINE
                  Text(
                    "Moment du soin : ${routine["soinTime"] ?? ""}",
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: const Color(0xff6B3F2A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    "Description",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xff5C4033),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    routine["description"] ?? "",
                    style: GoogleFonts.lato(
                      fontSize: 15.5,
                      height: 1.5,
                      color: Colors.brown[800],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ⭐ PRODUITS DANS LA MÊME GRANDE CARTE
                  if (produits.isNotEmpty) ...[
                    Text(
                      "Produits utilisés",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff5C4033),
                      ),
                    ),
                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1,
                      ),
                      itemCount: produits.length,
                      itemBuilder: (_, index) {
                        final produit = produits[index];

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.brown.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.network(
                              "http://10.0.2.2:8080${produit["imageUrl"]}",
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
