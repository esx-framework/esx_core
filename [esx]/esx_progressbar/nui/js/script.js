const w = window
const doc = document

const codes = {
    "~r~": "red",
    "~b~": "#378cbf",
    "~g~": "green",
    "~y~": "yellow",
    "~p~": "purple",
    "~c~": "grey",
    "~m~": "#212121",
    "~u~": "black",
    "~o~": "orange"
}

$(function () {
    w.addEventListener('message', function(e) {
        if (e.data.type === "Progressbar") {
            var message = e.data.message
            const replaceColors = (str, obj) => {
                let strToReplace = str
            
                for (let id in obj) {
                    strToReplace = strToReplace.replace(new RegExp(id, 'g'), obj[id])
                }
            
                return strToReplace
            }
            for (color in codes) {
                if (message.includes(color)) {
                    let objArr = {};
                    objArr[color] = `<span style="color: ${codes[color]}">`;
                    objArr["~s~"] = "</span>";
        
                    let newStr = replaceColors(message, objArr);
        
                    message = newStr;
                }
            }
            $(".text").text(message)
            doc.getElementById("notifyInfo").style.display = "block";
            const start = new Date();
            const maxTime = e.data.length;
            const timeoutValue = Math.floor(maxTime/100);
            animUpdate();

            function updateProg(prc) {
                $("#progline").css("width", prc + "%");
            }
            
            function animUpdate() {
                const now = new Date();
                const timeoutDiff = now.getTime() - start.getTime();
                const prc = Math.round((timeoutDiff/maxTime)*100);
                if (prc <= 100) {
                    updateProg(prc);
                    this.timeoutID = setTimeout(animUpdate, timeoutValue);
                } else {
                   doc.getElementById('notifyInfo').style.display = "none";
                }
            }
        } else {
            doc.getElementById("notifyInfo").style.display = "none"
            clearTimeout(this.timeoutID);
            timeoutValue = 0;

        }
    })
})
