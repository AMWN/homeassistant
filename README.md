# Home Assistant (for Toon)
This a Home Assistant App for Toon. It is a basic app to turn devices on and off.
Right now only devicetypes are allowed that are able to turn on and off. 

The buttons with state will be generated based on the groups you set in the settings.

This design of this app is inspired by [Dashtics for toon](https://github.com/Dashticz/dashticz_toon).

## Screenshots
![alt tag](https://i.imgur.com/To5vfIx.png)

## Manual Installation
* Download zip from this repository, unzip contents to a folder named 'homeassistant' and upload this folder to: '/HCBv2/qml/apps/'
* Add 'homeassistant' to the array of 'appsToLoad' in '/HCBv2/qml/qb/base/Globals.qml'
* Run command `killall qt-gui` to restart the gui and load home assistant.
* Click on the new home assistant icon in the notification-bar
* Click on 'Settings' to enter ip, port, password, and groups (comma delimited).
* After this, the buttons should be showed, based on the devices in the group(s).

## Home Assistant Configuration
* Give Home Assitant a password
* Add CORS
* Create custom groups specifically for Toon (optional)

### Example config:

```
http:
  api_password: PASSWORD
  cors_allowed_origins:
    - http://192.168.0.116
```



