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

    const id = Math.floor(Math.random() * Math.random());
    const notification = $(`
        <div id="${id}" class="notify ${data.type} fadeIn">
            <div class="innerText">
                <span class="material-symbols-outlined icon">${types[data.type] ? types[data.type]["icon"] : types["info"]["icon"]}</span>
                <p class="text">${data["message"]}</p>
            </div>
        </div>
    `).appendTo(`#root`);

    setTimeout(() => {
        document.getElementById(id).classList.remove("fadeIn");
    }, 300);

    setTimeout(() => {
        document.getElementById(id).classList.add("fadeOut");

        setTimeout(() => {
            document.getElementById(id).remove();
        }, 400);
    },data.length);

    return notification;
};
