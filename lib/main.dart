import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:push_app/config/local_notifications/local_notifications.dart';
import 'package:push_app/config/router/app_router.dart';
import 'package:push_app/config/theme/app_theme.dart';
import 'package:push_app/presentation/blocs/notifications/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgorundHandler);
  await NotificationsBloc.initializeFCM();
  // await LocalNotifications.initializeLocalNotifications();

  runApp(MultiBlocProvider(providers: [
    BlocProvider(
        create: (_) => NotificationsBloc(
            requestLocalNotificationPermission:
                LocalNotifications.requestPermissionLocalNotifications,
            showLocalNotification: LocalNotifications.showLocalNotification))
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Flutter Demo',
      theme: AppTheme().getTheme(),
      builder: (context, child) => HandleNotifiationInteractions(child: child!),
    );
  }
}

class HandleNotifiationInteractions extends StatefulWidget {
  final Widget child;
  const HandleNotifiationInteractions({super.key, required this.child});

  @override
  State<HandleNotifiationInteractions> createState() =>
      _HandleNotifiationInteractionsState();
}

class _HandleNotifiationInteractionsState
    extends State<HandleNotifiationInteractions> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    context.read<NotificationsBloc>().handleRemoteMessage(message);

    final messageId =
        message.messageId?.replaceAll(":", '').replaceAll('%', '');
    appRouter.push('/push-details/:$messageId');
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
