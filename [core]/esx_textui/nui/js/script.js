const w = window;
const doc = document;
let lastType = {};

// Gets the current icon it needs to use.
const types = {
    ["success"]: {
        ["message"]: "successMessage",
        ["id"]: "notifySuccess",
    },
    ["error"]: {
        ["message"]: "errorMessage",
        ["id"]: "notifyError",
    },
    ["info"]: {
        ["message"]: "infoMessage",
        ["id"]: "notifyInfo",
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

w.addEventListener("message", (event) => {
    if (event.data.action === "show") {
        if (lastType.id !== undefined) {
            doc.getElementById(lastType["id"]).style.display = "none";
            notification({
                type: event.data.type,
                message: event.data.message,
            });
        } else {
            notification({
                type: event.data.type,
                message: event.data.message,
            });
        }
    } else if (event.data.action === "hide") {
        if (lastType !== "") {
            doc.getElementById(lastType["id"]).classList.add("fadeOut");
            setTimeout(() => {
                doc.getElementById(lastType["id"]).classList.remove("fadeOut");
                doc.getElementById(lastType["id"]).style.display = "none";
                doc.getElementById(lastType["message"]).innerHTML = "";
            }, 300);
        } else {
            console.log("There isn't a textUI displaying!?");
        }
    }
});

const replaceColors = (str, obj) => {
    let strToReplace = str;

    for (let id in obj) {
        strToReplace = strToReplace.replace(new RegExp(id, "g"), obj[id]);
    }

    return strToReplace;
};

notification = (data) => {
    for (color in codes) {
        if (data["message"].includes(color)) {
            let objArr = {};
            objArr[color] = `<span style="color: ${codes[color]}">`;
            objArr["~s~"] = "</span>";

            let newStr = replaceColors(data["message"], objArr);

            data["message"] = newStr;
        }
    }

    doc.getElementById(types[data.type]["id"]).style.display = "block";
    doc.getElementById(types[data.type]["id"]).classList.add("fadeIn");
    setTimeout(() => {
        doc.getElementById(types[data.type]["id"]).classList.remove("fadeIn");
        lastType = types[data.type];
        doc.getElementById(types[data.type]["message"]).innerHTML = data["message"];
    }, 300);
};
