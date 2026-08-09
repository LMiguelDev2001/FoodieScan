import 'package:flutter/material.dart';
import 'package:foodie_scan/views/main_view.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

//Variable global para las notificaciones.
final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  //Inicializamos el reloj y la zona horaria
  tz.initializeTimeZones();
  final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

  //El icono de la notificacion sera el de la app
  const AndroidInitializationSettings initAndroidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: initAndroidSettings,
  );

  //Inicializamos la configuración de las notificaciones
  await notifications.initialize(settings: initSettings);

  //Preguntamos al usuario sobre si quiere activar las notificaciones o no
  await notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.requestNotificationsPermission();
}

//Funcion para programar las alarmas y configurar las notifiaciones (su formato)
Future<void> expirationDateNotification(
  int fridgeId,
  String productName,
  DateTime expirationDate,
) async {
  //Multiplicamos el id * 10. Des esta froma nos aseguramos que las notificaiones que recibimos sean del producto concreto
  //En l amemoria se detalla mas el como funciona
  int baseId = fridgeId * 10;

  //Decalramos la fecha de caducidad y añadimos la hora explcita de cuando queremos que suene (y desde cuando empeiza a contar el tiempo)
  DateTime targetDate = DateTime(
    expirationDate.year,
    expirationDate.month,
    expirationDate.day,
    1,
    0,
  );

  //Canal config
  const NotificationDetails channelConfig = NotificationDetails(
    android: AndroidNotificationDetails(
      'alertas_caducidad',
      'Alertas de Caducidad',
      channelDescription: 'Avisa cuando un producto va a caducar',
      importance: Importance.max,
      priority: Priority.high,
    ),
  );

  //Caduca en una semana
  DateTime sevenDaysDate = targetDate.subtract(const Duration(days: 7));

  if (sevenDaysDate.isAfter(DateTime.now())) {
    await notifications.zonedSchedule(
      id: baseId + 7,
      title: '¡CADUCA EN 1 SEMANA!',
      body: 'Recuerda que $productName caduca en 7 días.',
      scheduledDate: tz.TZDateTime.from(sevenDaysDate, tz.local),
      notificationDetails: channelConfig,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  //Caduca en 3 dias
  DateTime threeDaysDate = targetDate.subtract(const Duration(days: 3));

  if (threeDaysDate.isAfter(DateTime.now())) {
    await notifications.zonedSchedule(
      id: baseId + 3,
      title: '¡CADUCA EN 3 DÍAS!',
      body: 'Cuidado, $productName caduca en 3 días.',
      scheduledDate: tz.TZDateTime.from(threeDaysDate, tz.local),
      notificationDetails: channelConfig,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
  //Caduca el dia de antes
  DateTime oneDayDate = targetDate.subtract(const Duration(days: 1));

  if (oneDayDate.isAfter(DateTime.now())) {
    await notifications.zonedSchedule(
      id: baseId + 1,
      title: '¡CADUCA MAÑANA!',
      body: '¡Te queda un día para comerte: $productName!',
      scheduledDate: tz.TZDateTime.from(oneDayDate, tz.local),
      notificationDetails: channelConfig,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  //Caduca el mismo dia
  if (targetDate.isAfter(DateTime.now())) {
    await notifications.zonedSchedule(
      id: baseId + 0,
      title: '¡CADUCA HOY!',
      body: '$productName caduca hoy, debes consumirlo ya.',
      scheduledDate: tz.TZDateTime.from(targetDate, tz.local),
      notificationDetails: channelConfig,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    //Si escaneas o ontroduces la fecha despues de las 10:00 am
  } else if (expirationDate.year == DateTime.now().year &&
      expirationDate.month == DateTime.now().month &&
      expirationDate.day == DateTime.now().day) {
    //No hace falta "maquetar" nuevamente la notificaion, simplemente llamamos a mostrarnotificacion.
    mostrarNotificacion(
      baseId + 0,
      '¡CADUCA HOY!',
      '$productName caduca hoy, debes consumirlo ya.',
    );
  }
}

//Funcion hecha para que salten las notifiacones instantaneamente
Future<void> mostrarNotificacion(
  int id,
  String title,
  String description,
) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alertas_caducidad',
    'Alertas de Caducidad',
    importance: Importance.max,
    priority: Priority.high,
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
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else {
    // Iniciamos la configuración de tiempo y permisos nada más abrir la app
    await initNotifications();
  }
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
