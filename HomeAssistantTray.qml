import QtQuick 1.1
import Effects 1.0

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: homeassistantSystrayIcon
	visible: true
	posIndex: 8000

	onClicked: {
		stage.openFullscreen(app.homeassistantScreenUrl);
	}

	onDimStateChanged: {
		if (dimState)
			colorize.setColor(colors.inboxSystrayIconDim);			
		else
			colorize.setColor("#07aee6");
	}

	Image {
		id: imghomeAssistant
		anchors.centerIn: parent
		source: "./drawables/hass.png"
		effect: Colorize {id: colorize; color: "#07aee6"; strength: 1.0}
	}
}
