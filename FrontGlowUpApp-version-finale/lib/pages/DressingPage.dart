import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/APIService.dart';
import 'creer_look_page.dart';

class DressingStylistePage extends StatefulWidget {
  final int idClient;
  final int idStyliste;

  const DressingStylistePage({super.key, required this.idClient, required this.idStyliste});

  @override
  State<DressingStylistePage> createState() => _DressingStylistePageState();
}

class _DressingStylistePageState extends State<DressingStylistePage> {
  List<Map<String, dynamic>> _vetementsData = [];
  int? _idDressing;
  bool _isLoading = true;
  String _errorMessage = '';
  Set<int> _selectedVetements = {}; // Vêtements sélectionnés pour créer un look

  @override
  void initState() {
    super.initState();
    _initialiserDressingEtChargerVetements();
  }

  Future<void> _initialiserDressingEtChargerVetements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final idDressing = await ApiService.getOrCreateDressing(widget.idClient);
      if (idDressing != null) {
        _idDressing = idDressing;
        await _chargerVetements();
      } else {
        _errorMessage = "Erreur: Dressing introuvable.";
      }
    } catch (e) {
      _errorMessage = "Erreur serveur: $e";
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _chargerVetements() async {
    if (_idDressing == null) return;
    try {
      var data = await ApiService.getVetements(_idDressing!);
      if (mounted) setState(() => _vetementsData = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur chargement: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _toggleSelection(int vetementId) {
    setState(() {
      if (_selectedVetements.contains(vetementId)) {
        _selectedVetements.remove(vetementId);
      } else {
        _selectedVetements.add(vetementId);
      }
    });
  }

  void _ouvrirCreationLook() {
    if (_selectedVetements.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreerLookPage(
          idClient: widget.idClient,
          idStyliste: widget.idStyliste,
          vetementsSelectionnes: _selectedVetements.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: Center(
          child: Text(_errorMessage, style: GoogleFonts.poppins(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Dressing du client #${widget.idClient}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
      ),
      body: _vetementsData.isEmpty
          ? Center(
        child: Text(
          "Aucun vêtement dans le dressing 👗",
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.pinkAccent),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _vetementsData.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: width < 600 ? 2 : 3,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final vet = _vetementsData[index];
          final idVetement = vet['idVetement'] ?? vet['id'];
          final imageUrl = vet['image'] ?? '';
          final selected = _selectedVetements.contains(idVetement);

          return GestureDetector(
            onTap: () => _toggleSelection(idVetement),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? Colors.pinkAccent : Colors.transparent,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? Colors.pinkAccent.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                  )
                ],
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(imageUrl, fit: BoxFit.cover)
                        : const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 40, color: Colors.grey)),
                    if (selected)
                      Container(
                        color: Colors.black26,
                        child: const Icon(Icons.check_circle,
                            color: Colors.white, size: 40),
                      ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        vet['nom'] ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: [const Shadow(color: Colors.black, blurRadius: 3)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: _selectedVetements.isEmpty
          ? null
          : FloatingActionButton.extended(
        backgroundColor: Colors.pinkAccent,
        icon: const Icon(Icons.style),
        label: Text("Créer look (${_selectedVetements.length})"),
        onPressed: _ouvrirCreationLook,
      ),
    );
  }
}
