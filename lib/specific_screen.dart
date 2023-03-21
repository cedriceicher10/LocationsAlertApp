import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationalertsapp/recent_locations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'database_services.dart';
import 'location_services.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'start_screen.dart';
import 'pick_on_map_screen.dart';
import 'go_back_button.dart';
import 'background_theme.dart';
import 'trigger_slider.dart';
import 'language_services.dart';
import 'my_alerts_screen.dart';

enum ScreenType {
  CREATE,
  EDIT,
}

class SpecificScreen extends StatefulWidget {
  final ScreenType screen;
  final AlertObject alert;
  SpecificScreen({required this.screen, required this.alert, Key? key})
      : super(key: key);

  @override
  State<SpecificScreen> createState() => _SpecificScreenState();
}

class _SpecificScreenState extends State<SpecificScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final LocationServices _locationServices = LocationServices();
  final DatabaseServices _dbServices = DatabaseServices();
  final BackgroundTheme _background =
      BackgroundTheme(Screen.SPECIFIC_ALERT_SCREEN);
  final LanguageServices _languageServices = LanguageServices();
  RecentLocations _rl = RecentLocations();
  String _reminderBody = '';
  String _specificLocation = '';
  bool _reverseGeolocateSuccess = false;
  bool _usingRecentLocation = false;
  bool _locationTextMapPick = false;

  bool _isMiles = true;

  Color unitsMiBorderColor = createAlertMiBorderOn;
  Color unitsMiTextColor = createAlertMiTextOn;
  Color unitsMiButtonColor = createAlertMiButtonOn;

  Color unitsKmBorderColor = createAlertKmBorderOff;
  Color unitsKmTextColor = createAlertKmTextOff;
  Color unitsKmButtonColor = createAlertKmButtonOff;

  Color unitsBorderColorActivated = createAlertBorderOn;
  Color unitsBorderColorInactive = createAlertBorderOff;
  Color unitsTextColorActivated = createAlertTextOn;
  Color unitsTextColorInactive = createAlertTextOff;
  Color unitsButtonColorActivated = createAlertUnitsOn;
  Color unitsButtonColorInactive = createAlertUnitsOff;

  double _topPadding = 0;
  double _submitButtonTopPadding = 0;
  double _buttonHeight = 0;
  double _buttonSpacing = 0;
  double _locationButtonHeight = 0;
  double _locationButtonWidth = 0;
  double _textWidth = 0;
  double _iconGapWidth = 0;
  double _titleTextFontSize = 0;
  double _guideTextFontSize = 0;
  double _formFontSize = 0;
  double _locationButtonTextFontSize = 0;
  double _submitButtonFontSize = 0;
  double _atMyLocationIconSize = 0;
  double _pickOnMapIconSize = 0;
  double _dropDownIconSize = 0;
  double _submitButtonIconSize = 0;
  double _cancelIconSize = 0;
  double _smallButtonCornerRadius = 0;
  double _largeButtonCornerRadius = 0;
  double _dropDownFontScale = 0;
  double _fabPadding = 0;
  double _bottomPadding = 0;
  double _formErrorFontSize = 0;
  double _triggerUnitsFontSize = 0;
  double _radioButtonWidth = 0;
  double _radioButtonsSpacerWidth = 0;
  double _restoreAlertsButtonWidth = 0;
  double _aboveRestoreAlertsSpacing = 0;
  double _updateButtonIconSize = 0;
  double _updateButtonFontSize = 0;
  double _markCompleteIconSize = 0;
  double _deleteAlertIconSize = 0;

  List<String> unitStrings = ['mi', 'km'];
  List<double> triggerRangeMiList = [0.25, 0.5, 1.0, 5.0, 10.0];
  List<double> triggerRangeKmList = [0.5, 0.75, 1.5, 8.0, 15.0];
  double selectedMiTrigger = 0.25;
  double selectedKmTrigger = 0.50;

  PickOnMapLocation __pickOnMapLocation = PickOnMapLocation('', 0.0, 0.0);

  final TextEditingController _controllerRecentLocations =
      TextEditingController();
  var _recentLocations = ['Make a few reminders to see their locations here!'];
  Map _recentLocationsMap = new Map();

  String atLocationText = '';
  String atLocationTextOpposite = '';
  String _location = '';
  bool _isGeneric = true;
  bool _locationTextUserEntered = false;
  bool _isStart = true;

  @override
  void initState() {
    if (widget.alert.isSpecific) {
      _isGeneric = false;
    }
    _location = widget.alert.location;
    if (_isGeneric) {
      atLocationText = 'generic';
      atLocationTextOpposite = 'specific';
    } else {
      atLocationText = 'specific';
      atLocationTextOpposite = 'generic';
      // Assign trigger distance/units slider and radio buttons
      // triggerDistance is equal to triggerRange*List[*]
      // We must conver this to ((max - min) / num_divisions) * index
      if (widget.alert.triggerUnits == unitStrings[1]) {
        selectedKmTrigger =
            (getTriggerDistanceKmIndex(widget.alert.triggerDistance) *
                    ((triggerRangeKmList[triggerRangeKmList.length - 1] -
                            triggerRangeKmList[0]) /
                        (triggerRangeKmList.length - 1))) +
                triggerRangeKmList[0];
        _isMiles = false;
        unitsMiBorderColor = unitsBorderColorInactive;
        unitsMiButtonColor = unitsButtonColorInactive;
        unitsMiTextColor = unitsTextColorInactive;
        unitsKmBorderColor = unitsBorderColorActivated;
        unitsKmButtonColor = unitsButtonColorActivated;
        unitsKmTextColor = unitsTextColorActivated;
      } else {
        selectedMiTrigger =
            (getTriggerDistanceMiIndex(widget.alert.triggerDistance) *
                    ((triggerRangeMiList[triggerRangeMiList.length - 1] -
                            triggerRangeMiList[0]) /
                        (triggerRangeMiList.length - 1))) +
                triggerRangeMiList[0];
        _isMiles = true;
        unitsMiBorderColor = unitsBorderColorActivated;
        unitsMiButtonColor = unitsButtonColorActivated;
        unitsMiTextColor = unitsTextColorActivated;
        unitsKmBorderColor = unitsBorderColorInactive;
        unitsKmButtonColor = unitsButtonColorInactive;
        unitsKmTextColor = unitsTextColorInactive;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    generateLayout();
    loadRecentLocations();
    // Wrapping the MaterialApp allows the user to tap anywhere on the screen
    // to remove the keyboard focus
    // See: https://flutterigniter.com/dismiss-keyboard-form-lose-focus/
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          title: 'Specific Screen',
          home: Scaffold(
            appBar: AppBar(
              title: specificScreenTitle(),
              backgroundColor: createAlertAppBar,
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: specificScreenBody(),
            floatingActionButton: buttonsFAB(),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          ),
        ));
  }

  void loadRecentLocations() {
    _rl.retrieveRecentLocations();
    _recentLocations = _rl.recentLocations;
    _recentLocationsMap = _rl.recentLocationsMap;
  }

  Widget buttonsFAB() {
    return Container(
        height: _fabPadding,
        width: _textWidth,
        child: Column(children: [
          cancelButtonFAB(_textWidth, _buttonHeight),
          SizedBox(height: _buttonSpacing),
          (this.widget.screen == ScreenType.CREATE)
              ? submitButtonFAB(_textWidth, _buttonHeight)
              : updateButtonFAB(_textWidth, _buttonHeight),
        ]));
  }

  Widget specificScreenBody() {
    return SafeArea(
        child: Container(
            decoration: _background.getBackground(),
            child: Form(
                key: formKey,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: _topPadding),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          titleText(_languageServices.createAlertRemindMe),
                          SizedBox(width: _textWidth, child: reminderEntry()),
                        ],
                      ),
                      SizedBox(height: _buttonSpacing),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleText(_languageServices.createAlertAtLocation),
                            SizedBox(width: _textWidth, child: locationEntry()),
                          ]),
                      SizedBox(height: _buttonSpacing),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            atMyLocationButton(
                                _locationButtonWidth, _locationButtonHeight),
                            SizedBox(width: _buttonSpacing),
                            pickOnMapButton(
                                _locationButtonWidth, _locationButtonHeight),
                          ]),
                      (this.widget.screen == ScreenType.EDIT)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  markCompleteButton(_locationButtonWidth,
                                      _locationButtonHeight),
                                  SizedBox(width: _buttonSpacing),
                                  deleteButton(_locationButtonWidth,
                                      _locationButtonHeight),
                                ])
                          : Container(),
                      SizedBox(height: _buttonSpacing),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleText(_languageServices.createAlertAtTrigger),
                            Container(
                                width: _textWidth, child: triggerRangeSlider()),
                          ]),
                      Container(
                          width: _textWidth,
                          child: unitsRadioButtons(
                              _radioButtonWidth, _locationButtonHeight)),
                      SizedBox(height: _aboveRestoreAlertsSpacing),
                      (this.widget.screen == ScreenType.CREATE)
                          ? restoreAlertsButton(
                              _restoreAlertsButtonWidth, _locationButtonHeight)
                          : Container(),
                    ]))));
  }

  Widget triggerRangeSlider() {
    return TriggerSlider(
      minValue: determineMinValue(),
      maxValue: determineMaxValue(),
      value: determineTrigger(),
      majorTick: 3, // # major ticks
      minorTick: 1, // # minor ticks between major ticks
      labelValuePrecision: 0,
      onChanged: (val) => setState(() {
        if (!_isMiles) {
          selectedKmTrigger = val;
        } else {
          selectedMiTrigger = val;
        }
      }),
      activeColor: createAlertSliderTickMarksOn,
      inactiveColor: createAlertSliderTickMarksOff,
      linearStep: true,
      steps: determineSteps(),
      unit: determineUnits(),
    );
  }

  double determineMinValue() {
    if (!_isMiles) {
      return triggerRangeKmList[0];
    } else {
      return triggerRangeMiList[0];
    }
  }

  double determineMaxValue() {
    if (!_isMiles) {
      return triggerRangeKmList[triggerRangeKmList.length - 1];
    } else {
      return triggerRangeMiList[triggerRangeMiList.length - 1];
    }
  }

  double determineTrigger() {
    if (!_isMiles) {
      return selectedKmTrigger;
    } else {
      return selectedMiTrigger;
    }
  }

  List<double> determineSteps() {
    if (!_isMiles) {
      return triggerRangeKmList;
    } else {
      return triggerRangeMiList;
    }
  }

  String determineUnits() {
    if (!_isMiles) {
      return _languageServices.unitsKm;
    } else {
      return _languageServices.unitsMi;
    }
  }

  Widget unitsRadioButtons(double buttonWidth, double buttonHeight) {
    return Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            side: BorderSide(width: 2, color: unitsMiBorderColor),
            backgroundColor: unitsMiButtonColor,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: triggerUnitsText(_languageServices.unitsMi, unitsMiTextColor),
        onPressed: () async {
          setState(() {
            swapColors();
          });
        },
      ),
      SizedBox(width: _radioButtonsSpacerWidth),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            side: BorderSide(width: 2, color: unitsKmBorderColor),
            backgroundColor: unitsKmButtonColor,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: triggerUnitsText(_languageServices.unitsKm, unitsKmTextColor),
        onPressed: () async {
          setState(() {
            swapColors();
          });
        },
      )
    ]));
  }

  void swapColors() {
    // Which activated tracker
    if (_isMiles) {
      _isMiles = false;
    } else {
      _isMiles = true;
    }
    // Miles button
    if (unitsMiBorderColor == unitsBorderColorActivated) {
      unitsMiBorderColor = unitsBorderColorInactive;
    } else {
      unitsMiBorderColor = unitsBorderColorActivated;
    }
    if (unitsMiTextColor == unitsTextColorActivated) {
      unitsMiTextColor = unitsTextColorInactive;
    } else {
      unitsMiTextColor = unitsTextColorActivated;
    }
    if (unitsMiButtonColor == unitsButtonColorActivated) {
      unitsMiButtonColor = unitsButtonColorInactive;
    } else {
      unitsMiButtonColor = unitsButtonColorActivated;
    }
    // Km button
    if (unitsKmBorderColor == unitsBorderColorActivated) {
      unitsKmBorderColor = unitsBorderColorInactive;
    } else {
      unitsKmBorderColor = unitsBorderColorActivated;
    }
    if (unitsKmTextColor == unitsTextColorActivated) {
      unitsKmTextColor = unitsTextColorInactive;
    } else {
      unitsKmTextColor = unitsTextColorActivated;
    }
    if (unitsKmButtonColor == unitsButtonColorActivated) {
      unitsKmButtonColor = unitsButtonColorInactive;
    } else {
      unitsKmButtonColor = unitsButtonColorActivated;
    }
  }

  Widget reminderEntry() {
    return TextFormField(
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        initialValue: (this.widget.screen == ScreenType.EDIT)
            ? widget.alert.reminder
            : '',
        style: TextStyle(
            color: createAlertRemindMeFieldText, fontSize: _formFontSize),
        decoration: InputDecoration(
            filled: true,
            fillColor: createAlertRemindMeFieldBackground,
            labelStyle: TextStyle(
                color: createAlertRemindMeLabel, fontWeight: FontWeight.bold),
            hintText: _languageServices.createAlertReminderHint,
            hintStyle: TextStyle(
                color: createAlertRemindMeFieldHintText,
                fontSize: _formFontSize),
            errorStyle: TextStyle(
                color: createAlertRemindMeError,
                fontWeight: FontWeight.bold,
                fontSize: _formErrorFontSize),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: createAlertRemindMeFieldUnfocusedBorder,
                    width: 2.0)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: createAlertRemindMeFieldFocusedBorder, width: 2.0))),
        onSaved: (value) {
          _reminderBody = value!;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return _languageServices.createAlertReminderFieldEmpty;
          } else if (value.length > 200) {
            return _languageServices.createAlertReminderFieldEmpty;
          } else {
            return null;
          }
        });
  }

  Widget locationEntry() {
    if (_locationTextMapPick) {
      _controllerRecentLocations.text = __pickOnMapLocation.location;
      _controllerRecentLocations.selection = TextSelection.fromPosition(
          TextPosition(offset: _controllerRecentLocations.text.length));
      _locationTextMapPick = false;
    } // Puts cursor at end of field
    if (_isStart) {
      _controllerRecentLocations.selection = TextSelection.fromPosition(
          TextPosition(
              offset: _controllerRecentLocations
                  .text.length)); // Puts cursor at end of field
    }
    if (!_isGeneric) {
      if (_locationTextUserEntered) {
        // User entered text
      } else if (_locationTextMapPick) {
        _controllerRecentLocations.text = __pickOnMapLocation.location;
        _locationTextMapPick = false;
      } else {
        if (_isStart) {
          _controllerRecentLocations.text = widget.alert.location;
          _isStart = false;
        }
      }
    } else {
      _controllerRecentLocations.text = '';
    }
    return Row(children: <Widget>[
      Flexible(
        child: TextFormField(
            controller: _controllerRecentLocations,
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
            style: TextStyle(
                color: createAlertLocationFieldText, fontSize: _formFontSize),
            decoration: InputDecoration(
                filled: true,
                fillColor: createAlertLocationFieldBackground,
                labelStyle: TextStyle(
                    color: createAlertLocationLabel,
                    fontWeight: FontWeight.bold),
                hintText: _languageServices.createAlertLocationHint,
                hintStyle: TextStyle(
                    color: createAlertLocationFieldHintText,
                    fontSize: _formFontSize),
                errorStyle: TextStyle(
                    color: createAlertLocationError,
                    fontWeight: FontWeight.bold,
                    fontSize: _formErrorFontSize),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: createAlertLocationFieldUnfocusedBorder,
                        width: 2.0)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: createAlertLocationFieldFocusedBorder,
                        width: 2.0))),
            onSaved: (value) async {
              _specificLocation = value!;
            },
            validator: (value) {
              if (value!.isEmpty) {
                return _languageServices.createAlertLocationEmpty;
              } else if (value.length > 200) {
                return _languageServices.createAlertLocationTooLong;
              } else if (!_reverseGeolocateSuccess) {
                return _languageServices.createAlertLocationNotFound;
              } else {
                return null;
              }
            }),
      ),
      PopupMenuButton<String>(
        icon: Icon(Icons.arrow_drop_down,
            size: _dropDownIconSize, color: createAlertPreviousLocations),
        onSelected: (String value) {
          _controllerRecentLocations.text = value;
          _locationTextUserEntered = true;
          _locationTextMapPick = false;
        },
        itemBuilder: (BuildContext context) {
          return _recentLocations.map<PopupMenuItem<String>>((String value) {
            return PopupMenuItem(
                child: Text(value, textScaleFactor: _dropDownFontScale),
                value: value,
                padding: EdgeInsets.all(5));
          }).toList();
        },
      )
    ]);
  }

  Widget submitButtonFAB(double buttonWidth, double buttonHeight) {
    return Container(
        width: buttonWidth,
        height: buttonHeight,
        child: FloatingActionButton.extended(
            heroTag: "submit",
            onPressed: () async {
              formKey.currentState?.save();
              _usingRecentLocation = checkRecentLocationMap(_specificLocation);
              String locationToUse;
              if (_usingRecentLocation) {
                locationToUse = _recentLocationsMap[_specificLocation];
              } else {
                locationToUse = _specificLocation;
              }
              // Ensure the place can be found and lat/lon added
              _reverseGeolocateSuccess = await _locationServices
                  .reverseGeolocateCheck(context, locationToUse);
              // Ensure user has not exceeded quota of 150 reminders
              bool lessThanLimit = await _dbServices.checkRemindersNum(context);
              if (formKey.currentState!.validate() && lessThanLimit) {
                formKey.currentState?.save();
                // Save for previously chosen locations
                _rl.add(locationToUse);
                // Put in Firestore cloud database
                _dbServices.addToRemindersDatabase(
                    context,
                    _reminderBody,
                    true,
                    false,
                    locationToUse,
                    _locationServices.alertLat,
                    _locationServices.alertLon,
                    determineSubmitTriggerDistance(),
                    determineSubmitTriggerUnits());
                _dbServices.updateUsersReminderCreated(context);
                // Remove keyboard
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                Navigator.pop(context);
              }
            },
            backgroundColor: createAlertCreateButton,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(_largeButtonCornerRadius))),
            label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.add,
                color: createAlertCreateIcon,
                size: _submitButtonIconSize,
              ),
              SizedBox(
                width: _iconGapWidth,
              ),
              FormattedText(
                text: _languageServices.createAlertCreateAlertButton,
                size: _submitButtonFontSize,
                color: createAlertCreateText,
                font: s_font_BonaNova,
                weight: FontWeight.bold,
              )
            ])));
  }

  Widget updateButtonFAB(double buttonWidth, double buttonHeight) {
    return Container(
        width: buttonWidth,
        height: buttonHeight,
        child: FloatingActionButton.extended(
            heroTag: "submit",
            onPressed: () async {
              formKey.currentState?.save();
              if (!_isGeneric) {
                _usingRecentLocation = checkRecentLocationMap(_location);
                String locationToUse;
                if (_usingRecentLocation) {
                  locationToUse = _recentLocationsMap[_location];
                } else {
                  locationToUse = _location;
                }
                _reverseGeolocateSuccess = await _locationServices
                    .reverseGeolocateCheck(context, locationToUse);
                // Ensure user has not exceeded quota of 150 reminders
                bool lessThanLimit =
                    await _dbServices.checkRemindersNum(context);
                if (formKey.currentState!.validate() && lessThanLimit) {
                  formKey.currentState?.save();
                  // Update in db
                  _dbServices.updateRemindersSpecificAlert(
                    context,
                    widget.alert.id,
                    _reminderBody,
                    locationToUse,
                    _locationServices.alertLat,
                    _locationServices.alertLon,
                    !_isGeneric,
                    determineSubmitTriggerDistance(),
                    determineSubmitTriggerUnits(),
                  );
                  _dbServices.updateUsersReminderUpdated(context);
                  // Save for previously chosen locations
                  _rl.add(locationToUse);
                  // Remove keyboard
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  Navigator.pop(context, false);
                }
              } else {
                // Ensure user has not exceeded quota of 150 reminders
                bool lessThanLimit =
                    await _dbServices.checkRemindersNum(context);
                if (formKey.currentState!.validate() && lessThanLimit) {
                  formKey.currentState?.save();
                  _dbServices.updateRemindersGenericAlert(context,
                      widget.alert.id, _reminderBody, _location, !_isGeneric);
                  _dbServices.updateUsersReminderUpdated(context);
                  // Remove keyboard
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  Navigator.pop(context, false);
                }
              }
            },
            backgroundColor: Color(s_aquarium),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(_largeButtonCornerRadius))),
            label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.update,
                color: Colors.white,
                size: _updateButtonIconSize,
              ),
              SizedBox(
                width: _iconGapWidth,
              ),
              FormattedText(
                text: _languageServices.editAlertUpdateAlertButton,
                size: _updateButtonFontSize,
                color: Colors.white,
                font: s_font_BonaNova,
                weight: FontWeight.bold,
              )
            ])));
  }

  double determineSubmitTriggerDistance() {
    // selected*Trigger is equal to ((max - min) / num_divisions) * index
    // We must conver this to triggerRange*List[index]
    if (!_isMiles) {
      double val = triggerRangeKmList[((selectedKmTrigger -
                  triggerRangeKmList[0]) ~/ // This is equivalent to .toInt()
              ((triggerRangeKmList[triggerRangeKmList.length - 1] -
                      triggerRangeKmList[0]) /
                  ((triggerRangeKmList.length - 1))))]
          .toDouble();
      return val;
    } else {
      double val = triggerRangeMiList[((selectedMiTrigger -
                  triggerRangeMiList[0]) ~/ // This is equivalent to .toInt()
              ((triggerRangeMiList[triggerRangeMiList.length - 1] -
                      triggerRangeMiList[0]) /
                  ((triggerRangeMiList.length - 1))))]
          .toDouble();
      return val;
    }
  }

  String determineSubmitTriggerUnits() {
    if (!_isMiles) {
      return unitStrings[1];
    } else {
      return unitStrings[0];
    }
  }

  void populateLocationFromPickOnMap(PickOnMapLocation pickOnMapLocation) {
    __pickOnMapLocation.location = pickOnMapLocation.location;
    __pickOnMapLocation.lat = pickOnMapLocation.lat;
    __pickOnMapLocation.lon = pickOnMapLocation.lon;
    _locationTextMapPick = true;
    _locationTextUserEntered = false;
  }

  bool checkRecentLocationMap(String location) {
    if (_recentLocationsMap[location] == null) {
      return false;
    }
    return true;
  }

  Widget atMyLocationButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // Location look up
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool? showLocationDisclosure =
              prefs.getBool('showLocationDisclosure');
          bool? masterLocationToggle = prefs.getBool('masterLocationToggle');
          // Show location disclosure on the start screen
          if ((showLocationDisclosure != null) && (showLocationDisclosure)) {
            if (this.widget.screen == ScreenType.CREATE) {
              Navigator.pop(context);
            } else {
              Navigator.pop(context, true);
            }
          } else {
            // Set master location toggle if not set yet
            if (masterLocationToggle == null) {
              prefs.setBool('masterLocationToggle', false);
            } else {
              await _locationServices.getLocation();
            }
            if (_locationServices.permitted) {
              prefs.setBool('masterLocationToggle', true);
              var placemarks = await placemarkFromCoordinates(
                  _locationServices.userLat, _locationServices.userLon);
              _specificLocation = placemarks[0].street! +
                  ', ' +
                  placemarks[0].locality! +
                  ', ' +
                  placemarks[0].administrativeArea! +
                  ', ' +
                  placemarks[0].postalCode!;
              _controllerRecentLocations.text = _specificLocation;
              _locationTextUserEntered = true;
              _locationTextMapPick = false;
            }
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: createAlertMyLocationButton,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.my_location_sharp,
            color: createAlertMyLocationIcon,
            size: _atMyLocationIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          smallButtonText(_languageServices.createAlertMyLocationButton)
        ]));
  }

  Widget pickOnMapButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // Pick on map screen
          if (this.widget.screen == ScreenType.CREATE) {
            Navigator.of(context)
                .push(createRoute(PickOnMapScreen(), 'from_right'))
                .then((value) => setState(() {
                      populateLocationFromPickOnMap(value);
                    }));
          } else {
            Navigator.of(context)
                .push(createRoute(
                    // Do I want this to be the location that's always in the location field?
                    PickOnMapScreen(
                        startLatitude: widget.alert.latitude,
                        startLongitude: widget.alert.longitude),
                    'from_right'))
                .then((value) => setState(() {
                      populateLocationFromPickOnMap(value);
                    }));
          }
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: createAlertPickOnMapButton,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.add_location_alt_outlined,
            color: createAlertPickOnMapIcon,
            size: _pickOnMapIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          smallButtonText(_languageServices.createAlertPickOnMapButton)
        ]));
  }

  Widget markCompleteButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          _dbServices.completeRemindersAlertWithContext(
              context, widget.alert.id);
          _dbServices.updateUsersReminderComplete();
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          Navigator.pop(context, false);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: s_markCompleteButtonColor,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.check_circle_rounded,
            color: Color(s_darkSalmon),
            size: _markCompleteIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          smallButtonText(_languageServices.editAlertMarkDoneButton)
        ]));
  }

  Widget deleteButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          _dbServices.deleteRemindersAlert(context, widget.alert.id);
          _dbServices.updateUsersReminderDeleted(context);
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          Navigator.pop(context, false);
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: s_deleteButtonColor,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.delete_forever,
            color: Color(s_darkSalmon),
            size: _deleteAlertIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          smallButtonText(_languageServices.editAlertDeleteButton)
        ]));
  }

  Widget restoreAlertsButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () {
          // Remove keyboard
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
          // Pick on map screen
          // Navigator.of(context)
          //     .push(createRoute(PickOnMapScreen(), 'from_right'))
          //     .then((value) => setState(() {
          //           populateLocationFromPickOnMap(value);
          //         }));
          Navigator.of(context).push(createRoute(
              MyAlertsScreen(alertList: AlertList.COMPLETED), 'from_right'));
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: createAlertRestoreButton,
            fixedSize: Size(buttonWidth, buttonHeight),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_smallButtonCornerRadius))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.restore,
            color: createAlertRestoreIcon,
            size: _pickOnMapIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          smallButtonText(_languageServices.restoreAlertsButton)
        ]));
  }

  Widget cancelButtonFAB(double buttonWidth, double buttonHeight) {
    return Container(
        width: buttonWidth,
        height: buttonHeight,
        child: FloatingActionButton.extended(
            heroTag: "cancel",
            onPressed: () {
              // Remove keyboard
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (this.widget.screen == ScreenType.CREATE) {
                Navigator.pop(context);
              } else {
                Navigator.pop(context, false);
              }
              ;
            },
            backgroundColor: createAlertCancelButton,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(_largeButtonCornerRadius))),
            label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                color: createAlertCancelIcon,
                size: _cancelIconSize,
              ),
              // Expanded(
              //     child: SizedBox(
              //   width: 1,
              // )),
              SizedBox(
                width: 8,
              ),
              cancelButtonText(_submitButtonFontSize)
            ])));
  }

  Widget cancelButtonText(double fontSize) {
    return FormattedText(
      text: _languageServices.createAlertCancelButton,
      size: fontSize,
      color: createAlertCancelText,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget triggerUnitsText(String text, Color color) {
    return FormattedText(
        text: text,
        size: _triggerUnitsFontSize,
        color: color,
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold,
        align: TextAlign.center);
  }

  Widget smallButtonText(String text) {
    return FormattedText(
      text: text,
      size: _locationButtonTextFontSize,
      color: createAlertMyLocationText,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget specificScreenTitle() {
    String title = _languageServices.createAlertTitle;
    if (this.widget.screen == ScreenType.EDIT) {
      title = _languageServices.editAlertTitle;
    }
    return FormattedText(
      text: title,
      size: _titleTextFontSize,
      color: createAlertTitleText,
      font: s_font_BerkshireSwash,
    );
  }

  Widget titleText(String title) {
    return FormattedText(
        text: title,
        size: _guideTextFontSize,
        color: createAlertRemindMeText,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  int getTriggerDistanceKmIndex(double triggerDistance) {
    for (int index = 0; index < triggerRangeKmList.length; ++index) {
      if (triggerDistance == triggerRangeKmList[index]) {
        return index;
      }
    }
    return 0;
  }

  int getTriggerDistanceMiIndex(double triggerDistance) {
    for (int index = 0; index < triggerRangeMiList.length; ++index) {
      if (triggerDistance == triggerRangeMiList[index]) {
        return index;
      }
    }
    return 0;
  }

  void generateLayout() {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;
    double langScale = _languageServices.getLanguageScale();

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _topPadding = (20 / 781) * _screenHeight;
    _buttonHeight = (60 / 781) * _screenHeight;
    _submitButtonTopPadding = (175 / 781) * _screenHeight;
    _locationButtonHeight = (30 / 781) * _screenHeight;
    _bottomPadding = (20 / 781) * _screenHeight;
    _fabPadding = (_buttonHeight * 2.25) + _buttonSpacing;
    _aboveRestoreAlertsSpacing = (10 / 781) * _screenHeight;

    // Width
    _textWidth = (325 / 392) * _screenWidth;
    _buttonSpacing = (10 / 392) * _screenWidth;
    _locationButtonWidth = ((_textWidth - _buttonSpacing) / 2);
    _iconGapWidth = 8;
    _radioButtonWidth = (60 / 392) * _screenWidth;
    _radioButtonsSpacerWidth = (40 / 392) * _screenWidth;
    _restoreAlertsButtonWidth = _locationButtonWidth * 1.5;

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height * langScale;
    _guideTextFontSize = (26 / 781) * _screenHeight * langScale;
    _formFontSize = (16 / 60) * _buttonHeight * langScale;
    _locationButtonTextFontSize = (16 / 30) * _locationButtonHeight * langScale;
    _submitButtonFontSize = (20 / 60) * _buttonHeight * langScale;
    _formErrorFontSize = (12 / 60) * _buttonHeight * langScale;
    _triggerUnitsFontSize = (16 / 60) * _buttonHeight * langScale;
    _updateButtonFontSize = (20 / 60) * _buttonHeight * langScale;

    // Icons
    _atMyLocationIconSize = (16 / 30) * _locationButtonHeight;
    _pickOnMapIconSize = (16 / 30) * _locationButtonHeight;
    _dropDownIconSize = 40;
    _submitButtonIconSize = (32 / 60) * _buttonHeight;
    _cancelIconSize = (24 / 60) * _buttonHeight;
    _updateButtonIconSize = (32 / 60) * _buttonHeight;
    _markCompleteIconSize = (18 / 60) * _buttonHeight;
    _deleteAlertIconSize = (20 / 60) * _buttonHeight;

    // Styling
    _smallButtonCornerRadius = (20 / 30) * _locationButtonHeight;
    _largeButtonCornerRadius = (10 / 60) * _buttonHeight;
    _dropDownFontScale = (_screenHeight / 781) * 1.0;
  }
}
