import 'package:flutter/material.dart';

// Font Families
const String s_font_BonaNova = 'BonaNova';
const String s_font_IBMPlexSans = 'IBMPlexSans';
const String s_font_BerkshireSwash = 'BerkshireSwash';
const String s_font_RighteousRegular = 'Righteous-Regular';
const String s_font_LeagueSpartan = 'LeagueSpartan';

// Font Selections
const String font_appBarText = s_font_LeagueSpartan;
const String font_bigButtonText = s_font_LeagueSpartan;
const String font_smallButtonText = s_font_LeagueSpartan;
const String font_nakedText = s_font_LeagueSpartan;
const String font_sideDrawer = s_font_LeagueSpartan;
const String font_cards = s_font_LeagueSpartan;
const String font_plainText = s_font_IBMPlexSans;

// Colors
const Color white = Colors.white;
const Color black = Colors.black;
const Color royalPurple = Color(0xFF1B1464);
const Color vibrantBlue = Color(0xFF3777FF);
const Color goldenYellow = Color(0xFFF0E100);
const Color yellow = Colors.yellow;
const Color moonstone = Color(0xFF5A9BAB);
const Color teal = Color(0xFF1F7A8C);
const Color gunmetal = Color(0xFF022B3A);
const Color columbiaBlue = Color(0xFFBFDBF7);
const Color lavenderWeb = Color(0xFFE1E5F2);
const Color blueBlack = Color(0xFF00171F);
const Color lightYellow = Color.fromARGB(255, 243, 245, 159);
const Color midYellow = Color.fromARGB(255, 239, 241, 79);
const Color vibrantRed = Color(0xFFf2301b);
const Color deepGreen = Color.fromARGB(255, 18, 148, 23);
const Color deepGray = Color(0xFFAAAEB1);
const Color skyBlue = Color.fromARGB(255, 112, 210, 255);
const Color charcoal = Color.fromARGB(255, 117, 114, 114);
const Color linkedin = Color(0xFF0077B5);
const Color blue = Colors.blue;
const Color lightRed = Color.fromARGB(255, 248, 178, 178);
const Color lightGreen = Color.fromARGB(255, 178, 248, 184);
const Color googleGreen = Color(0xFF1EA362);
const Color googleYellow = Color(0xFFFFE047);
const Color googleBlue = Color(0xFF4A89F3);
const Color googleGrey = Color(0xFFD3D3D3);
const Color googleRed = Color(0xFFDD4B3E);
const Color googleDarkRed = Color(0xFF822F2B);
const Color royalPurpleLight = Color.fromARGB(255, 70, 59, 192);
const Color googleGreenLight = Color.fromARGB(255, 117, 236, 178);
const Color googleYellowLight = Color.fromARGB(255, 255, 241, 170);
const Color googleBlueLight = Color.fromARGB(255, 135, 178, 252);
const Color googleGreyLight = Color.fromARGB(255, 243, 243, 243);
const Color googleRedLight = Color.fromARGB(255, 241, 163, 156);

// Color Selections

// Background fades
Color startScreenBackgroundTop = royalPurpleLight;
Color startScreenBackgroundBottom = googleGrey;
Color createAlertBackgroundTop = royalPurpleLight;
Color createAlertBackgroundBottom = googleGrey;
Color editAlertBackgroundTop = royalPurpleLight;
Color editAlertBackgroundBottom = googleGrey;
Color myAlertsBackgroundTop = royalPurpleLight;
Color myAlertsBackgroundBottom = googleGrey;
Color mapViewBackgroundTop = royalPurpleLight;
Color mapViewBackgroundBottom = googleGrey;

// Top app bar
Color startScreenAppBar = black;
Color pickOnMapAppBar = black;
Color createAlertAppBar = black;
Color myAlertsAppBar = black;
Color mapViewAppBar = black;
Color sideDrawerTitleBackground = royalPurple;

// Circular progress indicator (loading wheel)
Color startScreenLoading = googleBlue;
Color sideDrawerCircularProgressIndicator = googleBlue;
Color mapViewCircularProgressIndicator = googleBlue;
Color pickOnMapCircularProgressIndicator = googleBlue;
Color splashScreenCircularProgressInidcator = googleBlue;
Color myAlertsProgressIndicator = googleBlue;

// Big buttons
Color startScreenCreateAlertButton = googleBlue;
Color startScreenMyAlertsButton = googleGreen;
Color createAlertCancelButton = googleRed;
Color createAlertCreateButton = googleBlue;
Color editAlertUpdateButton = googleGreen;
Color myAlertsBackButton = googleRed;
Color myAlertsMapViewButton = googleYellow;
Color restoreAlertsBackButton = googleRed;

