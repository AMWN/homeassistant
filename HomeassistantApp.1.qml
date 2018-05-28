import QtQuick 1.1
import qb.components 1.0
import qb.base 1.0;

App {
  id: root
  // These are the URL's for the QML resources from which our widgets will be instantiated.
  // By making them a URL type property they will automatically be converted to full paths,
  // preventing problems when passing them around to code that comes from a different path.
  property url trayUrl: "HomeassistantTray.qml";
  property url thumbnailIcon: "./drawables/hass.png"
  property url homeassistantScreenUrl: "HomeassistantScreen.qml"
  property url homeassistantSettingsUrl: "HomeassistantSettings.qml"

  //devices
  property variant deviceList: []
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
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
        // for switching groups, to update all switches states
        oneTimeStateUpdate.start()
      }
    }
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
    var loopDevices = []

    // get devices in group
    for (var key in states) {
      if (states[key].attributes.friendly_name === selectedGroup) {
        deviceList = states[key].attributes.entity_id
        loopDevices.push(states[key])
      };
    }

    //get states
    for (var device in deviceList) {
      for (var state in states) {
        if (states[state].entity_id === deviceList[device]) {
          loopDevices.push(states[state])
        };
      }
    }

    devices = loopDevices
  }

  function readDeviceStatus(selectedGroup) {
    var xmlhttp = new XMLHttpRequest();
    var url = "http://" + settings.host + ":" + settings.port + "/api/states?api_password=" + settings.password
    xmlhttp.onreadystatechange = function () {
      if (xmlhttp.readyState == 4) {
        if (xmlhttp.status == 200) {
          try {

            // new part
            var allStates = JSON.parse(xmlhttp.responseText);
            var devicesInGroups = [];
            var statesOfDevicesInGroups = [];

            //get all devices in groups
            for (var i in allStates) {
              if (groups.indexOf(allStates[i].attributes.friendly_name) !== -1) {
                devicesInGroups.push.apply(devicesInGroups, allStates[i].attributes.entity_id)
              };
            }

            //create minimal states object for al devices in groups
            for (var i in allStates) {
              if (devicesInGroups.indexOf(allStates[i].entity_id) !== -1) {
                statesOfDevicesInGroups.push(allStates[i])
              };
            }
            // console.log('logAWI statesOfDevicesingroups' + statesOfDevicesInGroups)

            //set states to the global states object
            states = statesOfDevicesInGroups;
            // console.log('states ' + states)

            var Tevices = ['test']

            //get all devices in groups
            for (var i in allStates) {
              //loop alle statussen
              var state = allStates[i]
              var group = state.attributes.friendly_name;
              //als state object uit allStates is in groups
              if (groups.indexOf(group) !== -1) {
                //dan voor alle devices in de entity_id array van de groep
                for (var device in state.attributes.entity_id) {
                  var device = state.attributes.entity_id[device];
                  //maak de group aan in de devices object
                  //vul het devices object per groep met de statussen
                  for (var j in allStates) {
                    //loop door alles statussen. State -> DeviceState
                    var deviceState = allStates[j]
                    if (deviceState.entity_id == device) {
                      deviceState['group'] = group
                      Tevices.push(deviceState)
                    }
                  }
                }
              }
            }

            console.log('devices awi' + JSON.stringify(Tevices))
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

    xmlhttp2.open("GET", "file:///HCBv2/qml/apps/Homeassistant/settings.txt");
    xmlhttp2.send();
  }

  Timer {
    id: deviceStateTimer
    interval: 10000
    triggeredOnStart: false
    running: true
    repeat: true
    onTriggered: {
      readDeviceStatus(selectedGroup)
    }
  }

  Timer {
    id: oneTimeStateUpdate
    interval: 5000
    triggeredOnStart: false
    running: false
    repeat: false
    onTriggered: {
      readDeviceStatus(selectedGroup)
    }
  }

}