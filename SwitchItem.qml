import QtQuick 1.1
import BasicUIControls 1.0

Item {
	id: switchItem
	width: 177
	height: 75

	property string entity_id;
	property string friendly_name;
	property string last_changed;
	property string last_updated;
	property string switchState;
	property string type: entity_id.split('.')[0]

	property color colorLight: "#f0f0f0"
	property color colorMedium: "#A8A8A8"
	property color colorDark: "#565656"
	property color bckgColorUp: "#f0f0f0"
	property color bckgColorDown: "#A8A8A8"

	state: "up"
	visible: true

	states: [
		State {
			name: "up"
			PropertyChanges {
				target: switch1Title;color: colorDark
			}
			PropertyChanges {
				target: switch1Last;color: colorDark
			}
			PropertyChanges {
				target: switch1Data;color: colorDark
			}
			PropertyChanges {
				target: switch1BG;color: bckgColorUp
			}
		},
		State {
			name: "down"
			PropertyChanges {
				target: switch1Title;color: bckgColorUp
			}
			PropertyChanges {
				target: switch1Last;color: bckgColorUp
			}
			PropertyChanges {
				target: switch1Data;color: bckgColorUp
			}
			PropertyChanges {
				target: switch1BG;color: bckgColorDown
			}
		}
	]

	function getImage(switchState, type) {
		switch (type) {
			case 'group':
				if(switchState != "on" && switchState != "off")
					break;
			case 'light':
			case 'switch':
				return (switchState === "off") ? "./drawables/bulb_off.png" : "./drawables/bulb_on.png"
			default:
				return "./drawables/sensor.png"
		}
	}

	MouseArea {
		anchors.fill: parent
		onPressed: {
			switchItem.state = "down"

			switch (type) {
				case 'group':
					{
						if(switchState != "on" && switchState != "off")
							break;
					}
				case 'light':
				case 'switch':
					{
						switchState = (switchState == "off" ? "on" : "off")
						app.postHomeAssistant(entity_id, switchState)
						break;
					}
				default:
					break;
			}

		}
		onReleased: {
			switchItem.state = "up"
		}
	}

	Item {
		anchors.fill: parent

		Rectangle {
			id: switch1BG
			width: parent.width
			height: parent.height
			radius: 3
			color: bckgColorUp
		}

		Image {
			id: switch1Button
			anchors {
				top: parent.top
				topMargin: 11
				left: parent.left
				leftMargin: 10
			}
			visible: true;
			width: 30
			height: 38
			source: getImage(switchState, type)
		}

		Text {
			id: switch1Title
			anchors {
				top: parent.top
				topMargin: 7
				left: parent.left
				leftMargin: 50
			}
			font {
				family: qfont.semiBold.name
				pixelSize: 15
			}
			color: colorDark
			text: friendly_name.substring(0, 14)
		}

		Text {
			id: switch1Data
			anchors {
				top: switch1Title.bottom
				left: switch1Button.right
				leftMargin: 10
			}
			font {
				family: qfont.semiBold.name
				pixelSize: 12
			}
			color: colorDark
			text: switchState
		}

		Text {
			id: switch1Last
			anchors {
				top: switch1Data.bottom
				topMargin: 3
				left: switch1Button.right
				leftMargin: 10
			}
			font {
				family: qfont.semiBold.name
				pixelSize: 9
			}
			color: colorMedium
			text: last_updated.substring(0, 16)
		}
	}
}
