import QtQuick 1.1
import qb.components 1.0
import BxtClient 1.0

Screen {

	id: homeassistantSettingsScreen
	screenTitleIconUrl: "drawables/hass.png"
	screenTitle: qsTr("Home Assistant - Instellingen")

	hasBackButton: false
	hasHomeButton: false
	hasCancelButton: true

	onShown: {
		addCustomTopRightButton("Opslaan");
		if (homeassistantHostLabel.inputText == "") homeassistantHostLabel.inputText = app.settings.host;
		if (homeassistantPortLabel.inputText == "") homeassistantPortLabel.inputText = app.settings.port;
		if (homeassistantPasswordLabel.inputText == "") homeassistantPasswordLabel.inputText = app.settings.password;
		if (homeassistantGroupsLabel.inputText == "") homeassistantGroupsLabel.inputText = app.settings.groups;
	}

	onCustomButtonClicked: {
		var temp = app.settings; // updating app property variant is only possible in its whole, not by elements only, so we need this
		temp.host = homeassistantHostLabel.inputText;
		temp.port = homeassistantPortLabel.inputText;
		temp.password = homeassistantPasswordLabel.inputText;
		temp.groups = homeassistantGroupsLabel.inputText
		app.settings = temp;

		var saveFile = new XMLHttpRequest();
		saveFile.onreadystatechange = function () {
			if (saveFile.readyState == 4) {
					app.readSettings()
					console.log('read settings again')
					stage.openFullscreen(app.homeassistantScreenUrl);
			}
		}
		saveFile.open("PUT", "file:///HCBv2/qml/apps/homeAssistant/settings.txt");
		saveFile.send(JSON.stringify(app.settings));
	}

	function hostnameValidate(text, isFinal) {
		if (isFinal) {
			if ((text.match(/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/)) || (text.match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/))) {
				return null;
			} else {
				return {
					content: "Onjuist hostnaam of IP adres"
				};
			}
			return null;
		}
		return null;
	}

	function numValidate(text, isFinal) {
		if (isFinal) {
			if (text.match(/^[0-9]*$/)) {
				return null;
			} else {
				return {
					content: "Poortnummer onjuist"
				};
			}
			return null;
		}
		return null;
	}

	function updateHomeAssistantHostLabel(text) {
		if (text) {
			homeassistantHostLabel.inputText = text;
		}
	}

	function updateHomeAssistantPortLabel(text) {
		if (text) {
			if (text.match(/^[0-9]*$/)) {
				homeassistantPortLabel.inputText = text;
			}
		}
	}

	function updateHomeAssistantPasswordLabel(text) {
		if (text) homeassistantPasswordLabel.inputText = text;
	}

	function updateHomeAssistantGroupsLabel(text) {
		if (text) homeassistantGroupsLabel.inputText = text;
	}


	// homeassistant
	Text {
		id: homeassistantText
		font.pixelSize: 16
		font.family: qfont.semiBold.name
		text: "Home Assistant"
		anchors {
			top: parent.top
			topMargin: 20
			left: parent.left
			leftMargin: 16
		}
	}

	EditTextLabel {
		id: homeassistantHostLabel
		width: 350
		height: 35
		leftText: "Host"
		leftTextAvailableWidth: 200

		anchors {
			left: homeassistantText.left
			top: homeassistantText.bottom
			topMargin: 10
		}

		onClicked: {
			qkeyboard.open("Hostnaam", homeassistantHostLabel.inputText, updateHomeAssistantHostLabel, hostnameValidate);
		}
	}

	EditTextLabel {
		id: homeassistantPortLabel
		width: 350
		height: 35
		leftText: "Port"
		leftTextAvailableWidth: 200

		anchors {
			left: homeassistantHostLabel.left
			top: homeassistantHostLabel.bottom
			topMargin: 10
		}

		onClicked: {
			qnumKeyboard.open("Poort", homeassistantPortLabel.inputText, "Nummer", 1, updateHomeAssistantPortLabel, numValidate);
		}
	}


	EditTextLabel {
		id: homeassistantPasswordLabel
		width: 350
		height: 35
		leftText: "Wachtwoord"
		leftTextAvailableWidth: 200

		anchors {
			left: homeassistantHostLabel.right
			leftMargin: 20
			top: homeassistantText.bottom
			topMargin: 10
		}

		onClicked: {
			qkeyboard.open("Wachtwoord", homeassistantPasswordLabel.inputText, updateHomeAssistantPasswordLabel);
		}
	}

	EditTextLabel {
		id: homeassistantGroupsLabel
		width: 350
		height: 35
		leftText: "Group"
		leftTextAvailableWidth: 200

		anchors {
			left: homeassistantHostLabel.right
			leftMargin: 20
			top: homeassistantPasswordLabel.bottom
			topMargin: 10
		}

		onClicked: {
			qkeyboard.open("Group", homeassistantGroupsLabel.inputText, updateHomeAssistantGroupsLabel);
		}
	}


}