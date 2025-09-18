import 'package:get/get.dart';

import '../controllers/DriverProfileController.dart';
import '../controllers/RateShipmentController.dart';
import '../controllers/ShipmentDetailsController.dart';
import '../controllers/MyBidsController.dart';
import '../controllers/AvailableLoadsController.dart';
import '../controllers/main_controller.dart'; // ADD THIS
import '../modules/ Support/SupportBinding.dart';
import '../modules/ Support/SupportView.dart';
import '../modules/Bids/AvailableLoadsBinding.dart';
import '../modules/Bids/AvailableLoadsView.dart';
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
import '../modules/bids/MyBidsView.dart';
import '../modules/bids/MyBidsBinding.dart';
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
import '../modules/main/main_view.dart'; // ADD THIS
import '../modules/main/main_binding.dart'; // ADD THIS

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH; // Keep this for normal app flow

  static final routes = [
    // Main wrapper route
    GetPage(
      name: _Paths.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),

    // Auth and initial routes
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

    // Main tab routes (these will be displayed in MainView)
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SHIPMENTS,
      page: () => const ShipmentsView(),
      binding: ShipmentsBinding(),
    ),
    GetPage(
      name: _Paths.BIDDING,
      page: () => const MyBidsView(),
      binding: MyBidsBinding(),
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
    GetPage(
      name: _Paths.AVAILABLE_LOADS,
      page: () => const AvailableLoadsView(),
      binding: AvailableLoadsBinding(),
    ),
    GetPage(
      name: _Paths.MY_BIDS,
      page: () => const MyBidsView(),
      binding: MyBidsBinding(),
    ),

    // Shipment routes
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
  ];
}