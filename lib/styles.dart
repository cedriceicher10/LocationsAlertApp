import 'package:flutter/material.dart';

// Font Families
const String s_font_BonaNova = 'BonaNova';
const String s_font_IBMPlexSans = 'IBMPlexSans';
const String s_font_BerkshireSwash = 'BerkshireSwash';
const String s_font_RighteousRegular = 'Righteous-Regular';

// Font Selections
const String font_appBarText = s_font_BonaNova;
const String font_bigButtonText = s_font_BonaNova;
const String font_smallButtonText = s_font_BonaNova;
const String font_plainText = s_font_IBMPlexSans;
const String font_nakedText = s_font_BonaNova;

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

// Color Selections

// Background fades
Color startScreenBackgroundTop = googleBlue;
Color startScreenBackgroundBottom = googleGrey;
Color createAlertBackgroundTop = googleBlue;
Color createAlertBackgroundBottom = googleGrey;
Color editAlertBackgroundTop = googleBlue;
Color editAlertBackgroundBottom = googleGrey;

// Top app bar
Color startScreenAppBar = black;
Color pickOnMapAppBar = black;
Color createAlertAppBar = black;
Color myAlertsAppBar = black;
Color mapViewAppBar = black;

// Circular progress indicator (loading wheel)
Color startScreenLoading = googleBlue;
Color sideDrawerCircularProgressIndicator = googleBlue;
Color mapViewCircularProgressIndicator = googleBlue;
Color pickOnMapCircularProgressIndicator = googleBlue;
Color splashScreenCircularProgressInidcator = googleBlue;

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
Color createAlertMyLocationButton = lightYellow;
Color createAlertPickOnMapButton = lightYellow;
Color createAlertRestoreButton = skyBlue;
Color editAlertMarkCompleteButton = lightRed;
Color editAlertDeleteButton = lightGreen;

// Map Buttons
Color mapViewResetNorthButton = white;
Color mapViewMyLocationButton = vibrantRed;
Color mapViewZoomInButton = moonstone;
Color mapViewZoomOutButton = moonstone;
Color pickOnMapLocationButton = vibrantRed;
Color pickOnMapUserLocation = gunmetal;
Color pickOnMapZoom = gunmetal;

// Screen specific
Color startScreenTitleText = white;
Color startScreenExplainerText = black;
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
Color startScreenLocationDisclosureButtonText = black;
Color startScreenLocationDisclosureIcon = googleYellow;
Color startScreenSignatureText = black;
Color startScreenLocationDisclosureAlertText = black;
Color startScreenLocationDisclosureAlertDeclineText = googleDarkRed;
Color startScreenLocationDisclosureAlertAccept = deepGreen;
Color startScreenLocationDisclosureAlertAcceptText = white;
Color startScreenLocationOffText = black;
Color startScreenLocationOffButton = deepGray;
Color startScreenLocationDisclosureText = black;

Color createAlertTitleText = white;
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
Color createAlertMyLocationText = blueBlack;
Color createAlertMyLocationIcon = blueBlack;
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
Color createAlertRestoreText = blueBlack;
Color createAlertRestoreIcon = blueBlack;
Color createAlertCancelText = white;
Color createAlertCancelIcon = white;
Color createAlertCreateText = white;
Color createAlertCreateIcon = white;

Color editAlertUpdateButtonText = white;
Color editAlertUpdateButtonIcon = white;
Color editAlertMarkCompleteText = gunmetal;
Color editAlertDeleteAlertText = gunmetal;

Color notificationTextAccept = white;
Color notificationTextDismiss = white;
Color notificationChannel = moonstone;
Color notificationLed = white;

Color myAlertsTitleText = white;
Color myAlertsBackgroundTop = goldenYellow;
Color myAlertsBackgroundBottom = vibrantBlue;
Color myAlertsCardBorder = gunmetal;
Color myAlertsCardBackground = white;
Color myAlertsFirstLine = blueBlack;
Color myAlertsSecondLine = teal;
Color myAlertsThirdLine = blueBlack;
Color myAlertsCardIcon = gunmetal;
Color myAlertsExplainerText = gunmetal;
Color myAlertsBackText = white;
Color myAlertsBackIcon = white;

Color myAlertsMapViewText = gunmetal;
Color myAlertsMapViewIcon = gunmetal;
Color myAlertsNoneYetText = gunmetal;
Color myAlertsProgressIndicator = gunmetal;

Color restoreAlertsCardIcon = gunmetal;
Color restoreAlertsBackText = white;
Color restoreAlertsBackIcon = white;

Color mapViewTitleText = white;
Color mapViewCluster = gunmetal;
Color mapViewTilesUnloaded = white;
Color mapViewClusterText = white;
Color mapViewAlertMarker = teal;
Color mapViewUserLocation = vibrantRed;
Color mapViewTriggerRadius = blue;
Color mapViewMyLocationIcon = white;
Color mapViewResetNorthIcon = teal;
Color mapViewZoomInIcon = white;
Color mapViewZoomOutIcon = white;
Color mapViewCardBorder = blueBlack;
Color mapViewCardBackground = white;
Color mapViewCardLineOne = blueBlack;
Color mapViewCardLineTwo = teal;
Color mapViewCardLineThree = blueBlack;
Color mapViewCardIcon = blueBlack;
Color mapViewCardNotFoundBorder = vibrantRed;
Color mapViewCardNotFoundText = vibrantRed;
Color mapViewCardUserLocationText = black;
Color mapViewNoAlertsText = gunmetal;

Color introSlidesBackgroundSlide1 = columbiaBlue;
Color introSlidesBackgroundSlide2 = gunmetal;
Color introSlidesBackgroundSlide3 = columbiaBlue;
Color introSlidesBackgroundSlide4 = gunmetal;
Color introSlidesTitleTextSlide1 = gunmetal;
Color introSlidesTitleTextSlide2 = columbiaBlue;
Color introSlidesTextSlide1 = columbiaBlue;
Color introSlidesTextSlide2 = gunmetal;

Color sideDrawerTitleText = white;
Color sideDrawerTitleIcon = white;
Color sideDrawerTitleBackground = gunmetal;
Color sideDrawerSectionTitleText = gunmetal;
Color sideDrawerSectionText = black;
Color sideDrawerDivider = charcoal;
Color sideDrawerIcons = black;
Color sideDrawerDisclosureTitle = black;
Color sideDrawerDisclosureText = gunmetal;
Color sideDrawerDisclosureIcon = black;
Color sideDrawerDisclosureBackground = white;
Color sideDrawerDisclosureCloseButton = gunmetal;
Color sideDrawerDisclosureCloseText = white;
Color sideDrawerDisclosureLinkedinButton = linkedin;
Color sideDrawerDisclosureLinkedinText = white;
Color sideDrawerChangeLanguageButton = gunmetal;
Color sideDrawerChangeLanguageText = black;
Color sideDrawerChangeLanguageUnderline = gunmetal;
Color sideDrawerChangeLanguageDropDown = gunmetal;
Color sideDrawerChangeLanguageRestartText = vibrantRed;
Color sideDrawerChangeLanguageRestartButton = vibrantRed;
Color sideDrawerChangeLanguageRestartButtonText = white;
Color sideDrawerChangeLanguageCloseButton = gunmetal;
Color sideDrawerChangeLanguageCloseButtonText = white;
Color pickOnMapMarkerIcon = vibrantRed;
Color pickOnMapTitleColor = white;

Color exceptionText = black;
