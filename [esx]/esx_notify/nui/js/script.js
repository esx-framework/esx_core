const w = window
const doc = document

$(function () {
    w.addEventListener('message', function(e) {
        $(".text").text(e.data.message)
        if (e.data.type === "info") {
            console.log("info")
            doc.getElementById("notifyInfo").style.display = "block";
            Timeout()
        } else if (e.data.type === "error") {
            console.log("error")
            doc.getElementById("notifyError").style.display = "block";
            Timeout()
        } else if (e.data.type === "success") {
            console.log("succeeeess")
            doc.getElementById("notifySuccess").style.display = "block";
            Timeout()
        }

        function Timeout() {
            setTimeout(function () {
                doc.getElementById("notifyInfo").style.display = "none";
                doc.getElementById("notifyError").style.display = "none";
                doc.getElementById("notifySuccess").style.display = "none";
            }, e.data.length)
        }
    })
})