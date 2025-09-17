part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  // Core routes
  static const SPLASH = _Paths.SPLASH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const PROFILE = _Paths.PROFILE;

  // Load management routes
  static const POST_LOAD = _Paths.POST_LOAD;
  static const CREATED_LOADS = _Paths.CREATED_LOADS;
  static const LOAD_DETAILS = _Paths.LOAD_DETAILS;
  static const EDIT_LOAD = _Paths.EDIT_LOAD;
  static const LOAD_HISTORY = _Paths.LOAD_HISTORY;

  // Shipment routes
  static const SHIPMENTS = _Paths.SHIPMENTS;
  static const TRACK_SHIPMENT = _Paths.TRACK_SHIPMENT;
  static const SHIPMENT_DETAILS = _Paths.SHIPMENT_DETAILS;

  // Communication routes
  static const CHAT = _Paths.CHAT;
  static const MESSAGES = _Paths.MESSAGES;

  // Support and feedback routes
  static const SUPPORT = _Paths.SUPPORT;
  static const RATE_SHIPMENT = _Paths.RATE_SHIPMENT;

  // Document routes
  static const DELIVERY_PROOF = _Paths.DELIVERY_PROOF;

  // Driver and transport routes
  static const DRIVER_PROFILE = _Paths.DRIVER_PROFILE;
  static const SEARCH_TRUCKS = _Paths.SEARCH_TRUCKS;
  static const TRUCK_DETAILS = _Paths.TRUCK_DETAILS;
  static const TRUCK_BOOKING = _Paths.TRUCK_BOOKING;

  // Bidding routes
  static const BIDDING = _Paths.BIDDING;
  static const BID_DETAILS = _Paths.BID_DETAILS;

  // Payment routes
  static const PAYMENTS = _Paths.PAYMENTS;
  static const PAYMENT_HISTORY = _Paths.PAYMENT_HISTORY;

  // Other routes
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const DOCUMENTS = _Paths.DOCUMENTS;
  static const REPORTS = _Paths.REPORTS;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();

  // Core paths
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const PROFILE = '/profile';

  // Load management paths
  static const POST_LOAD = '/post-load';
  static const CREATED_LOADS = '/created-loads';
  static const LOAD_DETAILS = '/load-details';
  static const EDIT_LOAD = '/edit-load';
  static const LOAD_HISTORY = '/load-history';

  // Shipment paths
  static const SHIPMENTS = '/shipments';
  static const TRACK_SHIPMENT = '/track-shipment';
  static const SHIPMENT_DETAILS = '/shipment-details';

  // Communication paths
  static const CHAT = '/chat';
  static const MESSAGES = '/messages';

  // Support and feedback paths
  static const SUPPORT = '/support';
  static const RATE_SHIPMENT = '/rate-shipment';

  // Document paths
  static const DELIVERY_PROOF = '/delivery-proof';

  // Driver and transport paths
  static const DRIVER_PROFILE = '/driver-profile';
  static const SEARCH_TRUCKS = '/search-trucks';
  static const TRUCK_DETAILS = '/truck-details';
  static const TRUCK_BOOKING = '/truck-booking';

  // Bidding paths
  static const BIDDING = '/bidding';
  static const BID_DETAILS = '/bid-details';

  // Payment paths
  static const PAYMENTS = '/payments';
  static const PAYMENT_HISTORY = '/payment-history';

  // Other paths
  static const NOTIFICATIONS = '/notifications';
  static const DOCUMENTS = '/documents';
  static const REPORTS = '/reports';
  static const SETTINGS = '/settings';
}