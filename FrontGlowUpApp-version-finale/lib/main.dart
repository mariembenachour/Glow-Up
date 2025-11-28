import 'package:flutter/material.dart';
import 'package:glowupf/pages/AgendaCoachPage.dart';
import 'package:glowupf/pages/CoachHomePage.dart';

import 'package:glowupf/pages/loginC.dart';
import 'package:glowupf/pages/skincare/CreerRoutinePage.dart';
import 'package:glowupf/pages/skincare/DermDashboardPage.dart';
import 'package:glowupf/pages/skincare/DermatologistsListPage.dart';
import 'package:glowupf/pages/skincare/HomePage.dart';
import 'package:glowupf/pages/skincare/InscriptionDermatoPage.dart';
import 'package:glowupf/pages/skincare/MyRoutinesPage.dart';
import 'package:glowupf/pages/skincare/RoutineDetailPage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/Auth.dart';
import 'pages/EspaceStylist.dart';
import 'pages/Login.dart'; // Contient InscriptionClient
import 'pages/choixRole.dart';
import 'pages/loginS.dart'; // Contient InscriptionStyliste

import 'pages/Dressing.dart';
import 'pages/Stylistes.dart';
import 'pages/home.dart';
import 'pages/PageChoix.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(const StyleApp());
}

class InscriptionDermato extends StatelessWidget {
  const InscriptionDermato({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Page Inscription Dermato')));
}

class StyleApp extends StatelessWidget {
  const StyleApp({super.key});

  static int _extractId(BuildContext context, String key) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      final dynamic idValue = arguments[key];

      if (idValue is int) {
        return idValue;
      } else if (idValue is String) {
        return int.tryParse(idValue) ?? 0;
      } else if (idValue is double) {
        return idValue.toInt();
      }
    }
    return 0;
  }

  static int _extractIdClient(BuildContext context) {
    return _extractId(context, 'idClient');
  }

  static int _extractIdStyliste(BuildContext context) {
    return _extractId(context, 'idStyliste'); // Utilisé pour /stylisteHome
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Glow Up',
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr', 'FR'),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.pinkAccent,
            secondary: Colors.redAccent,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),

        routes: {
          '/': (context) => const AuthPage(), // Page de démarrage (Connexion)
          '/choixRole': (context) => const ChoixRolePage(),

          '/registerClient': (context) => const InscriptionClient(),
          '/registerStyliste': (context) => const InscriptionStyliste(),
          '/registerCoach': (context) => const InscriptionCoach(),
          '/registerDermato': (context) => const InscriptionDermatoPage(),

          '/home': (context) {
            final idClient = StyleApp._extractIdClient(context);
            return HomePage(idClient: idClient);
          },
          '/Dressing': (context) {
            final idClient = StyleApp._extractIdClient(context);
            return DressingPage(idClient: idClient);
          },
          '/styliste': (context) {
            final idClient = StyleApp._extractIdClient(context);
            return StylistesPage(clientId: idClient);
          },

          '/stylisteHome': (context) {
            final idStyliste = StyleApp._extractIdStyliste(context);
            return EspaceStylistePage(stylisteId: idStyliste);
          },
          '/choix': (context) {
            final idClient = StyleApp._extractIdClient(context);
            return ChoixPage(idClient: idClient);
          },
          '/coachs': (context) {
            final idCoach = StyleApp._extractId(context, 'idCoach');
            return CoachHomePage(coachId: idCoach);
          },
          '/programmeCreator': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
            return ProgrammeCreatorPage(
              clientId: args['clientId'],
              demandeId: args['demandeId'],
              coachId: args['coachId'],
            );
          },
          '/dermatologists': (context) {
            final idClient = _extractIdClient(context);
            return DermatologistsListPage(clientId: idClient);
          },

          '/myRoutines': (context) {
            final idClient = _extractIdClient(context);
            return MyRoutinesPage(clientId: idClient);
          },

          '/routineDetail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;
            return RoutineDetailPage(routine: args['routine']);
          },
          "/creer-routine-complete": (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map;

            final produits = args["produits"] as List;
            final demande = args["demande"] as Map?;

            return CreerRoutineCompletePage(
              produits: produits,
              demande: demande,
            );
          },


          '/dermatologistDashboard': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            final idDermato = args['idDermato'] as int;
            return DermDashboardPage(dermatologueId: idDermato);
          }}
    );
  }
}