// Small Buttons
Color startScreenLocationDisclosureButton = googleRed;
Color createAlertMyLocationButton = googleBlue;
Color createAlertPickOnMapButton = googleGreen;
Color createAlertRestoreButton = royalPurple;
Color editAlertMarkCompleteButton = googleYellow;
Color editAlertDeleteButton = googleRed;

// Screen specific
Color startScreenTitleText = white;
Color startScreenExplainerText = white;
Color startScreenLogoGlow = white;
Color startScreenLocationToggleTextOn = googleYellow;
Color startScreenLocationToggleTextOff = white;
Color startScreenToggleOn = googleYellow;
Color startScreenToggleOff = googleGrey;
Color startScreenToggleSliderOn = googleGreen;
Color startScreenToggleSliderOff = white;
Color startScreenCreateAlertText = white;
Color startScreenCreateAlertIcon1 = googleYellow;
Color startScreenCreateAlertIcon2 = white;
Color startScreenMyAlertsText = white;
Color startScreenMyAlertsIcon1 = googleYellow;
Color startScreenMyAlertsIcon2 = white;
Color startScreenLocationDisclosureButtonText = white;
Color startScreenLocationDisclosureIcon = googleYellow;
Color startScreenSignatureText = black;
Color startScreenLocationDisclosureAlertText = black;
Color startScreenLocationDisclosureAlertDeclineText = vibrantRed;
Color startScreenLocationDisclosureAlertAccept = deepGreen;
Color startScreenLocationDisclosureAlertAcceptText = white;
Color startScreenLocationOffText = black;
Color startScreenLocationOffButton = deepGray;
Color startScreenLocationDisclosureText = black;

Color createAlertTitleText = white;
Color createAlertRemindMeText = black;
Color createAlertRemindMeFieldFocusedBorder = googleYellow;
Color createAlertRemindMeFieldUnfocusedBorder = columbiaBlue;
Color createAlertRemindMeFieldText = black;
Color createAlertRemindMeFieldHintText = googleGrey;
Color createAlertRemindMeError = vibrantRed;
Color createAlertRemindMeLabel = teal;
Color createAlertRemindMeFieldBackground = white;
Color createAlertLocationText = black;
Color createAlertLocationFieldFocusedBorder = googleYellow;
Color createAlertLocationFieldUnfocusedBorder = columbiaBlue;
Color createAlertLocationFieldText = black;
Color createAlertLocationFieldHintText = googleGrey;
Color createAlertLocationError = vibrantRed;
Color createAlertLocationLabel = teal;
Color createAlertLocationFieldBackground = white;
Color createAlertPreviousLocations = white;
Color createAlertPreviousLocationsText = black;
Color createAlertMyLocationText = white;
Color createAlertMyLocationIcon = white;
Color createAlertPickOnMapText = white;
Color createAlertPickOnMapIcon = white;
Color createAlertAtTriggerText = black;
Color createAlertSliderThumb = googleYellow;
Color createAlertSliderTickMarksOn = midYellow;
Color createAlertSliderTickMarksOff = black;
Color createAlertSliderTrackOn = midYellow;
Color createAlertSliderTrackOff = googleGrey;
Color createAlertMiButtonOn = gunmetal;
Color createAlertMiButtonOff = gunmetal;
Color createAlertMiTextOn = googleYellow;
Color createAlertMiTextOff = googleGrey;
Color createAlertMiBorderOn = midYellow;
Color createAlertMiBorderOff = googleGrey;
Color createAlertKmButtonOn = gunmetal;
Color createAlertKmButtonOff = gunmetal;
Color createAlertKmTextOn = googleYellow;
Color createAlertKmTextOff = googleGrey;
Color createAlertKmBorderOn = midYellow;
Color createAlertKmBorderOff = googleGrey;
Color createAlertUnitsOn = googleBlue;
Color createAlertUnitsOff = googleBlue;
Color createAlertBorderOn = googleYellow;
Color createAlertBorderOff = googleGrey;
Color createAlertTextOn = midYellow;
Color createAlertTextOff = googleGrey;
Color createAlertRestoreText = white;
Color createAlertRestoreIcon = white;
Color createAlertCancelText = white;
Color createAlertCancelIcon = white;
Color createAlertCreateText = white;
Color createAlertCreateIcon = white;

