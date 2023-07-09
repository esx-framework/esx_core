const w = window;
const doc = document;
let lastType = "";

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
    "~r~": "red",
    "~b~": "#378cbf",
    "~g~": "green",
    "~y~": "yellow",
    "~p~": "purple",
    "~c~": "grey",
    "~m~": "#212121",
    "~u~": "black",
    "~o~": "orange",
};

w.addEventListener("message", (event) => {
    if (event.data.action === "show") {
        if (lastType) {
            doc.getElementById(lastType).style.display = "none";
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
            doc.getElementById(lastType).style.display = "none";
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
    lastType = types[data.type]["id"];
    doc.getElementById(types[data.type]["message"]).innerHTML = data["message"];
};
