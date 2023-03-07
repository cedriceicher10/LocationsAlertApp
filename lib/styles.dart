import 'dart:ui';
import 'package:flutter/material.dart';

// Font Families
const String s_font_MajorMonoDisplay = 'MajorMonoDisplay';
const String s_font_BonaNova = 'BonaNova';
const String s_font_AmaticSC = 'AmaticSC';
const String s_font_RedOctober = "RedOctober";
const String s_font_SpecialElite = "SpecialElite";
const String s_font_IBMPlexSans = "IBMPlexSans";
const String s_font_NovaMono = "NovaMono";
const String s_font_BerkshireSwash = "BerkshireSwash";
const String s_font_Pompiere = "Pompiere";

// Font Sizes
const double s_fontSizeExtraLarge = 44;
const double s_fontSizeLarge = 32;
const double s_fontSizeMedLarge = 26;
const double s_fontSizeMedium = 20;
const double s_fontSizeSmall = 16;
const double s_fontSizeExtraSmall = 12;

// Colors Used in App
const int s_aquarium = 0xFF1F7A8C; // 0xFF328396 (orig), 0xFF1F7A8C(second)
const int s_aquariumLighter = 0xFF5A9BAB; // 0xFF5A9BAB
const int s_darkSalmon = 0xFF022B3A; // 0xFFDD9787 (orig)
const int s_declineRed = 0xFFf2301b; // 0xFFf2301b
const int s_raisinBlack = 0xFFBFDBF7; // 0xFF2A2D34
const int s_beauBlue = 0xFFBFDBF7;
const int s_lavenderWeb = 0xFFE1E5F2;
const int s_iconGreen = 0xFF2fa561;
const int s_linkedin = 0xFF0077B5;
const Color s_deleteButtonColor = Color.fromARGB(255, 248, 178, 178);
const Color s_markCompleteButtonColor = Color.fromARGB(255, 178, 248, 184);

// Colors
const Color white = Colors.white;
const Color black = Colors.black;
const Color mooonstone = Color(0xFF5A9BAB); // aquariumLighter
const Color teal = Color(0xFF1F7A8C); // aquarium
const Color gunmetal = Color(0xFF022B3A); // darkSalmon
const Color columbiaBlue = Color(0xFFBFDBF7); // beauBlue
const Color lavenderWeb = Color(0xFFE1E5F2);
const Color blueBlack = Color(0xFF00171F);
const Color lightYellow = Color.fromARGB(255, 243, 245, 159);
const Color midYellow = Color.fromARGB(255, 239, 241, 79);
const Color vibrantRed = Color(0xFFf2301b);
const Color deepGreen = Color.fromARGB(255, 18, 148, 23);
const Color deepGray = Color(0xFFAAAEB1);
const Color skyBlue = Color.fromARGB(255, 112, 210, 255);

const Color s_pickOnMapColor = lightYellow;
const Color s_myLocationColor = lightYellow;

Color startScreenAppBar = gunmetal;
Color startScreenLoading = gunmetal;
Color startScreenTitleText = white;
Color startScreenBackgroundTop = teal;
Color startScreenBackgroundBottom = lavenderWeb;
Color startScreenExplainerText = white;
Color startScreenLogoGlow = white;
Color startScreenLocationToggleText = white;
Color startScreenToggleOn = midYellow;
Color startScreenToggleOff = columbiaBlue;
Color startScreenToggleSliderOn = lightYellow;
Color startScreenToggleSliderOff = white;
Color startScreenCreateAlertButton = teal;
Color startScreenCreateAlertText = white;
Color startScreenCreateAlertIcon1 = white;
Color startScreenCreateAlertIcon2 = white;
Color startScreenMyAlertsButton = gunmetal;
Color startScreenMyAlertsText = white;
Color startScreenMyAlertsIcon1 = white;
Color startScreenMyAlertsIcon2 = white;
Color startScreenLocationDisclosureButton = blueBlack;
Color startScreenLocationDisclosureButtonText = white;
Color startScreenLocationDisclosureIcon = lightYellow;
Color startScreenSignatureText = black;
Color startScreenLocationDisclosureAlertText = black;
Color startScreenLocationDisclosureAlertDeclineText = vibrantRed;
Color startScreenLocationDisclosureAlertAccept = deepGreen;
Color startScreenLocationDisclosureAlertAcceptText = white;
Color startScreenLocationOffText = black;
Color startScreenLocationOffButton = deepGray;
Color startScreenLocationDisclosureText = black;

