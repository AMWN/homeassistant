import QtQuick 1.1
import qb.components 1.0
import qb.base 1.0;

App {
  id: root
  // These are the URL's for the QML resources from which our widgets will be instantiated.
  // By making them a URL type property they will automatically be converted to full paths,
  // preventing problems when passing them around to code that comes from a different path.
  property url trayUrl: "HomeAssistantTray.qml";
  property url thumbnailIcon: "./drawables/hass.png"
  property url homeassistantScreenUrl: "HomeAssistantScreen.qml"
  property url homeassistantSettingsUrl: "HomeAssistantSettings.qml"

  //devices
  property variant devices: []
  property variant groups: []
  property variant states: []
  property string selectedGroup: ''

  //setting
  property variant settings: {
    "host": "",
    "port": "",
    "password": "",
    "groups": ""
  }


  function init() {
    registry.registerWidget("systrayIcon", trayUrl, this, "homeassistantTray");
    registry.registerWidget("screen", homeassistantScreenUrl, this);
    registry.registerWidget("screen", homeassistantSettingsUrl, this);
    // readSettings()
  }

  Component.onCompleted: {
    readSettings();
  }

  function simpleSynchronous(device, command) {
    var url = "http://" + settings.host + ":" + settings.port + "/api/services/homeassistant/" + command + "?api_password=" + settings.password
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.open("POST", url, true);
    xmlhttp.send(JSON.stringify({
      'entity_id': device
    }));
  }

  // home assistant turnon and turnoff service
  function postHomeAssistant(device, state) {
    if (state === "on") {
      simpleSynchronous(device, 'turn_on')
    } else {
      simpleSynchronous(device, 'turn_off')
    }
  }

  // switch selected Group
  function switchSelectedGroup(value) {
    selectedGroup = value
    devicesOfSelectedGroup()
  }

  function devicesOfSelectedGroup() {
    var localDevices = []
    for (var device in states) {
      var device = states[device]
      if (device.group == selectedGroup) localDevices.push(device)
    }
    devices = localDevices
  }

  function readDeviceStatus() {
    // when in DimState no refresh of devices states
      var xmlhttp = new XMLHttpRequest();
      var url = "http://" + settings.host + ":" + settings.port + "/api/states?api_password=" + settings.password
      xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4) {
          if (xmlhttp.status == 200) {
            try {
              var allStates = JSON.parse(xmlhttp.responseText);
              var devicesInGroupsStates = [];

              // get all devices in groups
              loop1:
                for (var i in allStates) {
                  // loop trough all states
                  var state = allStates[i]
                  var group = state.attributes.friendly_name;
                  // if group found in states object
                  if (groups.indexOf(group) !== -1) {
                    // then for all devices of the group
                    loop2: for (var device in state.attributes.entity_id) {
                      var device = state.attributes.entity_id[device];
                      loop3:
                        for (var j in allStates) {
                          // find state and push it to the array with states
                          var deviceState = allStates[j]
                          if (deviceState.entity_id == device) {
                            deviceState['group'] = group
                            devicesInGroupsStates.push(deviceState)
                            break loop3;
                          }
                        }
                    }
                  }
                }

              states = devicesInGroupsStates
              devicesOfSelectedGroup()

            } catch (err) {
              console.log(err)
            }
          }
        }
      }
      xmlhttp.open("GET", url, true);
      xmlhttp.send();
  }

  function readSettings() {
    var xmlhttp2 = new XMLHttpRequest()

    xmlhttp2.onreadystatechange = function () {
      if (xmlhttp2.readyState == XMLHttpRequest.DONE) {
        if (xmlhttp2.responseText.length > 0) {
          var temp = JSON.parse(xmlhttp2.responseText);
          groups = (temp.groups ? temp.groups.split(',') : null)
          selectedGroup = (groups ? groups[0] : null)
          settings = temp;
        }
      }
    }

    xmlhttp2.open("GET", "file:///HCBv2/qml/apps/homeAssistant/settings.txt");
    xmlhttp2.send();
  }

  Timer {
    id: deviceStateTimer
    interval: 10000
    triggeredOnStart: false
    running: true
    repeat: true
    onTriggered: {
      readDeviceStatus()
    }
  }

  Timer {
    id: oneTimeStateUpdate
    interval: 2000
    triggeredOnStart: false
    running: false
    repeat: false
    onTriggered: {
      readDeviceStatus()
    }
  }

}