import 'package:flutter/material.dart';
import '../../services/RoutineService.dart';

class CreerRoutineCompletePage extends StatefulWidget {
  final List produits;
  final Map? demande;

  const CreerRoutineCompletePage({super.key, required this.produits, this.demande});

  @override
  State<CreerRoutineCompletePage> createState() => _CreerRoutineCompletePageState();
}

class _CreerRoutineCompletePageState extends State<CreerRoutineCompletePage> {
  final _formKey = GlobalKey<FormState>();
  final RoutineService service = RoutineService();

  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController soinTimeController = TextEditingController();

  bool loading = false;

  void creerRoutine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final utilisateurId = widget.demande?["utilisateurId"] ?? 1;
      final List<int> produitIds =
      widget.produits.map<int>((p) => p["id"] as int).toList();

      final routine = await service.creerRoutineComplete(
        utilisateurId,
        titreController.text,
        descriptionController.text,
        soinTimeController.text,
        produitIds,
      );

      if (routine != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Routine créée avec succès")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur: réponse vide du backend")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
      print("Erreur détaillée: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Créer Routine",
            style: TextStyle(color: Color(0xff5C4033), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xff5C4033)),
      ),

      body: Stack(
        children: [
          /// ⭐ BACKGROUND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/bg-s.webp"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ⭐ FILTRE BEIGE
          Container(color: const Color(0xCCFFF4E6)),

          /// ⭐ FORM CARD
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.90),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      /// Titre
                      TextFormField(
                        controller: titreController,
                        decoration: _inputStyle("Titre"),
                        validator: (v) =>
                        v == null || v.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 18),

                      /// Description
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: _inputStyle("Description"),
                        validator: (v) =>
                        v == null || v.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 18),

                      /// Soin Time
                      TextFormField(
                        controller: soinTimeController,
                        decoration: _inputStyle("Soin Time"),
                        validator: (v) =>
                        v == null || v.isEmpty ? "Champ requis" : null,
                      ),
                      const SizedBox(height: 30),

                      /// BUTTON
                      loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff5C4033),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: creerRoutine,
                          child: const Text(
                            "Créer Routine",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// STYLE DES INPUTS
  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xff5C4033), fontWeight: FontWeight.w600),
      filled: true,
      fillColor: const Color(0xFFFFF8EF),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xffBFA58A)),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xff5C4033), width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}
