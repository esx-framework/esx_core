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

const elems = {
    infoMessage: document.getElementById("infoMessage"),
    notifyInfo: document.getElementById("notifyInfo"),
    progline: document.getElementById("progline"),
};

const replaceColors = (str, obj) => {
    let strToReplace = str;

    for (let id in obj) {
        strToReplace = strToReplace.replace(new RegExp(id, "g"), obj[id]);
    }

    return strToReplace;
};

window.addEventListener("message", function ({ data }) {
    if (data.type === "Progressbar") {
        let { message } = data;

        for (color in codes) {
            if (message.includes(color)) {
                let objArr = {};
                objArr[color] = `<span style="color: ${codes[color]}">`;
                objArr["~s~"] = "</span>";

                let newStr = replaceColors(message, objArr);

                message = newStr;
            }
        }

        elems.infoMessage.innerHTML = message;
        elems.notifyInfo.style.display = "block";

        const start = new Date();
        const maxTime = data.length;
        const timeoutValue = Math.floor(maxTime / 100);
        animUpdate();

        function animUpdate() {
            const now = new Date();
            const timeoutDiff = now.getTime() - start.getTime();
            const prc = Math.round((timeoutDiff / maxTime) * 100);
            if (prc <= 100) {
                elems.progline.style.width = prc + "%";
                this.timeoutID = setTimeout(animUpdate, timeoutValue);
            } else {
                elems.notifyInfo.style.display = "none";
            }
        }
    } else {
        elems.notifyInfo.style.display = "none";
        clearTimeout(this.timeoutID);
        timeoutValue = 0;
    }
});
