import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.redAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('images/logo1.png'),
                ),
                const SizedBox(height: 12),

              ],
            ),
          ),

          // Accueil
          ListTile(
            leading: const Icon(Icons.home, color: Colors.pink),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),

          // Dressing
          ListTile(
            leading: const Icon(Icons.checkroom, color: Colors.pink),
            title: const Text('Mon Dressing'),
            onTap: () {
              Navigator.pushNamed(context, '/Dressing');
            },
          ),

          //  Espace Styliste
          ListTile(
            leading: const Icon(Icons.person, color: Colors.pink),
            title: const Text('Espace Styliste'),
            onTap: () {
              Navigator.pushNamed(context, '/styliste');
            },
          ),

          const Divider(color: Colors.black26, thickness: 1, indent: 15, endIndent: 15),

          //  Déconnexion
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.pink),
            title: const Text('Déconnexion'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.pink[50], // 🌸 Fond rose clair
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      "Confirmation",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      "Souhaitez-vous vraiment vous déconnecter ?",
                      style: TextStyle(color: Colors.black87),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Fermer la boîte
                        },
                        child: const Text(
                          "Annuler",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Fermer le dialogue
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                                (Route<dynamic> route) => false,
                          );
                        },

                        child: const Text(
                          "Se déconnecter",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}