const w = window;

const types = {
	["success"]: {
		["icon"]: "check_circle",
		["frequency"]: 800,
		["duration"]: 100,
		["color"]: "#2ecc71",
		["borderColor"]: "#1f9c4d",
	},
	["error"]: {
		["icon"]: "error",
		["frequency"]: 300,
		["duration"]: 150,
		["color"]: "#e74c3c",
		["borderColor"]: "#c0392b",
	},
	["info"]: {
		["icon"]: "info",
		["frequency"]: 600,
		["duration"]: 100,
		["color"]: "#3498db",
		["borderColor"]: "#2980b9",
	},
	["warning"]: {
		["icon"]: "warning_amber",
		["frequency"]: 450,
		["duration"]: 125,
		["color"]: "#f39c12",
		["borderColor"]: "#d35400",
	},
};

// the color codes example `i ~r~love~s~ donuts`
const codes = {
	"~r~": "#c0392b",
	"~b~": "#378cbf",
	"~g~": "#2ecc71",
	"~y~": "yellow",
	"~p~": "purple",
	"~c~": "grey",
	"~m~": "#212121",
	"~u~": "black",
	"~o~": "#fb9b04",
};

// Audio context for sound effects
let audioContext;

// Initialize audio context on user interaction
document.addEventListener("click", initAudioContext, { once: true });
document.addEventListener("keydown", initAudioContext, { once: true });

function initAudioContext() {
	if (!audioContext) {
		audioContext = new (window.AudioContext || window.webkitAudioContext)();
	}
}

function playNotificationSound(type) {
	if (!audioContext) initAudioContext();

	const typeConfig = types[type] || types["info"];
	const oscillator = audioContext.createOscillator();
	const gainNode = audioContext.createGain();

	oscillator.type = "sine";
	oscillator.frequency.setValueAtTime(typeConfig.frequency, audioContext.currentTime);

	gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
	gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + typeConfig.duration / 1000);

	oscillator.connect(gainNode);
	gainNode.connect(audioContext.destination);

	oscillator.start();
	oscillator.stop(audioContext.currentTime + typeConfig.duration / 1000);
}

w.addEventListener("message", (event) => {
	notification({
		type: event.data.type,
		title: event.data.title || "New Notification",
		message: event.data.message,
		length: event.data.length,
		position: event.data.position,
		notificationSoundEnabled: event.data.notificationSoundEnabled,
	});
});

const replaceColors = (str, obj) => {
	let strToReplace = str;

	for (const id in obj) {
		strToReplace = strToReplace.replace(new RegExp(id, "g"), obj[id]);
	}

	return strToReplace;
};

const sanitizeHTML = (str) => {
	const temp = document.createElement("div");
	temp.textContent = str;
	return temp.innerHTML;
};

const processLineBreaks = (str) => {
	// Replace <br> tags with actual line breaks
	return str.replace(/&lt;br&gt;/g, "<br>");
};

const notification = (data) => {
	if (typeof $ === "undefined") {
		console.error("jQuery is not loaded. Please ensure jQuery is included in your project.");
		return;
	}

	if (data.message) {
		// Remove any standalone ~s~ tags (not preceded by a color code)
		data.message = data.message.replace(/~s~/g, "");
	}

	if (data.title) {
		// Remove any standalone ~s~ tags (not preceded by a color code)
		data.title = data.title.replace(/~s~/g, "");
	}

	let sanitizedTitle = data.title ? sanitizeHTML(data.title) : "";
	let sanitizedMessage = data.message ? sanitizeHTML(data.message) : "";

	if (data.title) {
		for (const color in codes) {
			if (sanitizedTitle.includes(color)) {
				const objArr = {};
				objArr[color] = `<span style="color: ${codes[color]}">`;
				objArr["~s~"] = "</span>";
				sanitizedTitle = replaceColors(sanitizedTitle, objArr);
			}
		}
	}

	for (const color in codes) {
		if (sanitizedMessage.includes(color)) {
			const objArr = {};
			objArr[color] = `<span style="color: ${codes[color]}">`;
			objArr["~s~"] = "</span>";
			sanitizedMessage = replaceColors(sanitizedMessage, objArr);
		}
	}

	sanitizedMessage = processLineBreaks(sanitizedMessage);
	sanitizedTitle = processLineBreaks(sanitizedTitle);

	const id = Math.floor(Math.random() * 100000);
	const typeInfo = types[data.type] || types["info"];
	const duration = data.length || 3000;
	const containerToAppend = data.position ? `#${data.position}` : "#middle-right";

	if (!$(containerToAppend).length) {
		console.error(`Container ${containerToAppend} to add the notification not found.`);
		return;
	}

	const notificationElement = $(`
    <div id="${id}" class="notify notify-${data.type} fadeIn">
      <div class="notify-icon-container">
        <div class="hexagon" style="--icon-color: ${typeInfo.color}; --border-color: ${typeInfo.borderColor}">
          <span class="material-symbols-outlined">${typeInfo.icon}</span>
        </div>
      </div>
      <div class="notify-content">
        <h3 class="notify-title">${sanitizedTitle}</h3>
        <p class="notify-text">${sanitizedMessage}</p>
        <div class="notify-progress" style="background-color: ${typeInfo.color}"></div>
      </div>
    </div>
  `).appendTo(containerToAppend);

	$(`#${id} .notify-progress`).css({
		transition: `width ${duration}ms linear`,
		width: "0%",
	});

	if (data.notificationSoundEnabled) {
		playNotificationSound(data.type);
	}

	setTimeout(() => {
		$(`#${id} .notify-progress`).css("width", "100%");
	}, 10);

	setTimeout(() => {
		$(`#${id}`).removeClass("fadeIn").addClass("fadeOut");
		setTimeout(() => {
			$(`#${id}`).remove();
		}, 500);
	}, duration);

	return notificationElement;
};
