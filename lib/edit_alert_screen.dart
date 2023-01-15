import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locationalertsapp/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'my_alerts_screen.dart';
import 'formatted_text.dart';
import 'styles.dart';
import 'database_services.dart';
import 'location_services.dart';
import 'pick_on_map_screen.dart';
import 'recent_locations.dart';
import 'go_back_button.dart';
import 'background_theme.dart';
import 'trigger_slider.dart';

enum TriggerUnits { mi, km }

class EditAlertScreen extends StatefulWidget {
  final AlertObject alert;
  const EditAlertScreen({required this.alert, Key? key}) : super(key: key);

  @override
  State<EditAlertScreen> createState() => _EditAlertScreenState();
}

class _EditAlertScreenState extends State<EditAlertScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final LocationServices _locationServices = LocationServices();
  final DatabaseServices _dbServices = DatabaseServices();
  RecentLocations _rl = RecentLocations();
  final TextEditingController _controllerRecentLocations =
      TextEditingController();
  final BackgroundTheme _background =
      BackgroundTheme(Screen.EDIT_ALERTS_SCREEN);
  var _recentLocations = ['Make a few reminders to see their locations here!'];
  Map _recentLocationsMap = new Map();
  String _reminderBody = '';
  String _location = '';
  bool _reverseGeolocateSuccess = false;
  bool _isStart = true;
  bool _locationTextMapPick = false;
  bool _locationTextUserEntered = false;

  double _topPadding = 0;
  double _deleteButtonTopPadding = 0;
  double _buttonHeight = 0;
  double _buttonSpacing = 0;
  double _locationButtonHeight = 0;
  double _locationButtonWidth = 0;
  double _textWidth = 0;
  double _iconGapWidth = 0;
  double _titleTextFontSize = 0;
  double _formFontSize = 0;
  double _locationButtonTextFontSize = 0;
  double _updateButtonFontSize = 0;
  double _atMyLocationIconSize = 0;
  double _pickOnMapIconSize = 0;
  double _dropDownIconSize = 0;
  double _updateButtonIconSize = 0;
  double _cancelIconSize = 0;
  double _smallButtonCornerRadius = 0;
  double _largeButtonCornerRadius = 0;
  double _dropDownFontScale = 0;
  double _switchReminderTypeIconSize = 0;
  double _switchReminderFontsize = 0;
  double _guideTextFontSize = 0;
  double _deleteAlertIconSize = 0;
  double _fabPadding = 0;
  double _bottomPadding = 0;
  double _formErrorFontSize = 0;
  double _markCompleteIconSize = 0;
  double _triggerUnitsFontSize = 0;

  List<String> unitStrings = ['mi', 'km'];
  List<double> triggerRangeMiList = [0.25, 0.5, 1.0, 5.0, 10.0];
  List<double> triggerRangeKmList = [0.5, 0.75, 1.5, 8.0, 15.0];
  double selectedMiTrigger = 0.25;
  double selectedKmTrigger = 0.5;
  TriggerUnits? _character = TriggerUnits.mi;
  bool loadedTriggerDistanceUnits = false;

  PickOnMapLocation __pickOnMapLocation = PickOnMapLocation('', 0.0, 0.0);
  bool _usingRecentLocation = false;

  String atLocationText = '';
  String atLocationTextOpposite = '';
  bool _isGeneric = true;

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
      if (widget.alert.triggerUnits == unitStrings[0]) {
        selectedMiTrigger =
            getTriggerDistanceMiIndex(widget.alert.triggerDistance) *
                ((triggerRangeMiList[triggerRangeMiList.length - 1] -
                        triggerRangeMiList[0]) /
                    (triggerRangeMiList.length - 1));
        _character = TriggerUnits.mi;
      } else {
        selectedKmTrigger =
            getTriggerDistanceKmIndex(widget.alert.triggerDistance) *
                ((triggerRangeKmList[triggerRangeKmList.length - 1] -
                        triggerRangeKmList[0]) /
                    (triggerRangeKmList.length - 1));
        _character = TriggerUnits.km;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    generateLayout();
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
          title: 'Edit Alert Screen',
          home: Scaffold(
            appBar: AppBar(
              title: editAlertTitle('Edit Alert'),
              backgroundColor: const Color(s_aquarium),
              centerTitle: true,
            ),
            resizeToAvoidBottomInset: false,
            body: editAlertScreenBody(),
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

  Widget buttonsFAB() {
    return Container(
        height: _fabPadding,
        width: _textWidth,
        child: Column(children: [
          cancelButtonFAB(_textWidth, _buttonHeight),
          SizedBox(height: _buttonSpacing),
          updateButtonFAB(_textWidth, _buttonHeight),
        ]));
  }

  Widget editAlertScreenBody() {
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
                          titleText('Remind me to...'),
                          SizedBox(width: _textWidth, child: reminderEntry()),
                        ],
                      ),
                      SizedBox(height: _buttonSpacing),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleText('At the location...'),
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
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            markCompleteButton(
                                _locationButtonWidth, _locationButtonHeight),
                            SizedBox(width: _buttonSpacing),
                            deleteButton(
                                _locationButtonWidth, _locationButtonHeight),
                          ]),
                      SizedBox(height: _buttonSpacing),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleText('At the trigger distance...'),
                            Container(
                                width: _textWidth, child: triggerRangeSlider()),
                          ]),
                      Container(
                          width: _textWidth,
                          child: unitsRadioButtons(_textWidth))
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
        if (_character == TriggerUnits.km) {
          selectedKmTrigger = val;
        } else {
          selectedMiTrigger = val;
        }
      }),
      activeColor: Color(s_darkSalmon),
      inactiveColor: Color(s_aquariumLighter),
      linearStep: true,
      steps: determineSteps(),
      unit: determineUnits(),
    );
  }

  double determineMinValue() {
    if (_character == TriggerUnits.km) {
      return triggerRangeKmList[0];
    } else {
      return triggerRangeMiList[0];
    }
  }

  double determineMaxValue() {
    if (_character == TriggerUnits.km) {
      return triggerRangeKmList[triggerRangeKmList.length - 1];
    } else {
      return triggerRangeMiList[triggerRangeMiList.length - 1];
    }
  }

  double determineTrigger() {
    if (_character == TriggerUnits.km) {
      return selectedKmTrigger;
    } else {
      return selectedMiTrigger;
    }
  }

  List<double> determineSteps() {
    if (_character == TriggerUnits.km) {
      return triggerRangeKmList;
    } else {
      return triggerRangeMiList;
    }
  }

  String determineUnits() {
    if (_character == TriggerUnits.km) {
      return unitStrings[1];
    } else {
      return unitStrings[0];
    }
  }

  Widget unitsRadioButtons(double width) {
    int outsideFlex = 2;
    int insideFlex = 4;
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(flex: outsideFlex, child: Container()),
        Expanded(
            flex: insideFlex,
            child: ListTileTheme(
                horizontalTitleGap: 0,
                child: ListTile(
                  title: triggerUnitsText(unitStrings[0]),
                  leading: Radio<TriggerUnits>(
                    value: TriggerUnits.mi,
                    groupValue: _character,
                    onChanged: (TriggerUnits? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ))),
        Expanded(
            flex: insideFlex,
            child: ListTileTheme(
                horizontalTitleGap: 0,
                child: ListTile(
                  title: triggerUnitsText(unitStrings[1]),
                  leading: Radio<TriggerUnits>(
                    value: TriggerUnits.km,
                    groupValue: _character,
                    onChanged: (TriggerUnits? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                ))),
        Expanded(flex: outsideFlex, child: Container()),
      ],
    ));
  }

  Widget reminderEntry() {
    return TextFormField(
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        initialValue: widget.alert.reminder,
        style: TextStyle(color: Colors.black, fontSize: _formFontSize),
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelStyle: TextStyle(
                color: Color(s_aquarium), fontWeight: FontWeight.bold),
            hintText: widget.alert.reminder,
            hintStyle: TextStyle(color: Colors.grey, fontSize: _formFontSize),
            errorStyle: TextStyle(
                color: Color(s_declineRed),
                fontWeight: FontWeight.bold,
                fontSize: _formErrorFontSize),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color(s_raisinBlack), width: 2.0)),
            focusedBorder: const OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color(s_darkSalmon), width: 2.0))),
        onSaved: (value) {
          _reminderBody = value!;
        },
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter a reminder';
          } else if (value.length > 200) {
            return 'Please shorten the reminder to less than 200 characters';
          } else {
            return null;
          }
        });
  }

  Widget locationEntry() {
    if (_isGeneric) {
      if (widget.alert.isSpecific) {
        _location = 'Grocery Store';
      }
      return Center(
          child: DropdownButton<String>(
              icon: const Icon(Icons.add_location_alt_outlined),
              iconEnabledColor: const Color(s_aquarium),
              items: generalLocations(),
              value: _location,
              onChanged: (value) {
                setState(() {
                  _location = value!;
                });
              }));
    } else {
      if (_isStart) {
        _controllerRecentLocations.selection = TextSelection.fromPosition(
            TextPosition(
                offset: _controllerRecentLocations
                    .text.length)); // Puts cursor at end of field
      }
      String hintTextForGeneric = '';
      TextStyle hintColor =
          TextStyle(color: Color(s_disabledGray), fontSize: _formFontSize);
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
        hintTextForGeneric = widget.alert.location;
      } else {
        _controllerRecentLocations.text = '';
        hintTextForGeneric = '42 Wallaby Way, Sydney, NSW';
        hintColor = const TextStyle(color: Colors.grey);
      }
      return Row(children: <Widget>[
        Flexible(
            child: TextFormField(
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                controller: _controllerRecentLocations,
                style: TextStyle(color: Colors.black, fontSize: _formFontSize),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: const TextStyle(
                        color: Color(s_aquarium), fontWeight: FontWeight.bold),
                    hintText: hintTextForGeneric,
                    hintStyle: hintColor,
                    errorStyle: TextStyle(
                        color: Color(s_declineRed),
                        fontWeight: FontWeight.bold,
                        fontSize: _formErrorFontSize),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(s_raisinBlack), width: 2.0)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Color(s_darkSalmon), width: 2.0))),
                onSaved: (value) async {
                  _location = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a location';
                  } else if (value.length > 200) {
                    return 'Please shorten the reminder to less than 200 characters';
                  } else if (!_reverseGeolocateSuccess) {
                    return 'Could not locate the location you entered. \nPlease be more specific.';
                  } else {
                    return null;
                  }
                })),
        PopupMenuButton<String>(
          icon: Icon(Icons.arrow_drop_down,
              size: _dropDownIconSize, color: Colors.white),
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
  }

  Widget switchReminderTypeButton(double buttonWidth, double buttonHeight) {
    return ElevatedButton(
        onPressed: () async {
          setState(() {
            if (_isGeneric) {
              _isGeneric = false;
            } else {
              _isGeneric = true;
            }
          });
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(s_blackBlue),
            fixedSize: Size(buttonWidth, buttonHeight)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            Icons.switch_access_shortcut,
            color: Colors.white,
            size: _switchReminderTypeIconSize,
          ),
          SizedBox(
            width: _iconGapWidth,
          ),
          FormattedText(
            text: 'Switch to $atLocationTextOpposite location',
            size: _switchReminderFontsize,
            color: Colors.white,
            font: s_font_IBMPlexSans,
          )
        ]));
  }

  void populateLocationFromPickOnMap(PickOnMapLocation pickOnMapLocation) {
    __pickOnMapLocation.location = pickOnMapLocation.location;
    __pickOnMapLocation.lat = pickOnMapLocation.lat;
    __pickOnMapLocation.lon = pickOnMapLocation.lon;
    _locationTextMapPick = true;
    _locationTextUserEntered = false;
  }

  Widget atMyLocationButton(double buttonWidth, double buttonHeight) {
    return Visibility(
        visible: !_isGeneric,
        child: ElevatedButton(
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
              bool? masterLocationToggle =
                  prefs.getBool('masterLocationToggle');
              // Show location disclosure on the start screen
              if ((showLocationDisclosure != null) &&
                  (showLocationDisclosure)) {
                Navigator.pop(context, true);
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
                  _location = placemarks[0].street! +
                      ', ' +
                      placemarks[0].locality! +
                      ', ' +
                      placemarks[0].administrativeArea! +
                      ', ' +
                      placemarks[0].postalCode!;
                  _controllerRecentLocations.text = _location;
                  _locationTextUserEntered = true;
                  _locationTextMapPick = false;
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: s_myLocationColor,
                fixedSize: Size(buttonWidth, buttonHeight),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_smallButtonCornerRadius))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.my_location_sharp,
                color: Color(s_darkSalmon),
                size: _atMyLocationIconSize,
              ),
              SizedBox(
                width: _iconGapWidth,
              ),
              smallButtonText('My Location')
            ])));
  }

  Widget pickOnMapButton(double buttonWidth, double buttonHeight) {
    return Visibility(
        visible: !_isGeneric,
        child: ElevatedButton(
            onPressed: () {
              // Remove keyboard
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              // Pick on map screen
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
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: s_pickOnMapColor,
                fixedSize: Size(buttonWidth, buttonHeight),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(_smallButtonCornerRadius))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.add_location_alt_outlined,
                color: Color(s_darkSalmon),
                size: _pickOnMapIconSize,
              ),
              SizedBox(
                width: _iconGapWidth,
              ),
              smallButtonText('Pick on Map')
            ])));
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
          smallButtonText('Mark Done')
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
          smallButtonText('Delete Alert')
        ]));
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
                text: 'Update Alert',
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
    if (_character == TriggerUnits.km) {
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
    if (_character == TriggerUnits.km) {
      return unitStrings[1];
    } else {
      return unitStrings[0];
    }
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
              Navigator.pop(context, false);
            },
            backgroundColor: Color(s_darkSalmon),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(_largeButtonCornerRadius))),
            label: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: _cancelIconSize,
              ),
              // Expanded(
              //     child: SizedBox(
              //   width: 1,
              // )),
              SizedBox(
                width: 8,
              ),
              cancelButtonText('Cancel', _updateButtonFontSize)
            ])));
  }

  Widget cancelButtonText(String text, double fontSize) {
    return FormattedText(
      text: text,
      size: fontSize,
      color: Colors.white,
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  bool checkRecentLocationMap(String location) {
    if (_recentLocationsMap[location] == null) {
      return false;
    }
    return true;
  }

  Widget smallButtonText(String text) {
    return FormattedText(
      text: text,
      size: _locationButtonTextFontSize,
      color: Color(s_darkSalmon),
      font: s_font_BonaNova,
      weight: FontWeight.bold,
    );
  }

  Widget editAlertTitle(String title) {
    return FormattedText(
      text: title,
      size: _titleTextFontSize,
      color: Colors.white,
      font: s_font_BerkshireSwash,
    );
  }

  Widget titleText(String title) {
    return FormattedText(
        text: title,
        size: _guideTextFontSize,
        color: Colors.white,
        font: s_font_BonaNova,
        weight: FontWeight.bold);
  }

  Widget triggerUnitsText(String text) {
    return FormattedText(
        text: text,
        size: _triggerUnitsFontSize,
        color: Color(s_darkSalmon),
        font: s_font_IBMPlexSans,
        weight: FontWeight.bold,
        align: TextAlign.center);
  }

  void generateLayout() {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _screenHeight = MediaQuery.of(context).size.height;

    // Original ratios based on a Google Pixel 5 (392 x 781) screen
    // and a 56 height appBar

    // Height
    _topPadding = (40 / 781) * _screenHeight;
    _buttonHeight = (60 / 781) * _screenHeight;
    _deleteButtonTopPadding = (125 / 781) * _screenHeight;
    _locationButtonHeight = (30 / 781) * _screenHeight;
    _bottomPadding = (20 / 781) * _screenHeight;
    _fabPadding = (_buttonHeight * 2.75) + _buttonSpacing;

    // Width
    _textWidth = (325 / 392) * _screenWidth;
    _buttonSpacing = (10 / 392) * _screenWidth;
    _locationButtonWidth = ((_textWidth - _buttonSpacing) / 2);
    _iconGapWidth = 8;

    // Font
    _titleTextFontSize = (32 / 56) * AppBar().preferredSize.height;
    _guideTextFontSize = (26 / 781) * _screenHeight;
    _formFontSize = (16 / 60) * _buttonHeight;
    _locationButtonTextFontSize = (16 / 30) * _locationButtonHeight;
    _updateButtonFontSize = (20 / 60) * _buttonHeight;
    _switchReminderFontsize = (12 / 30) * _locationButtonHeight;
    _formErrorFontSize = (12 / 60) * _buttonHeight;
    _triggerUnitsFontSize = (16 / 60) * _buttonHeight;

    // Icons
    _atMyLocationIconSize = (16 / 30) * _locationButtonHeight;
    _pickOnMapIconSize = (16 / 30) * _locationButtonHeight;
    _dropDownIconSize = 40;
    _updateButtonIconSize = (32 / 60) * _buttonHeight;
    _deleteAlertIconSize = (20 / 60) * _buttonHeight;
    _markCompleteIconSize = (18 / 60) * _buttonHeight;
    _cancelIconSize = (24 / 60) * _buttonHeight;
    _switchReminderTypeIconSize = (16 / _locationButtonHeight) * _screenHeight;

    // Styling
    _smallButtonCornerRadius = (20 / 30) * _locationButtonHeight;
    _largeButtonCornerRadius = (10 / 60) * _buttonHeight;
    _dropDownFontScale = (_screenHeight / 781) * 1.0;
  }
}
