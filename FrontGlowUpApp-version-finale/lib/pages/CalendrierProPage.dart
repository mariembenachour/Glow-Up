import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ProgrammeService.dart';
import '../services/SeanceService.dart';

class CalendrierProPage extends StatefulWidget {
  final int clientId;

  const CalendrierProPage({super.key, required this.clientId});

  @override
  State<CalendrierProPage> createState() => _CalendrierProPageState();
}

class _CalendrierProPageState extends State<CalendrierProPage> {
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  Map<DateTime, List<Map<String, dynamic>>> seancesParJour = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _chargerSeances();
  }

  Future<void> _chargerSeances() async {
    try {
      final programmes = await ProgrammeService.getProgrammesByClient(widget.clientId);
      Map<DateTime, List<Map<String, dynamic>>> temp = {};

      for (var prog in programmes) {
        final coach = prog["coach"]?["nom"] ?? "Coach";
        final seances = (prog["seances"] as List<dynamic>?) ?? [];

        for (var s in seances) {
          if (s["heureDebut"] == null) continue;
          final d = DateTime.parse(s["heureDebut"].toString());
          final key = DateTime(d.year, d.month, d.day);

          s["coach"] = coach;
          s["description"] = s["description"]?.toString() ?? '';
          s["heureDebut"] = s["heureDebut"]?.toString() ?? '';
          s["heureFin"] = s["heureFin"]?.toString() ?? '';

          // Récupération sécurisée des médias
          if (s["medias"] != null && s["medias"] is List) {
            s["medias"] = List<String>.from(s["medias"].map((m) => m.toString()));
          } else {
            s["medias"] = [];
          }

          temp.putIfAbsent(key, () => []);
          if (!temp[key]!.any((e) => e["idSeance"] == s["idSeance"])) {
            temp[key]!.add(Map<String, dynamic>.from(s));
          }
        }
      }

      setState(() {
        seancesParJour = temp;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  String _mois(int m) {
    const names = [
      "", "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
      "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
    ];
    return names[m];
  }

  Widget _buildDaysHeader() {
    const days = ["L", "M", "M", "J", "V", "S", "D"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: days
          .map((e) => Expanded(
        child: Center(
          child: Text(
            e,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    DateTime first = DateTime(currentMonth.year, currentMonth.month, 1);
    int start = first.weekday;
    List<Widget> cells = [];

    for (int i = 1; i < start; i++) cells.add(Container());

    for (int i = 1; i <= 31; i++) {
      DateTime d;
      try {
        d = DateTime(currentMonth.year, currentMonth.month, i);
      } catch (_) {
        break;
      }

      final key = DateTime(d.year, d.month, d.day);
      final seances = seancesParJour[key] ?? [];
      Color bg = seances.isNotEmpty ? Colors.blue.withOpacity(0.7) : Colors.grey.withOpacity(.1);

      cells.add(
        GestureDetector(
          onTap: () => _popupJour(key),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                i.toString(),
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(crossAxisCount: 7, children: cells);
  }

  Future<void> _popupJour(DateTime key) async {
    final seances = seancesParJour[key] ?? [];

    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          "Séances du ${key.day}/${key.month}",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: seances.isEmpty
            ? Text("Aucune séance", style: GoogleFonts.poppins())
            : SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: seances.map((s) {
              final desc = s["description"]?.toString() ?? '';
              final coach = s["coach"]?.toString() ?? 'Coach';
              final heureDeb = s["heureDebut"]?.toString() ?? '';
              final heureFin = s["heureFin"]?.toString() ?? '';
              final medias = s["medias"] != null ? List<String>.from(s["medias"]) : [];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(desc, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Coach : $coach", style: GoogleFonts.poppins(color: Colors.grey[700])),
                    Text("Heure : $heureDeb - $heureFin", style: GoogleFonts.poppins(color: Colors.grey[700])),
                    if (medias.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: medias.length,
                          itemBuilder: (context, index) {
                            final url = medias[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 6),
                              child: Image.network(
                                url,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ]
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bleu = const Color(0xFF0A84FF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bleu,
        title: Text("Calendrier Pro", style: GoogleFonts.poppins()),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 12),
          Text(
            "${_mois(currentMonth.month)} ${currentMonth.year}",
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          _buildDaysHeader(),
          Expanded(child: _buildCalendarGrid()),
        ],
      ),
    );
  }
}
