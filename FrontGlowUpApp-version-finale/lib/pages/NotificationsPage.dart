import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/NotificationService.dart';

class NotificationsPage extends StatefulWidget {
  final int userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Map<String, dynamic>>> _futureNotifications;

  @override
  void initState() {
    super.initState();
    _futureNotifications = NotificationService.getNotifications(widget.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureNotifications = NotificationService.getNotifications(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mes Notifications",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFD2B48C),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/notifications.jpg"),
            fit: BoxFit.cover,
            opacity: 0.35,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureNotifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFD2B48C)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erreur de connexion ❌",
                  style: GoogleFonts.poppins(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              );
            }

            final notifications = snapshot.data!;

            // 🔥 TRI : afficher les plus récentes en haut
            notifications.sort((a, b) =>
                b["idNotification"].compareTo(a["idNotification"]));

            if (notifications.isEmpty) {
              return Center(
                child: Text(
                  "Aucune notification 📭",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final bool lue = notif["etat"] == "Lue";

                  return Card(
                    color: lue ? Colors.white70 : Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        lue ? Colors.grey : Color(0xFFD2B48C),
                        child: const Icon(Icons.notifications, color: Colors.white),
                      ),
                      title: Text(
                        notif["message"],
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight:
                          lue ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                      trailing: !lue
                          ? IconButton(
                        icon: const Icon(Icons.mark_email_read,
                            color: Colors.green),
                        onPressed: () async {
                          final notifId = notif["idNotification"];
                          if (notifId != null) {
                            try {
                              await NotificationService.marquerCommeLue(
                                  int.parse(notifId.toString()));
                              _refresh();
                            } catch (e) {
                              print("Erreur marquage comme lue: $e");
                            }
                          }
                        },
                      )
                          : const Icon(Icons.check,
                          color: Colors.green, size: 22),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
