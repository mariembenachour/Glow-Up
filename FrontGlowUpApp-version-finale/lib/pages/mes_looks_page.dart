import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/look_service.dart';
import 'look_detail_page.dart';

class MesLooksClientPage extends StatefulWidget {
  final int idClient;
  const MesLooksClientPage({super.key, required this.idClient});

  @override
  State<MesLooksClientPage> createState() => _MesLooksClientPageState();
}

class _MesLooksClientPageState extends State<MesLooksClientPage>
    with SingleTickerProviderStateMixin {
  final LookService _lookService = LookService();
  List<dynamic> _looks = [];
  bool _isLoading = true;
  String _errorMessage = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _chargerLooksClient();
  }

  Future<void> _chargerLooksClient() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final looksClient = await _lookService.getLooksByClient(widget.idClient);
      setState(() {
        _looks = looksClient;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur : $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavoris(dynamic look) async {
    final bool newState = !(look["favoris"] ?? false);
    setState(() {
      look["favoris"] = newState;
    });

    try {
      await _lookService.updateFavoris(look["idLook"], newState);
    } catch (e) {
      setState(() {
        look["favoris"] = !newState; // rollback
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la mise à jour du favori")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Mes Looks"),
          backgroundColor: Colors.pinkAccent,
        ),
        body: Center(
          child: Text(_errorMessage, style: GoogleFonts.poppins(color: Colors.red)),
        ),
      );
    }

    final favoris = _looks.where((l) => l["favoris"] == true).toList();
    final categories = _looks.map((l) => l["categorie"]).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Looks"),
        backgroundColor: Colors.pinkAccent,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Tous"),
            Tab(text: "Catégories"),
            Tab(text: "Favoris"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 🧥 Tous les looks
          _buildLookList(_looks),

          // 📂 Par catégorie
          _buildCategorieTab(categories),

          // ❤️ Favoris
          _buildLookList(favoris),
        ],
      ),
    );
  }

  Widget _buildCategorieTab(List categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final looksCat = _looks.where((l) => l["categorie"] == cat).toList();

        return ExpansionTile(
          title: Text(cat ?? "Inconnue", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          children: [
            _buildLookList(looksCat, shrinkWrap: true),
          ],
        );
      },
    );
  }

  Widget _buildLookList(List looks, {bool shrinkWrap = false}) {
    if (looks.isEmpty) {
      return Center(
        child: Text(
          "Aucun look trouvé",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.all(12),
      itemCount: looks.length,
      itemBuilder: (context, index) {
        final look = looks[index];
        final vetements = (look["vetements"] ?? []) as List<dynamic>;
        final image = vetements.isNotEmpty ? vetements[0]["image"] ?? "" : "";

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: ListTile(
            leading: image.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(image, width: 60, height: 60, fit: BoxFit.cover),
            )
                : const Icon(Icons.image_not_supported, color: Colors.grey),
            title: Text(
              look["nom"] ?? "Look sans nom",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              look["categorie"] ?? "Catégorie inconnue",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(
                (look["favoris"] ?? false) ? Icons.favorite : Icons.favorite_border,
                color: Colors.pinkAccent,
              ),
              onPressed: () => _toggleFavoris(look),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LookDetailPage(look: look)),
              );
            },
          ),
        );
      },
    );
  }
}