Color editAlertUpdateButtonText = white;
Color editAlertUpdateButtonIcon = white;
Color editAlertMarkCompleteText = black;
Color editAlertDeleteAlertText = white;

Color notificationTextAccept =
    vibrantBlue; // This should work on both normal/dark modes of phone notifications
Color notificationTextDismiss =
    vibrantBlue; // This should work on both normal/dark modes of phone notifications
Color notificationChannel = royalPurple;
Color notificationLed = royalPurple;

Color myAlertsTitleText = white;
Color myAlertsCardBorder = royalPurple;
Color myAlertsCardBackground = white;
Color myAlertsFirstLine = black;
Color myAlertsSecondLine = googleBlue;
Color myAlertsThirdLine = black;
Color myAlertsCardIcon = royalPurple;
Color myAlertsExplainerText = black;
Color myAlertsBackText = white;
Color myAlertsBackIcon = white;
Color myAlertsMapViewText = black;
Color myAlertsMapViewIcon = black;
Color myAlertsNoneYetText = white;

Color restoreAlertsCardIcon = gunmetal;
Color restoreAlertsBackText = white;
Color restoreAlertsBackIcon = white;

Color pickOnMapLocationButton = googleBlue;
Color pickOnMapSelectLocation = googleGreen;
Color pickOnMapZoom = googleGreen;
Color pickOnMapMarkerIcon = googleBlue;
Color pickOnMapTitleColor = white;

Color mapViewTitleText = white;
Color mapViewCluster = royalPurpleLight;
Color mapViewTilesUnloaded = white;
Color mapViewClusterText = white;
Color mapViewAlertMarker = royalPurple;
Color mapViewUserLocation = googleBlue;
Color mapViewTriggerRadius = royalPurpleLight;
Color mapViewMyLocationIcon = white;
Color mapViewResetNorthIcon = googleRed;
Color mapViewZoomInIcon = white;
Color mapViewZoomOutIcon = white;
Color mapViewCardBorder = royalPurple;
Color mapViewCardUserLocationBorder = googleBlue;
Color mapViewCardBackground = white;
Color mapViewCardLineOne = black;
Color mapViewCardLineTwo = googleBlue;
Color mapViewCardLineThree = black;
Color mapViewCardIcon = royalPurple;
Color mapViewCardNotFoundBorder = vibrantRed;
Color mapViewCardNotFoundText = vibrantRed;
Color mapViewCardUserLocationText = black;
Color mapViewNoAlertsText = white;
Color mapViewResetNorthButton = black;
Color mapViewMyLocationButton = googleBlue;
Color mapViewZoomInButton = googleGreen;
Color mapViewZoomOutButton = googleGreen;

Color introSlidesBackgroundSlide1 = googleBlueLight;
Color introSlidesBackgroundSlide2 = googleGreenLight;
Color introSlidesBackgroundSlide3 = googleRedLight;
Color introSlidesBackgroundSlide4 = googleYellowLight;
Color introSlidesTitleTextSlide1 = black;
Color introSlidesTitleTextSlide2 = black;
Color introSlidesTitleTextSlide3 = black;
Color introSlidesTitleTextSlide4 = black;
Color introSlidesTextSlide1 = black;
Color introSlidesTextSlide2 = black;
Color introSlidesTextSlide3 = black;
Color introSlidesTextSlide4 = black;

Color sideDrawerTitleText = white;
Color sideDrawerTitleIcon = white;
Color sideDrawerSectionTitleText = googleBlue;
Color sideDrawerSectionText = black;
Color sideDrawerIcons = black;
Color sideDrawerDisclosureTitle = googleBlue;
Color sideDrawerDisclosureText = black;
Color sideDrawerDisclosureBackground = white;
Color sideDrawerDisclosureCloseButton = googleBlue;
Color sideDrawerDisclosureCloseText = white;
Color sideDrawerDisclosureLinkedinButton = linkedin;
Color sideDrawerDisclosureLinkedinText = white;
Color sideDrawerChangeLanguageButton = googleBlue;
Color sideDrawerChangeLanguageText = black;
Color sideDrawerChangeLanguageUnderline = googleBlue;
Color sideDrawerChangeLanguageDropDown = gunmetal;
Color sideDrawerChangeLanguageRestartText = vibrantRed;
Color sideDrawerChangeLanguageRestartButton = vibrantRed;
Color sideDrawerChangeLanguageRestartButtonText = white;
Color sideDrawerChangeLanguageCloseButton = googleBlue;
Color sideDrawerChangeLanguageCloseButtonText = white;

Color exceptionText = black;
