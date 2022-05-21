const w = window
const doc = document

$(function () {
    w.addEventListener('message', function(e) {
        $(".text").text(e.data.message)
        const start = new Date()
        const max = e.data.length
        const val = Math.floor(max/100)
        let current = ""
        if (e.data.type === "info") {
            doc.getElementById("notifyInfo").style.display = "block";
            RequestAnimUpdate()
            current = "notifyInfo"
        } else if (e.data.type === "error") {
            doc.getElementById("notifyError").style.display = "block";
            RequestAnimUpdate()
            current = "notifyError"
        } else if (e.data.type === "success") {
            doc.getElementById("notifySuccess").style.display = "block";
            RequestAnimUpdate()
            current = "notifySuccess"
        }

        function RequestAnimUpdate() {
            const now = new Date()
            const diff = now.getTime() - start.getTime();
            const prc = Math.round((diff/max)*100)
            if (prc <= 100) {
                RequestUpdateProgress(prc)
                setTimeout(RequestAnimUpdate, val)
            } else {
                doc.getElementById(current).style.display = "none"
            }
        }

        function RequestUpdateProgress(prc) {
            $(".prog").css("width", prc + "%")
        }
    })
})
