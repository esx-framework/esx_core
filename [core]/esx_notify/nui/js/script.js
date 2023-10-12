const w = window;

// Gets the current icon it needs to use.
const types = {
    ["success"]: {
        ["icon"]: "check_circle",
    },
    ["error"]: {
        ["icon"]: "error",
    },
    ["info"]: {
        ["icon"]: "info",
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
    notification({
        type: event.data.type,
        message: event.data.message,
        length: event.data.length,
    });
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

    const notification = $(`
        <div class="notify ${data.type}">
            <div class="innerText">
                <span class="material-symbols-outlined icon">${types[data.type]["icon"]}</span>
                <p class="text">${data["message"]}</p>
            </div>
        </div>
    `).appendTo(`#root`);

    setTimeout(() => {
        notification.fadeOut(700);
    }, data.length);

    return notification;
};