// Others
const int s_jungleGreen = 0xFF2EAD65;
const int s_grayGreen = 0xFF89A894;
const int s_darkGray = 0xFF333333;
const int s_jungleGreen_faded = 0xEEbac261;
const int s_mustard = 0xFFFFD700;
const int s_fadedDeclineRed = 0xCCbe5b50;
const int s_periwinkleBlue = 0xFF4aa8ff;
const int s_periwinkleBlueTransparent = 0xCC4aa8ff;
const int s_lightPurple = 0xFF8565c4;
const int s_cadmiumOrange = 0xFFFF6500;
const int s_lightOrange = 0xFFFF8c69;
const int s_disabledGray = 0xFFAAAEB1;
const int s_seaFoam = 0xFF0A8C79;
const int s_forrestGreen = 0xFF012B09;
const int s_goldenrod = 0xC59849;
const int s_blackBlue = 0xFF00171F;

Color createAlertAppBar = gunmetal;
Color createAlertTitleText = white;
Color createAlertBackgroundTop = teal;
Color createAlertBackgroundBottom = lavenderWeb;
Color createAlertRemindMeText = white;
Color createAlertRemindMeFieldFocusedBorder = gunmetal;
Color createAlertRemindMeFieldUnfocusedBorder = columbiaBlue;
Color createAlertRemindMeFieldText = black;
Color createAlertRemindMeFieldHintText = deepGray;
Color createAlertRemindMeError = vibrantRed;
Color createAlertRemindMeLabel = teal;
Color createAlertRemindMeFieldBackground = white;
Color createAlertLocationText = white;
Color createAlertLocationFieldFocusedBorder = gunmetal;
Color createAlertLocationFieldUnfocusedBorder = columbiaBlue;
Color createAlertLocationFieldText = black;
Color createAlertLocationFieldHintText = deepGray;
Color createAlertLocationError = vibrantRed;
Color createAlertLocationLabel = teal;
Color createAlertLocationFieldBackground = white;
Color createAlertPreviousLocations = white;
Color createAlertPreviousLocationsText = black;
Color createAlertMyLocationButton = lightYellow;
Color createAlertMyLocationText = blueBlack;
Color createAlertMyLocationIcon = blueBlack;
Color createAlertPickOnMapButton = lightYellow;
Color createAlertPickOnMapText = blueBlack;
Color createAlertPickOnMapIcon = blueBlack;
Color createAlertAtTriggerText = white;
Color createAlertSliderThumb = lightYellow;
Color createAlertSliderTickMarksOn = gunmetal;
Color createAlertSliderTickMarksOff = white;
Color createAlertMiButtonOn = gunmetal;
Color createAlertMiButtonOff = gunmetal;
Color createAlertMiTextOn = midYellow;
Color createAlertMiTextOff = teal;
Color createAlertMiBorderOn = midYellow;
Color createAlertMiBorderOff = teal;
Color createAlertKmButtonOn = gunmetal;
Color createAlertKmButtonOff = gunmetal;
Color createAlertKmTextOn = midYellow;
Color createAlertKmTextOff = teal;
Color createAlertKmBorderOn = midYellow;
Color createAlertKmBorderOff = teal;
Color createAlertUnitsOn = gunmetal;
Color createAlertUnitsOff = gunmetal;
Color createAlertBorderOn = midYellow;
Color createAlertBorderOff = teal;
Color createAlertTextOn = midYellow;
Color createAlertTextOff = teal;
Color createAlertRestoreButton = skyBlue;
Color createAlertRestoreText = blueBlack;
Color createAlertRestoreIcon = blueBlack;
Color createAlertCancelButton = gunmetal;
Color createAlertCancelText = white;
Color createAlertCancelIcon = white;
Color createAlertCreateButton = teal;
Color createAlertCreateText = white;
Color createAlertCreateIcon = white;

// editAlertAppBar
// editAlertTitleText
// editAlertBackgroundTop
// editAlertBackgroundBottom
// editAlertRemindMeText
// editAlertRemindMeFieldBorder
// editAlertRemindMeFieldText
// editAlertRemindMeFieldHintText
// editAlertRemindMeError
// editAlertLocationText
// editAlertLocationFieldBorder
// editAlertLocationFieldText
// editAlertLocationFieldHintText
// editAlertLocationError
// editAlertPreviousLocations
// editAlertPreviousLocationsText
// editAlertMyLocationButton
// editAlertMyLocationText
// editAlertMyLocationIcon
// editAlertPickOnMapButton
// editAlertPickOnMapText
// editAlertPickOnMapIcon
// editAlertAtTriggerText
// editAlertSliderSelection
// editAlertSliderBackground
// editAlertSliderTickMarksOn
// editAlertSliderTickMarksOff
// editAlertSliderText
// editAlertMiButtonOn
// editAlertMiButtonOff
// editAlertMiTextOn
// editAlertMiTextOff
// editAlertMiBorderOn
// editAlertMiBorderOff
// editAlertKmButtonOn
// editAlertKmButtonOff
// editAlertKmTextOn
// editAlertKmTextOff
// editAlertKmBorderOn
// editAlertKmBorderOff
// editAlertRestoreButton
// editAlertRestoreText
// editAlertRestoreIcon
// editAlertCancelButton
// editAlertCancelText
// editAlertCancelIcon
// editAlertUpdateButton
// editAlertUpdateText
// editAlertUpdateIcon
// editAlertMarkDoneButton
// editAlertMarkDoneText
// editAlertMarkDoneIcon
// editAlertDeleteButton
// editAlertDeleteText
// editAlertDeleteIcon

