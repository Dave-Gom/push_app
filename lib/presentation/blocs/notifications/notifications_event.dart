part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class NotificationStatusChanged extends NotificationsEvent {
  final AuthorizationStatus status;
  NotificationStatusChanged(this.status);
}

class NotificationRecived extends NotificationsEvent {
  final PushMessage pushMessage;
  NotificationRecived(this.pushMessage);
}
