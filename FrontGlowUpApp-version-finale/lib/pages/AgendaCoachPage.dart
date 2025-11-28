import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ProgrammeService.dart';
import '../services/SeanceService.dart';

class ProgrammeCreatorPage extends StatefulWidget {
  final int clientId;
  final int demandeId;
  final int coachId;

  final Map<String, dynamic>? programmeData; // priorité si existant

  const ProgrammeCreatorPage({
    super.key,
    required this.clientId,
    required this.demandeId,
    required this.coachId,
    this.programmeData,
  });

  @override
  State<ProgrammeCreatorPage> createState() => _ProgrammeCreatorPageState();
}

class _ProgrammeCreatorPageState extends State<ProgrammeCreatorPage> {
  int? programmeId;
  final Map<DateTime, List<Map<String, dynamic>>> agenda = {};
  bool isLoading = true;

  DateTime displayedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initProgramme();
  }

  // ============================================================
  // 🔥 INITIALISATION DU PROGRAMME
  // ============================================================
  Future<void> _initProgramme() async {
    try {
      // 1️⃣ PRIORITÉ À programmeData envoyé via CoachHomePage
      if (widget.programmeData != null) {
        final prog = widget.programmeData!;
        programmeId = prog["idProgramme"] ?? prog["id"];

        final seances = (prog["seances"] as List<dynamic>?) ?? [];

        for (var s in seances) {
          if (s["heureDebut"] == null) continue;

          final d = DateTime.parse(s["heureDebut"].toString());
          final key = DateTime(d.year, d.month, d.day);

          agenda[key] ??= [];
          agenda[key]!.add(Map<String, dynamic>.from(s));
        }

        setState(() => isLoading = false);
        return;
      }

      // 2️⃣ SINON ON CHARGE DEPUIS L’API
      final programmes = await ProgrammeService.getProgrammesByClient(widget.clientId);

      if (programmes.isNotEmpty) {
        final prog = programmes.first;
        programmeId = prog["idProgramme"] ?? prog["id"];

        final seances = (prog["seances"] as List<dynamic>?) ?? [];

        for (var s in seances) {
          if (s["heureDebut"] == null) continue;

          final d = DateTime.parse(s["heureDebut"].toString());
          final key = DateTime(d.year, d.month, d.day);

          agenda[key] ??= [];
          agenda[key]!.add(Map<String, dynamic>.from(s));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  int daysInMonth(DateTime date) {
    final firstDayNextMonth = DateTime(date.year, date.month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  // ============================================================
  // 🔥 UI PRINCIPALE
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final bleuFonce = const Color(0xFF001F3F);
    final bleuClair = const Color(0xFF3A6EA5);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'images/sallesport.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "Créer un Programme",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: bleuFonce,
          ),
          floatingActionButton: programmeId != null
              ? FloatingActionButton.extended(
            backgroundColor: bleuClair,
            label: const Text("Attribuer au Client"),
            onPressed: () async {
              try {
                await ProgrammeService.attribuerProgramme(programmeId!, widget.clientId);
                if (!mounted) return;

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Programme attribué au client ✅")),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erreur attribution: $e")),
                );
              }
            },
          )
              : null,
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              _buildMonthNavigation(),
              _buildDaysHeader(),
              Expanded(child: _buildMonthGrid()),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 🔥 NAVIGATION ENTRE LES MOIS
  // ============================================================
  Widget _buildMonthNavigation() {
    const months = [
      "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  displayedMonth = DateTime(displayedMonth.year, displayedMonth.month - 1, 1);
                });
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white)),
          Text(
            "${months[displayedMonth.month - 1]} ${displayedMonth.year}",
            style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          IconButton(
              onPressed: () {
                setState(() {
                  displayedMonth = DateTime(displayedMonth.year, displayedMonth.month + 1, 1);
                });
              },
              icon: const Icon(Icons.arrow_forward, color: Colors.white)),
        ],
      ),
    );
  }

  // ============================================================
  // 🔥 JOUR DE LA SEMAINE
  // ============================================================
  Widget _buildDaysHeader() {
    final days = ["L", "M", "M", "J", "V", "S", "D"];
    return Row(
      children: days
          .map((d) => Expanded(
        child: Center(
          child: Text(
            d,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ))
          .toList(),
    );
  }

  // ============================================================
  // 🔥 CALENDRIER
  // ============================================================
  Widget _buildMonthGrid() {
    final firstDayOfMonth = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final totalDays = daysInMonth(displayedMonth);
    final startWeekday = (firstDayOfMonth.weekday % 7);

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: totalDays + startWeekday,
      itemBuilder: (context, index) {
        if (index < startWeekday) return const SizedBox();

        final dayNum = index - startWeekday + 1;
        final day = DateTime(displayedMonth.year, displayedMonth.month, dayNum);

        final hasSeances = agenda[day]?.isNotEmpty ?? false;

        return GestureDetector(
          onTap: () => _openDayPopup(day),
          child: Container(
            decoration: BoxDecoration(
              color: hasSeances
                  ? Colors.blue.withOpacity(0.6)
                  : Colors.white.withOpacity(0.30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white70),
            ),
            child: Center(
              child: Text(
                "$dayNum",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔥 POPUP CREATION / AFFICHAGE DES SÉANCES
  // ============================================================
  Future<void> _openDayPopup(DateTime day) async {
    final descCtrl = TextEditingController();
    TimeOfDay? hDebut;
    TimeOfDay? hFin;
    List<XFile> medias = [];

    final seancesDuJour = List<Map<String, dynamic>>.from(agenda[day] ?? []);

    await showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, ss) {
            void localSetState(VoidCallback fn) => ss(() => fn());

            return AlertDialog(
              title: Text(
                "Séances du ${day.day}/${day.month}",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (seancesDuJour.isNotEmpty)
                      ...seancesDuJour.map((s) {
                        final deb = DateTime.parse(s["heureDebut"]);
                        final fin = DateTime.parse(s["heureFin"]);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${deb.hour.toString().padLeft(2, '0')}:${deb.minute.toString().padLeft(2, '0')}  -  "
                                    "${fin.hour.toString().padLeft(2, '0')}:${fin.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s["description"] ?? "",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder()),
                    ),
                    ListTile(
                      title: Text(
                          hDebut == null
                              ? "Heure début"
                              : "Début : ${hDebut!.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final pick = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 10, minute: 0),
                        );
                        if (pick != null) localSetState(() => hDebut = pick);
                      },
                    ),
                    ListTile(
                      title: Text(
                          hFin == null
                              ? "Heure fin"
                              : "Fin : ${hFin!.format(context)}"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final pick = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 11, minute: 0),
                        );
                        if (pick != null) localSetState(() => hFin = pick);
                      },
                    ),

                    ElevatedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final files = await picker.pickMultiImage();
                        if (files.isNotEmpty) {
                          localSetState(() => medias.addAll(files));
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: const Text("Ajouter images"),
                    ),
                    if (medias.isNotEmpty)
                      Text("${medias.length} image(s) sélectionnées"),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Fermer")),
                TextButton(
                  child: const Text("Créer"),
                  onPressed: () async {
                    if (programmeId == null) return;

                    if (hDebut == null || hFin == null || descCtrl.text.trim().isEmpty) {
                      return;
                    }

                    final now = DateTime.now();
                    final today = DateTime(now.year, now.month, now.day);
                    final selected = DateTime(day.year, day.month, day.day);

                    if (selected.isBefore(today)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Impossible d'ajouter une séance dans un jour passé ❌"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final newStart = DateTime(
                        day.year, day.month, day.day, hDebut!.hour, hDebut!.minute);
                    final newEnd = DateTime(
                        day.year, day.month, day.day, hFin!.hour, hFin!.minute);

                    final key = DateTime(day.year, day.month, day.day);

                    // Vérification chevauchements
                    final exist = agenda[key] ?? [];
                    final chevauche = exist.any((s) {
                      final start = DateTime.parse(s["heureDebut"]);
                      final end = DateTime.parse(s["heureFin"]);
                      return newStart.isBefore(end) && newEnd.isAfter(start);
                    });

                    if (chevauche) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text("Cette séance chevauche une séance existante ⚠️"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final seanceMap = {
                      "description": descCtrl.text.trim(),
                      "heureDebut": formatDateTime(newStart),
                      "heureFin": formatDateTime(newEnd),
                    };

                    try {
                      final created = await SeanceService.creerSeanceCoach(
                        seanceMap,
                        programmeId!,
                        medias,
                      );

                      if (!mounted) return;

                      setState(() {
                        agenda[key] ??= [];
                        agenda[key]!.add(created);
                      });

                      Navigator.pop(context);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erreur création séance : $e")),
                      );
                    }
                  },
                ),
              ],
            );
          }),
    );
  }

  String formatDateTime(DateTime dt) {
    String two(int x) => x.toString().padLeft(2, '0');
    return "${dt.year}-${two(dt.month)}-${two(dt.day)}T${two(dt.hour)}:${two(dt.minute)}";
  }
}