// myAlertsAppBar
// myAlertsTitleText
// myAlertsBackgroundTop
// myAlertsBackgroundBottom
// myAlertsCardBorder
// myAlertsCardBackground
// myAlertsFirstLine
// myAlertsSecondLine
// myAlertsThirdLine
// myAlertsCardIcon
// myAlertsExplainerText
// myAlertsBackButton
// myAlertsBackText
// myAlertsBackIcon
// myAlertsMapViewButton
// myAlertsMapViewText
// myAlertsMapViewIcon
// myAlertsNoneYetText

// restoreAlertsTitleText
// restoreAlertsBackgroundTop
// restoreAlertsBackgroundBottom
// restoreAlertsCardBorder
// restoreAlertsCardBackground
// restoreAlertsFirstLine
// restoreAlertsSecondLine
// restoreAlertsThirdLine
// restoreAlertsCardIcon
// restoreAlertsExplainerText
// restoreAlertsBackButton
// restoreAlertsBackText
// restoreAlertsBackIcon
// restoreAlertsNoneYetText

// mapViewAppBar
// mapViewTitleText
// mapViewBackgroundTop
// mapViewBackgroundBottom
// mapViewCluster
// mapViewClusterText
// mapViewAlertMarker
// mapViewUserLocation
// mapViewResetNorthButton
// mapViewResetNorthIcon
// mapViewZoomInButton
// mapViewZoomInIcon
// mapViewZoomOutButton
// mapViewZoomOutIcon
// mapViewCardBorder
// mapViewCardBackground
// mapViewCardLineOne
// mapViewCardLineTwo
// mapViewCardLineThree
// mapViewCardIcon
// mapViewCardNotFoundBorder
// mapViewCardNotFoundText
// mapViewCardNotFoundIcon
// mapViewListViewButton
// mapViewListViewText
// mapViewListViewIcon

Color introSlidesBackgroundSlide1 = columbiaBlue;
Color introSlidesBackgroundSlide2 = gunmetal;
Color introSlidesBackgroundSlide3 = columbiaBlue;
Color introSlidesBackgroundSlide4 = gunmetal;
Color introSlidesTitleTextSlide1 = gunmetal;
Color introSlidesTitleTextSlide2 = columbiaBlue;
Color introSlidesTextSlide1 = columbiaBlue;
Color introSlidesTextSlide2 = gunmetal;

// sideDrawerTopBar
// sideDrawerTitleText
// sideDrawerTitleIcon
// sideDrawerBackground
// sideDrawerSectionTitleText
// sideDrawerSectionText
// sideDrawerIcons
// sideDrawerDisclosureTitle
// sideDrawerDisclosureText
// sideDrawerDisclosureCloseButton
// sideDrawerDisclosureCloseText
// sideDrawerDisclosureLinkedinButton
// sideDrawerDisclosureLinkedinText
// sideDrawerChangeLanguageButton
// sideDrawerChangeLanguageText
// sideDrawerChangeLanguageDropDown
// sideDrawerChangeLanguageRestartText
// sideDrawerChagneLanguageRestartButton
// sideDrawerChagneLanguageRestartButtonText

// Color Swatch
const MaterialColor s_whiteSwatch = const MaterialColor(
  0xFFFFFFFF,
  const <int, Color>{
    50: const Color(0xFFFFFFFF),
    100: const Color(0xFFFFFFFF),
    200: const Color(0xFFFFFFFF),
    300: const Color(0xFFFFFFFF),
    400: const Color(0xFFFFFFFF),
    500: const Color(0xFFFFFFFF),
    600: const Color(0xFFFFFFFF),
    700: const Color(0xFFFFFFFF),
    800: const Color(0xFFFFFFFF),
    900: const Color(0xFFFFFFFF),
  },
);
const MaterialColor s_blackSwatch = const MaterialColor(
  0xFF000000,
  const <int, Color>{
    50: const Color(0xFF000000),
    100: const Color(0xFF000000),
    200: const Color(0xFF000000),
    300: const Color(0xFF000000),
    400: const Color(0xFF000000),
    500: const Color(0xFF000000),
    600: const Color(0xFF000000),
    700: const Color(0xFF000000),
    800: const Color(0xFF000000),
    900: const Color(0xFF000000),
  },
);
