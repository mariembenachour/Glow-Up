import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/ProgrammeService.dart';
import '../services/SeanceService.dart';

class MesProgrammesPage extends StatefulWidget {
  final int clientId;
  const MesProgrammesPage({super.key, required this.clientId});

  @override
  State<MesProgrammesPage> createState() => _MesProgrammesPageState();
}

class _MesProgrammesPageState extends State<MesProgrammesPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> programmes = [];
  List<Map<String, dynamic>> seances = [];
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    fetchProgrammes();
  }

  Future<void> fetchProgrammes() async {
    setState(() => isLoading = true);
    try {
      programmes = await ProgrammeService.getProgrammesByClient(widget.clientId);
      if (programmes.isNotEmpty) {
        int programmeId = programmes.first["idProgramme"];
        await fetchSeances(programmeId);
      }
    } catch (e) {
      print("Erreur programmes: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> fetchSeances(int programmeId) async {
    try {
      final data = await SeanceService.getSeancesByProgramme(programmeId);
      setState(() {
        seances = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      print("Erreur séances: $e");
    }
  }

  Future<void> ajouterOuModifierSeance(
      int programmeId, {
        required DateTime day,
        Map<String, dynamic>? seance,
      }) async {

    DateTime dateDeb = seance != null && seance['heureDebut'] != null
        ? DateTime.parse(seance['heureDebut'])
        : DateTime(day.year, day.month, day.day, 0, 0);

    DateTime dateFin = seance != null && seance['heureFin'] != null
        ? DateTime.parse(seance['heureFin'])
        : DateTime(day.year, day.month, day.day, 0, 0);

    TextEditingController descCtrl =
    TextEditingController(text: seance?['description'] ?? "");

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (_, setDialog) {
        return AlertDialog(
          title: Text(seance != null ? "Modifier séance" : "Ajouter séance"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextButton(
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(dateDeb),
                  );
                  if (t != null) {
                    setDialog(() {
                      dateDeb = DateTime(day.year, day.month, day.day, t.hour, t.minute);
                    });
                  }
                },
                child: Text("Début : ${DateFormat('HH:mm').format(dateDeb)}"),
              ),
              TextButton(
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(dateFin),
                  );
                  if (t != null) {
                    setDialog(() {
                      dateFin = DateTime(day.year, day.month, day.day, t.hour, t.minute);
                    });
                  }
                },
                child: Text("Fin : ${DateFormat('HH:mm').format(dateFin)}"),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler")
            ),
            TextButton(
              child: const Text("Enregistrer"),
              onPressed: () async {
                DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                DateTime selectedDay = DateTime(day.year, day.month, day.day);

                if (selectedDay.isBefore(today)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠ Impossible d'ajouter une séance dans un jour déjà passé !")),
                  );
                  return;
                }

                if (dateFin.isBefore(dateDeb) || dateFin.isAtSameMomentAs(dateDeb)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("L'heure de fin doit être supérieure à l'heure de début.")),
                  );
                  return;
                }

                for (var s in seances) {
                  if (s['heureDebut'] == null || s['heureFin'] == null) continue;
                  DateTime deb = DateTime.parse(s['heureDebut']);
                  DateTime fin = DateTime.parse(s['heureFin']);
                  if (deb.year == selectedDay.year && deb.month == selectedDay.month && deb.day == selectedDay.day) {
                    bool overlap = dateDeb.isBefore(fin) && dateFin.isAfter(deb);
                    if (overlap && (seance == null || s["idSeance"] != seance["idSeance"])) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Une séance est déjà programmée dans cette plage horaire.")),
                      );
                      return;
                    }
                  }
                }

                try {
                  if (seance == null) {
                    await SeanceService.creerSeanceClient(
                      programmeId: programmeId,
                      description: descCtrl.text.trim(),
                      dateDeb: dateDeb,
                      dateFin: dateFin,
                      files: [],
                    );
                  } else {
                    await SeanceService.modifierSeance(
                      id: seance["idSeance"],
                      description: descCtrl.text.trim(),
                      dateDeb: dateDeb,
                      dateFin: dateFin,
                    );
                  }

                  await fetchSeances(programmeId);

                  if (mounted) Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(seance == null ? "Séance ajoutée" : "Séance modifiée")),
                  );
                } catch (e) {
                  print("Erreur : $e");
                }
              },
            ),
          ],
        );
      }),
    );
  }

  void _ouvrirImagePleineEcran(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeanceImages(List<dynamic> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index].toString();
              final fullImageUrl = imageUrl.startsWith('http') ? imageUrl : 'http://10.0.2.2:8080$imageUrl';
              return GestureDetector(
                onTap: () => _ouvrirImagePleineEcran(fullImageUrl),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      fullImageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildMonthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navBtn(Icons.arrow_back, () {
            setState(() {
              currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
            });
          }),
          Text(
            DateFormat("MMMM yyyy", "fr_FR").format(currentMonth),
            style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          _navBtn(Icons.arrow_forward, () {
            setState(() {
              currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
            });
          }),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget buildCalendar(int programmeId) {
    int days = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    return Column(
      children: [
        buildMonthHeader(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.1),
            itemCount: days,
            itemBuilder: (_, i) {
              final day = DateTime(currentMonth.year, currentMonth.month, i + 1);
              final hasSeance = seances.any((s) {
                if (s['heureDebut'] == null) return false;
                final d = DateTime.tryParse(s['heureDebut']);
                return d != null && d.year == day.year && d.month == day.month && d.day == day.day;
              });
              return GestureDetector(
                onTap: () => showDaySeances(programmeId, day),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: hasSeance ? Colors.blue.withOpacity(0.8) : Colors.white.withOpacity(0.15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
                  ),
                  child: Center(
                    child: Text(
                      "${i + 1}",
                      style: GoogleFonts.montserrat(
                        color: hasSeance ? Colors.white : Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void showDaySeances(int programmeId, DateTime day) {
    final list = seances.where((s) {
      if (s['heureDebut'] == null) return false;
      final d = DateTime.tryParse(s['heureDebut']);
      return d != null && d.year == day.year && d.month == day.month && d.day == day.day;
    }).toList();

    showModalBottomSheet(
      backgroundColor: Colors.white.withOpacity(0.0),
      context: context,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Séances du ${DateFormat('dd/MM/yyyy').format(day)}",
                  style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...list.map((s) => buildSeanceCard(programmeId, s, day)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text("Ajouter une séance"),
                  onPressed: () {
                    Navigator.pop(context);
                    ajouterOuModifierSeance(programmeId, day: day);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSeanceCard(int programmeId, Map<String, dynamic> s, DateTime day) {
    final debut = DateFormat('HH:mm').format(DateTime.parse(s['heureDebut']));
    final fin = DateFormat('HH:mm').format(DateTime.parse(s['heureFin']));
    final images = s["images"] ?? [];
    final String createur = s["createur"] ?? "client";
    final bool estComplete = s["estComplete"] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)]),
      child: Column(
        children: [
          ListTile(
            title: Text(s["description"], style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
            subtitle: Text("$debut - $fin"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (createur == "CLIENT") ...[
                  IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.pop(context);
                        ajouterOuModifierSeance(programmeId, day: day, seance: s);
                      }),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool? confirm = await _confirmDelete();
                      if (confirm == true) {
                        await SeanceService.supprimerSeance(s["idSeance"]);
                        await fetchSeances(programmeId);
                        Navigator.pop(context);
                        showDaySeances(programmeId, day);
                      }
                    },
                  ),
                ],
                if (createur == "COACH" && !estComplete)
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () async {
                      await SeanceService.completerSeance(s["idSeance"]);
                      await fetchSeances(programmeId);
                      Navigator.pop(context);
                      showDaySeances(programmeId, day);
                    },
                  ),
                if (estComplete) const Icon(Icons.check_circle, color: Colors.grey),
              ],
            ),
          ),
          _buildSeanceImages(images),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete() {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Supprimer"),
          content: const Text("Voulez-vous supprimer cette séance ?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer")),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (programmes.isEmpty) return Scaffold(appBar: AppBar(title: const Text("Mon Programme")), body: const Center(child: Text("veuillez envoyer une demande au coach d'abord")));

    int programmeId = programmes.first["idProgramme"];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text("Mon Programme"), backgroundColor: Colors.indigoAccent, elevation: 0),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("images/yoga.webp", fit: BoxFit.cover)),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: kToolbarHeight + 20), child: buildCalendar(programmeId)),
        ],
      ),
    );
  }
}