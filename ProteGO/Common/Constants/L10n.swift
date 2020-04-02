// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// Restrictions on movement except for travel to work, volunteering, and arranging matters necessary for everyday life.
  internal static let dashboardGreenRecommend1 = L10n.tr("Localizable", "dashboard_green_recommend_1")
  /// There can be as many people on the bus as half the number of seats.
  internal static let dashboardGreenRecommend2 = L10n.tr("Localizable", "dashboard_green_recommend_2")
  /// Total ban on gatherings, except with the closest ones.
  internal static let dashboardGreenRecommend3 = L10n.tr("Localizable", "dashboard_green_recommend_3")
  /// More information %@.
  internal static func dashboardGreenRecommendMoreInfoBtn(_ p1: String) -> String {
    return L10n.tr("Localizable", "dashboard_green_recommend_more_info_btn", p1)
  }
  /// here
  internal static let dashboardGreenRecommendMoreInfoBtnHere = L10n.tr("Localizable", "dashboard_green_recommend_more_info_btn_here")
  /// Current govermental recommendations
  internal static let dashboardGreenRecommendTitle = L10n.tr("Localizable", "dashboard_green_recommend_title")
  /// It seems you weren't close to infected people
  internal static let dashboardGreenStatusDescription = L10n.tr("Localizable", "dashboard_green_status_description")
  /// Learn more on about the precautions, click %@
  internal static func dashboardGreenStatusMoreInfoBtn(_ p1: String) -> String {
    return L10n.tr("Localizable", "dashboard_green_status_more_info_btn", p1)
  }
  /// here
  internal static let dashboardGreenStatusMoreInfoBtnHere = L10n.tr("Localizable", "dashboard_green_status_more_info_btn_here")
  /// We didn't dectect any threat
  internal static let dashboardGreenStatusTitle = L10n.tr("Localizable", "dashboard_green_status_title")
  /// Need to send us an email?
  internal static let dashboardInfoContactUsDescription = L10n.tr("Localizable", "dashboard_info_contact_us_description")
  /// kontakt@protego.gov.pl
  internal static let dashboardInfoContactUsEmail = L10n.tr("Localizable", "dashboard_info_contact_us_email")
  /// Od godziny
  internal static let dashboardInfoFromTime = L10n.tr("Localizable", "dashboard_info_from_time")
  /// Devices detected since %@: %@
  internal static func dashboardInfoHistoryOverview(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Localizable", "dashboard_info_history_overview", p1, p2)
  }
  /// xxx xxx xxx
  internal static let dashboardInfoIdPlacehloder = L10n.tr("Localizable", "dashboard_info_id_placehloder")
  /// telefonów z aktywnie działającą aplikacją
  internal static let dashboardInfoPhonesWithApp = L10n.tr("Localizable", "dashboard_info_phones_with_app")
  /// Send history
  internal static let dashboardInfoSendDataBtn = L10n.tr("Localizable", "dashboard_info_send_data_btn")
  /// ProteGO Terms of Use
  internal static let dashboardInfoTermsOfUseBtn = L10n.tr("Localizable", "dashboard_info_terms_of_use_btn")
  /// version
  internal static let dashboardInfoVersion = L10n.tr("Localizable", "dashboard_info_version")
  /// pojawiło się wokół Ciebie
  internal static let dashboardInfoYouEncountered = L10n.tr("Localizable", "dashboard_info_you_encountered")
  /// Your ID:
  internal static let dashboardInfoYourId = L10n.tr("Localizable", "dashboard_info_your_id")
  /// Restrictions on movement except for travel to work, volunteering, and arranging matters necessary for everyday life.
  internal static let dashboardRedRecommend1 = L10n.tr("Localizable", "dashboard_red_recommend_1")
  /// There can be as many people on the bus as half the number of seats.
  internal static let dashboardRedRecommend2 = L10n.tr("Localizable", "dashboard_red_recommend_2")
  /// Total ban on gatherings, except with the closest ones.
  internal static let dashboardRedRecommend3 = L10n.tr("Localizable", "dashboard_red_recommend_3")
  /// More information %@.
  internal static func dashboardRedRecommendMoreInfoBtn(_ p1: String) -> String {
    return L10n.tr("Localizable", "dashboard_red_recommend_more_info_btn", p1)
  }
  /// here
  internal static let dashboardRedRecommendMoreInfoBtnHere = L10n.tr("Localizable", "dashboard_red_recommend_more_info_btn_here")
  /// Current govermental recommendations
  internal static let dashboardRedRecommendTitle = L10n.tr("Localizable", "dashboard_red_recommend_title")
  /// Contact an expert
  internal static let dashboardRedStatusContactBtn = L10n.tr("Localizable", "dashboard_red_status_contact_btn")
  /// You were close to people infected with SARS-CoV-2. Call the nearest GIS. Stay at home quarantine.
  internal static let dashboardRedStatusDescription = L10n.tr("Localizable", "dashboard_red_status_description")
  /// You were close to infected people.
  internal static let dashboardRedStatusTitle = L10n.tr("Localizable", "dashboard_red_status_title")
  /// Po więcej informacji kliknij %@.
  internal static func dashboardYellowMoreInfoBtn(_ p1: String) -> String {
    return L10n.tr("Localizable", "dashboard_yellow_more_info_btn", p1)
  }
  /// tutaj
  internal static let dashboardYellowMoreInfoBtnHere = L10n.tr("Localizable", "dashboard_yellow_more_info_btn_here")
  /// Restrictions on movement except for travel to work, volunteering, and arranging matters necessary for everyday life.
  internal static let dashboardYellowRecommend1 = L10n.tr("Localizable", "dashboard_yellow_recommend_1")
  /// There can be as many people on the bus as half the number of seats.
  internal static let dashboardYellowRecommend2 = L10n.tr("Localizable", "dashboard_yellow_recommend_2")
  /// Total ban on gatherings, except with the closest ones.
  internal static let dashboardYellowRecommend3 = L10n.tr("Localizable", "dashboard_yellow_recommend_3")
  /// More information %@.
  internal static func dashboardYellowRecommendMoreInfoBtn(_ p1: String) -> String {
    return L10n.tr("Localizable", "dashboard_yellow_recommend_more_info_btn\n", p1)
  }
  /// here
  internal static let dashboardYellowRecommendMoreInfoBtnHere = L10n.tr("Localizable", "dashboard_yellow_recommend_more_info_btn_here")
  /// Current govermental recommendations
  internal static let dashboardYellowRecommendTitle = L10n.tr("Localizable", "dashboard_yellow_recommend_title")
  /// Będziemy w stanie określić Twoje ryzyko zarażenia po 14 dniach korzystania z aplikacji. Zachowaj ostrożność i ogranicz wyjścia do minimum.
  internal static let dashboardYellowStatusDescription = L10n.tr("Localizable", "dashboard_yellow_status_description")
  /// Uważaj na siebie!
  internal static let dashboardYellowStatusTitle = L10n.tr("Localizable", "dashboard_yellow_status_title")
  /// Do korzystania z aplikacji niezbędne jest połączenie z internetem. Włącz wi-fi lub transmisję danych, żeby kontynuować. 
  internal static let errorNoInternetDescription = L10n.tr("Localizable", "error_no_internet_description")
  /// Przejdź do ustawień
  internal static let errorNoInternetGoToSeetingsBtn = L10n.tr("Localizable", "error_no_internet_go_to_seetings_btn")
  /// Turn on the Internet
  internal static let errorNoInternetTitle = L10n.tr("Localizable", "error_no_internet_title")
  /// Zaktualizuj aplikację
  internal static let errorUdateTitle = L10n.tr("Localizable", "error_udate_title")
  /// Do poprawnego funkcjonowania aplikacji niezbędna jest najnowsza wersja. Przejdź do App Store lub Google Play, żeby zaktualizować ProteGO.
  internal static let errorUpdateDescription = L10n.tr("Localizable", "error_update_description")
  /// Zaktualizuj aplikację
  internal static let errorUpdateUpdateBtn = L10n.tr("Localizable", "error_update_update_btn")
  /// Back
  internal static let onboardingBackBtn = L10n.tr("Localizable", "onboarding_back_btn")
  /// The applicatioin requires Bluetooth to be turned on all the time\n\nProteGO scans your surrounding for other app users via Bluetooth.\n\nThe app stores the 2 weeks history of all your encounters encrypted on your device and doesn't send it anywhere.
  internal static let onboardingBluetoothDescription = L10n.tr("Localizable", "onboarding_bluetooth_description")
  /// Turn on Bluetooth
  internal static let onboardingBluetoothTitle = L10n.tr("Localizable", "onboarding_bluetooth_title")
  /// We didn't dectect any threat
  internal static let onboardingGreenDescription = L10n.tr("Localizable", "onboarding_green_description")
  /// Thank you for installing ProteGO.\n\nThe app will allow you you learn if there is risk you were close to people infected with coronavirus SARS-CoV-2.
  internal static let onboardingHelloDescription = L10n.tr("Localizable", "onboarding_hello_description")
  /// Welcome to ProteGO!
  internal static let onboardingHelloTitle = L10n.tr("Localizable", "onboarding_hello_title")
  /// Next
  internal static let onboardingNextBtn = L10n.tr("Localizable", "onboarding_next_btn")
  /// Call the nearest GIS
  internal static let onboardingRedDescription = L10n.tr("Localizable", "onboarding_red_description")
  /// If you are diagnosed with SARS-CoV-2 we will ask you to send the data from your phone. We will use it to alert some of the people who were close to you within last 2 weeks. They may be infected too. They will not learn about your condition.
  internal static let onboardingSharingDescription = L10n.tr("Localizable", "onboarding_sharing_description")
  /// Sharing the data in case of threat
  internal static let onboardingSharingTitle = L10n.tr("Localizable", "onboarding_sharing_title")
  /// The application will presnet one of three statuses. You will learn in could be exposed to infected people within last 2 weeks.
  internal static let onboardingStatusDescription = L10n.tr("Localizable", "onboarding_status_description")
  /// We will keep you informed about a possible threat
  internal static let onboardingStatusTitle = L10n.tr("Localizable", "onboarding_status_title")
  /// You could have been close to infected people
  internal static let onboardingYellowDescription = L10n.tr("Localizable", "onboarding_yellow_description")
  /// xxx xxx xxx
  internal static let registrationPhonePlaceholder = L10n.tr("Localizable", "registration_phone_placeholder")
  /// Send code
  internal static let registrationSendCodeBtn = L10n.tr("Localizable", "registration_send_code_btn")
  /// Enter your phone number so that we can contact you if you were closed to people with SARS-CoV-2.\n\nWe will confirm your phone number by sending you an SMS code.
  internal static let registrationSendDescription = L10n.tr("Localizable", "registration_send_description")
  /// Join the application!
  internal static let registrationSendTitle = L10n.tr("Localizable", "registration_send_title")
  /// By joing the app you accept %@.
  internal static func registrationTermsOfUseBtnRegularPart(_ p1: String) -> String {
    return L10n.tr("Localizable", "registration_terms_of_use_btn_regular_part", p1)
  }
  /// Term of Use
  internal static let registrationTermsOfUseBtnUnderlinedPart = L10n.tr("Localizable", "registration_terms_of_use_btn_underlined_part")
  /// Verify code
  internal static let registrationVerifyBtn = L10n.tr("Localizable", "registration_verify_btn")
  /// xxxxx
  internal static let registrationVerifyCodePlaceholder = L10n.tr("Localizable", "registration_verify_code_placeholder")
  /// Enter the code you received on 
  internal static let registrationVerifyDescription = L10n.tr("Localizable", "registration_verify_description")
  /// Enter your SMS code
  internal static let registrationVerifyTitle = L10n.tr("Localizable", "registration_verify_title")
  /// Your data was sent to GIS.\nWe guarantee nobody will use your personal data while contacting with other people.\n\nIf you have any questions please email as at %@\nor call %@
  internal static func sendDataAlertDescription(_ p1: String, _ p2: String) -> String {
    return L10n.tr("Localizable", "send_data_alert_description", p1, p2)
  }
  /// Thank you!
  internal static let sendDataAlertTitle = L10n.tr("Localizable", "send_data_alert_title")
  /// Share the list of users you encounteres nearby within last 2 weeks. Our experts will alert those who might be infected.\n\nNobody will learn about your condition.
  internal static let sendDataDescription = L10n.tr("Localizable", "send_data_description")
  /// xxx xxx xxx
  internal static let sendDataIdPlaceholder = L10n.tr("Localizable", "send_data_id_placeholder")
  /// Send
  internal static let sendDataSendButton = L10n.tr("Localizable", "send_data_send_button")
  /// Send encounters list
  internal static let sendDataTitle = L10n.tr("Localizable", "send_data_title")
  /// Your ID:
  internal static let sendDataYourId = L10n.tr("Localizable", "send_data_your_id")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
