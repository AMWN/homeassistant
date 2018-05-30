import QtQuick 1.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: homeassistantScreen
	screenTitleIconUrl: "drawables/hass.png"
	screenTitle: qsTr("Home Assistant")

	onShown: {
		addCustomTopRightButton("Settings");	
	}

	onCustomButtonClicked: {
		stage.openFullscreen(app.homeassistantSettingsUrl);
	}

	Row {
		spacing: 10
		anchors {
			top: parent.top
			topMargin: 20
			left: parent.left
			leftMargin: 32
		}

		Repeater {
			id: groupRepeater
			model: app.groups
			StandardButton {
				id: btnConfigScreen
				width: 106
				height: 45
				text: app.groups[index]
				onClicked: {
					app.switchSelectedGroup(app.groups[index])
				}
			}
		}
		
	}

	Grid {
		spacing: 10
		columns: 4
		rows: 5
		visible: true
		anchors {
			top: parent.top
			topMargin: 75
			left: parent.left
			leftMargin: 32
		}

		Repeater {
			id: switchesRepeater
			model: app.devices
			SwitchItem {
				entity_id: app.devices[index]['entity_id']
				friendly_name: app.devices[index]['attributes']['friendly_name']
				last_changed: app.devices[index]['last_changed']
				last_updated: app.devices[index]['last_updated']
				switchState: app.devices[index]['state']
			}
		}
	}

}