import 'package:get/get.dart';

import '../controllers/DriverProfileController.dart';
import '../controllers/RateShipmentController.dart';
import '../controllers/ShipmentDetailsController.dart';
import '../modules/ Support/SupportBinding.dart';
import '../modules/ Support/SupportView.dart';
import '../modules/DeliveryProof/DeliveryProofView.dart';
import '../modules/Driver/DriverProfileView.dart';
import '../modules/Shipments/ShipmentDetailsView.dart';
import '../modules/Shipments/ShipmentsBinding.dart';
import '../modules/Shipments/ShipmentsView.dart';
import '../modules/Shipments/TrackShipmentBinding.dart';
import '../modules/Shipments/TrackShipmentView.dart';
import '../modules/load/CreatedLoadsBinding.dart';
import '../modules/load/CreatedLoadsView.dart';
import '../modules/load/PostLoadBinding.dart';
import '../modules/load/PostLoadView.dart';
import '../modules/rate/RateShipmentView.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/auth/login/login_binding.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/register/register_binding.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';

// // Load management modules
// import '../modules/loads/post_load/post_load_binding.dart';
// import '../modules/loads/post_load/post_load_view.dart';
// import '../modules/loads/created_loads/created_loads_binding.dart';
// import '../modules/loads/created_loads/created_loads_view.dart';
// import '../modules/loads/load_details/load_details_binding.dart';
// import '../modules/loads/load_details/load_details_view.dart';
//
// // Shipment modules
// import '../modules/shipments/shipments_binding.dart';
// import '../modules/shipments/shipments_view.dart';
// import '../modules/shipments/track_shipment/track_shipment_binding.dart';
// import '../modules/shipments/track_shipment/track_shipment_view.dart';
// import '../modules/shipments/shipment_details/shipment_details_binding.dart';
// import '../modules/shipments/shipment_details/shipment_details_view.dart';
//
// // Communication modules
// import '../modules/chat/chat_binding.dart';
// import '../modules/chat/chat_view.dart';
//
// // Support and rating modules
// import '../modules/support/support_binding.dart';
// import '../modules/support/support_view.dart';
// import '../modules/rating/rate_shipment_binding.dart';
// import '../modules/rating/rate_shipment_view.dart';
//
// // Document modules
// import '../modules/delivery_proof/delivery_proof_binding.dart';
// import '../modules/delivery_proof/delivery_proof_view.dart';
//
// // Driver profile module
// import '../modules/driver_profile/driver_profile_binding.dart';
// import '../modules/driver_profile/driver_profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // Core routes
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    // Load management routes
    GetPage(
      name: _Paths.POST_LOAD,
      page: () => const PostLoadView(),
      binding: PostLoadBinding(),
    ),
    GetPage(
      name: _Paths.CREATED_LOADS,
      page: () => const CreatedLoadsView(),
      binding: CreatedLoadsBinding(),
    ),
    // GetPage(
    //   name: _Paths.LOAD_DETAILS,
    //   page: () => const LoadDetailsView(),
    //   binding: LoadDetailsBinding(),
    // ),

    // Shipment routes
    GetPage(
      name: _Paths.SHIPMENTS,
      page: () => const ShipmentsView(),
      binding: ShipmentsBinding(),
    ),
    GetPage(
      name: _Paths.TRACK_SHIPMENT,
      page: () => const TrackShipmentView(),
      binding: TrackShipmentBinding(),
    ),
    GetPage(
      name: _Paths.SHIPMENT_DETAILS,
      page: () => const ShipmentDetailsView(),
      binding: ShipmentDetailsBinding(),
    ),

    // Communication routes
    // GetPage(
    //   name: _Paths.CHAT,
    //   page: () => const ChatView(),
    //   binding: ChatBinding(),
    // ),

    // Support and feedback routes
    GetPage(
      name: _Paths.SUPPORT,
      page: () => const SupportView(),
      binding: SupportBinding(),
    ),
    GetPage(
      name: _Paths.RATE_SHIPMENT,
      page: () => const RateShipmentView(),
      binding: RateShipmentBinding(),
    ),

    // Document routes
    GetPage(
      name: _Paths.DELIVERY_PROOF,
      page: () => const DeliveryProofView(),
      binding: DeliveryProofBinding(),
    ),

    // Driver profile route
    GetPage(
      name: _Paths.DRIVER_PROFILE,
      page: () => const DriverProfileView(),
      binding: DriverProfileBinding(),
    ),

    // Other freight transport routes - add as modules are created
    /*
    GetPage(
      name: _Paths.SEARCH_TRUCKS,
      page: () => const SearchTrucksView(),
      binding: SearchTrucksBinding(),
    ),
    GetPage(
      name: _Paths.BIDDING,
      page: () => const BiddingView(),
      binding: BiddingBinding(),
    ),
    GetPage(
      name: _Paths.BID_DETAILS,
      page: () => const BidDetailsView(),
      binding: BidDetailsBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENTS,
      page: () => const PaymentsView(),
      binding: PaymentsBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_HISTORY,
      page: () => const PaymentHistoryView(),
      binding: PaymentHistoryBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_LOAD,
      page: () => const EditLoadView(),
      binding: EditLoadBinding(),
    ),
    GetPage(
      name: _Paths.LOAD_HISTORY,
      page: () => const LoadHistoryView(),
      binding: LoadHistoryBinding(),
    ),
    GetPage(
      name: _Paths.TRUCK_DETAILS,
      page: () => const TruckDetailsView(),
      binding: TruckDetailsBinding(),
    ),
    GetPage(
      name: _Paths.TRUCK_BOOKING,
      page: () => const TruckBookingView(),
      binding: TruckBookingBinding(),
    ),
    GetPage(
      name: _Paths.MESSAGES,
      page: () => const MessagesView(),
      binding: MessagesBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.DOCUMENTS,
      page: () => const DocumentsView(),
      binding: DocumentsBinding(),
    ),
    GetPage(
      name: _Paths.REPORTS,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    */
  ];
}