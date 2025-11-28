import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/produit_service.dart';
import 'AjouterModifierProduitPage.dart';

class GestionProduitsPage extends StatefulWidget {
  final Map? demande;

  const GestionProduitsPage({super.key, this.demande});

  @override
  _GestionProduitsPageState createState() => _GestionProduitsPageState();
}

class _GestionProduitsPageState extends State<GestionProduitsPage> {
  final ProduitService service = ProduitService();
  List produits = [];
  bool loading = true;

  List<int> selectedProduits = [];

  @override
  void initState() {
    super.initState();
    chargerProduits();
  }

  Future<void> chargerProduits() async {
    setState(() => loading = true);
    try {
      final data = await service.getProduits();
      setState(() => produits = data);
    } catch (e) {
      setState(() => produits = []);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erreur: $e")));
    }
    setState(() => loading = false);
  }

  void confirmerSuppression(int id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer ce produit ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) supprimerProduit(id);
  }

  void supprimerProduit(int id) async {
    bool ok = await service.deleteProduit(id);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Produit supprimé")));
      chargerProduits();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Erreur de suppression")));
    }
  }

  /// ⭐ Fonction toggle sélection multiple
  void toggleSelection(int id) {
    setState(() {
      if (selectedProduits.contains(id)) {
        selectedProduits.remove(id);
      } else {
        selectedProduits.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des produits"),
        backgroundColor: const Color(0xFF5C4033),
        elevation: 0,
      ),

      floatingActionButton: selectedProduits.isNotEmpty
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5C4033),
        icon: const Icon(Icons.check),
        label: Text("Créer routine (${selectedProduits.length})"),
        onPressed: () {
          // Récupérer les produits sélectionnés avec tous leurs détails
          final produitsSelectionnes = produits
              .where((p) => selectedProduits.contains(p["id"]))
              .toList();

          Navigator.pushNamed(
            context,
            "/creer-routine-complete",
            arguments: {
              "produits": produitsSelectionnes,
              "demande": widget.demande,
            },
          );
        },

      )
          : FloatingActionButton(
        backgroundColor: const Color(0xFF5C4033),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AjouterModifierProduitPage(),
            ),
          ).then((_) => chargerProduits());
        },
      ),


      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg-skin.jpg"),
            fit: BoxFit.cover,
          ),
        ),

        child: loading
            ? const Center(child: CircularProgressIndicator())
            : produits.isEmpty
            ? const Center(
          child: Text(
            "Aucun produit disponible",
            style: TextStyle(color: Colors.brown, fontSize: 18),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: produits.length,
            itemBuilder: (_, i) {
              final p = produits[i];
              final imageUrl = p["imageUrl"] != null
                  ? "http://10.0.2.2:8080${p["imageUrl"]}"
                  : null;

              final isSelected = selectedProduits.contains(p["id"]);

              return GestureDetector(
                onTap: () => toggleSelection(p["id"]),

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 230),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF5C4033)
                          : Colors.transparent,
                      width: 2.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 4,
                              child: imageUrl != null
                                  ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              )
                                  : Container(
                                color: Colors.brown
                                    .withOpacity(0.1),
                                child: const Icon(Icons.image,
                                    size: 70),
                              ),
                            ),

                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p["nom"],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Color(0xFF4B3326),
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      p["type"] ?? "",
                                      style: TextStyle(
                                        color: Colors.brown
                                            .withOpacity(0.7),
                                        fontSize: 13.5,
                                      ),
                                    ),

                                    const Spacer(),

                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.end,
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.brown
                                              .withOpacity(0.1),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: Colors.brown,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      AjouterModifierProduitPage(
                                                        produit: p,
                                                      ),
                                                ),
                                              ).then((_) =>
                                                  chargerProduits());
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.red
                                              .withOpacity(0.1),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                confirmerSuppression(
                                                    p["id"]),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      /// ⭐ Overlay transparent si sélectionné
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}