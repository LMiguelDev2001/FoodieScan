import 'package:flutter/material.dart';
import 'package:foodie_scan/models/model_fridge.dart';
import 'package:foodie_scan/views/main_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:workmanager/workmanager.dart';
import '../services/database_helper.dart';

//Variable global para las notificaciones.
final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  //Icono por defecto de flutter.
  const AndroidInitializationSettings initAndroidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: initAndroidSettings,
  );

  //Iniciacmos la configuraciond de las notificaciones.
  await notifications.initialize(settings: initSettings);

  //Preguntamos al uisuario sobre si quiere activar las notificaiones o no.
  await notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();
}

//Tarjeta de notificacion
Future<void> mostrarNotificacion(
  int id,
  String title,
  String description,
) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', //Id de la fecha
    'channel_name', //Nombre del canala (es lo que podra ver el usuario)
    channelDescription:
        'Notificaciones para avisar cuando caduca un producto :)',

    //Concretamos la inportancia (con esto las notificaiones salen en la parte de arriba de la app)
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker', //Vibracion
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await notifications.show(
    id: id,
    title: title,
    body: description,
    notificationDetails: notificationDetails,
  );
}

Future main() async {
  //Con esto obligamois a dart a que inicialice las funcion initNotifications antes que la propia app.
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();

  //Cuando la app esa desactivada:
  await Workmanager().initialize(backgroundNotifications);

  await Workmanager().registerPeriodicTask(
    "channel_1",
    "channel_2",
    initialDelay: const Duration(hours: 24),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodie Scan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E2C),
      ),
      home: const MainView(),
    );
  }
}

//Manegador de notificaiones cuando la app no esta activada.
@pragma('vm:entry-point')
Future<void> checkExpirationDate() async {
  final FlutterLocalNotificationsPlugin hiddenNotifications =
      FlutterLocalNotificationsPlugin();
  //El icono
  const AndroidInitializationSettings initAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: initAndroid,
  );

  await hiddenNotifications.initialize(settings: initSettings);
  //Configuramos un segundo vanal para cuando esta en segundo desactivada
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channel_id', //Id de la fecha
    'channel_name', //Nombre del canala (es lo que podra ver el usuario)
    channelDescription:
        'Notificaciones para avisar cuando caduca un producto :)',

    //Concretamos la inportancia (con esto las notificaiones salen en la parte de arriba de la app)
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker', //Vibracion
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  try {
    final List<ModelFridge> resGoods = await DatabaseHelper.instance
        .readGoods();

    //Fecha de hoy
    final DateTime now = DateTime.now();
    //Fecha de hoy fromateada
    final DateTime today = DateTime(now.year, now.month, now.day);

    //Creamos un bucle para recorrer todos los producot en nuestro inventario y comparamos las fechas de caducidad con las de hoy.
    for (ModelFridge items in resGoods) {
      int dateDiff = items.expirationDate.difference(today).inDays;

      String itemName = items.productName ?? "No name";

      String day = items.expirationDate
          .toIso8601String()
          .split('T')[0]
          .split('-')[2];

      //Cuando queda una semana
      if (dateDiff == 7) {
        await hiddenNotifications.show(
          id: items.id!,
          title: '¡CADUCA EN 1 SEMANA!',
          body: 'Recuerda que $itemName caduca el $day',
          notificationDetails: notificationDetails,
        );
      }
      //Cuando caduca en 3 días
      else if (dateDiff == 3) {
        await hiddenNotifications.show(
          id: items.id!,
          title: '¡CADUCA EN 3 DÍAS!',
          body: 'Recuerda que $itemName caduca el $day',
          notificationDetails: notificationDetails,
        );
      }
      //Cuando quedan 2 días para que caduque.
      else if (dateDiff == 1) {
        await hiddenNotifications.show(
          id: items.id!,
          title: '¡CADUCA MAÑANA!',
          body: 'Recuerda que $itemName caduca mañana',
          notificationDetails: notificationDetails,
        );
      }
      //Cuando caduca el mismo día.
      else if (dateDiff == 0) {
        await hiddenNotifications.show(
          id: items.id!,
          title: '¡CADUCA HOY!',
          body: 'Recuerda que $itemName caduca hoy, debes consumirlo',
          notificationDetails: notificationDetails,
        );
      }
    }
  } catch (error) {
    print(error);
  }
}

void backgroundNotifications() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    await checkExpirationDate();
    return Future.value(true);
  });
}
