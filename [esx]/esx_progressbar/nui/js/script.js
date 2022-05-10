const w = window
const doc = document

$(function () {
    w.addEventListener('message', function(e) {
        $(".text").text(e.data.message)
        if (e.data.type === "Progressbar") {
            doc.getElementById("notifyInfo").style.display = "block";
            const start = new Date();
            const maxTime = e.data.length
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
                    setTimeout(animUpdate, timeoutValue);
                } else {
                   doc.getElementById('notifyInfo').style.display = "none";
                }
            }
        } else {
            doc.getElementById("notifyInfo").style.display = "none"
        }
    })
})
