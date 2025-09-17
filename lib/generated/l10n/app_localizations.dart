import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
  <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  // Basic App Translations
  String get welcome;
  String get getStarted;
  String get loading;
  String get skip;
  String get next;
  String get login;
  String get register;
  String get email;
  String get password;
  String get confirmPassword;
  String get forgotPassword;
  String get dontHaveAccount;
  String get alreadyHaveAccount;
  String get signUp;
  String get signIn;
  String get logout;
  String get home;
  String get profile;
  String get settings;
  String get language;
  String get english;
  String get arabic;

  // Onboarding
  String get onboardingTitle1;
  String get onboardingDesc1;
  String get onboardingTitle2;
  String get onboardingDesc2;
  String get onboardingTitle3;
  String get onboardingDesc3;

  // Validation Messages
  String get emailRequired;
  String get passwordRequired;
  String get invalidEmail;
  String get passwordTooShort;
  String get passwordsDoNotMatch;
  String get loginSuccess;
  String get loginFailed;
  String get registrationSuccess;
  String get registrationFailed;

  // Dashboard
  String get quickOverview;
  String get totalShipments;
  String get activeShipments;
  String get completedShipments;
  String get totalSavings;
  String get pendingShipments;
  String get deliveredShipments;
  String get cancelledShipments;
  String get totalRevenue;
  String get averageRating;
  String get thisMonth;
  String get lastMonth;

  // Freight Transport Specific Translations

  // Load Management
  String get postLoad;
  String get createLoad;
  String get loadDetails;
  String get myLoads;
  String get searchLoads;
  String get availableLoads;
  String get loadHistory;
  String get loadStatus;

  // Load Information
  String get loadTitle;
  String get description;
  String get materialType;
  String get loadType;
  String get weight;
  String get dimensions;
  String get volume;
  String get quantity;
  String get kilogram;
  String get meter;
  String get ton;
  String get pieces;

  // Vehicle & Transport
  String get vehicleType;
  String get truck;
  String get miniTruck;
  String get trailer;
  String get container;
  String get pickup;
  String get van;
  String get tempo;
  String get preferredVehicle;
  String get vehicleCapacity;

  // Location & Route
  String get pickupLocation;
  String get deliveryLocation;
  String get fromLocation;
  String get toLocation;
  String get currentLocation;
  String get selectLocation;
  String get searchLocation;
  String get recentLocations;
  String get popularCities;
  String get distance;
  String get route;
  String get estimatedTime;
  String get kilometer;
  String get hour;
  String get minute;

  // Date & Time
  String get pickupDate;
  String get deliveryDate;
  String get pickupTime;
  String get deliveryTime;
  String get preferredDate;
  String get preferredTime;
  String get urgentDelivery;
  String get flexible;
  String get immediate;
  String get scheduled;

  // Pricing & Budget
  String get budget;
  String get price;
  String get quotation;
  String get estimatedCost;
  String get totalCost;
  String get priceRange;
  String get minimumBid;
  String get maximumBid;
  String get rupees;
  String get currency;
  String get negotiable;
  String get fixed;

  // Bidding System
  String get bids;
  String get bidding;
  String get placeBid;
  String get viewBids;
  String get acceptBid;
  String get rejectBid;
  String get bidAmount;
  String get bidders;
  String get topBids;
  String get winningBid;
  String get bidHistory;

  // Transporter Information
  String get transporter;
  String get transporters;
  String get driver;
  String get driverDetails;
  String get transporterProfile;
  String get rating;
  String get reviews;
  String get experience;
  String get completedTrips;
  String get onTimeDelivery;
  String get customerRating;

  // Contact & Communication
  String get contactDetails;
  String get contactPerson;
  String get phone;
  String get phoneNumber;
  String get callTransporter;
  String get sendMessage;
  String get chatWithDriver;
  String get emergencyContact;

  // Requirements & Services
  String get requirements;
  String get specialRequirements;
  String get additionalServices;
  String get loadingUnloading;
  String get packaging;
  String get insurance;
  String get tracking;
  String get gpsTracking;
  String get expressDelivery;
  String get fragileHandling;
  String get temperatureControlled;
  String get documentation;
  String get warehouseFacility;

  // Status & Tracking
  String get status;
  String get tracking;
  String get trackShipment;
  String get liveTracking;
  String get shipmentStatus;
  String get inTransit;
  String get pickedUp;
  String get delivered;
  String get delayed;
  String get cancelled;
  String get confirmed;
  String get assigned;
  String get enRoute;
  String get arrived;

  // Media & Documentation
  String get photos;
  String get images;
  String get addPhoto;
  String get takePhoto;
  String get uploadPhoto;
  String get documents;
  String get loadImages;
  String get proofOfDelivery;
  String get invoices;
  String get receipts;

  // Notifications & Alerts
  String get notifications;
  String get alerts;
  String get newBid;
  String get bidAccepted;
  String get loadAssigned;
  String get pickupReminder;
  String get deliveryAlert;
  String get delayNotification;

  // Terms & Legal
  String get termsOfService;
  String get privacyPolicy;
  String get cancellationPolicy;
  String get refundPolicy;
  String get agreement;
  String get liability;
  String get terms;
  String get conditions;

  // Actions & Buttons
  String get submit;
  String get save;
  String get cancel;
  String get edit;
  String get delete;
  String get confirm;
  String get reject;
  String get accept;
  String get approve;
  String get decline;
  String get update;
  String get refresh;
  String get search;
  String get filter;
  String get sort;
  String get share;
  String get print;
  String get download;
  String get upload;

  // Common UI Elements
  String get selectAll;
  String get clear;
  String get reset;
  String get apply;
  String get close;
  String get back;
  String get continue_;
  String get finish;
  String get retry;
  String get viewMore;
  String get viewLess;
  String get showDetails;
  String get hideDetails;

  // Error Messages
  String get error;
  String get errorOccurred;
  String get tryAgain;
  String get noDataFound;
  String get connectionError;
  String get serverError;
  String get invalidInput;
  String get requiredField;
  String get fieldRequired;
  String get selectRequired;
  String get minimumLength;
  String get maximumLength;
  String get invalidFormat;
  String get invalidPhoneNumber;
  String get invalidAmount;
  String get amountTooLow;
  String get amountTooHigh;

  // Success Messages
  String get success;
  String get loadPosted;
  String get bidPlaced;
  String get profileUpdated;
  String get settingsSaved;
  String get photoUploaded;
  String get documentSaved;

  // Time & Date Formats
  String get today;
  String get tomorrow;
  String get yesterday;
  String get now;
  String get soon;
  String get morning;
  String get afternoon;
  String get evening;
  String get night;
  String get am;
  String get pm;

  // Measurement Units
  String get kg;
  String get grams;
  String get tons;
  String get liters;
  String get meters;
  String get centimeters;
  String get feet;
  String get inches;
  String get kilometers;
  String get miles;

  // Load Categories
  String get generalGoods;
  String get electronics;
  String get furniture;
  String get automotive;
  String get constructionMaterials;
  String get chemicals;
  String get textiles;
  String get foodAndBeverages;
  String get machinery;
  String get rawMaterials;
  String get pharmaceuticals;
  String get perishableGoods;
  String get hazardousMaterials;
  String get oversizedCargo;
  String get documents_;
  String get samples;
  String get personalBelongings;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
          'an issue with the localizations generation tool. Please file an issue '
          'on GitHub with a reproducible sample app and the gen-l10n configuration '
          'that was used.');
}