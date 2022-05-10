const w = window
const doc = document

$(function () {
    w.addEventListener('message', function(e) {
        $(".text").text(e.data.message)
        if (e.data.action === "show") {
            if (e.data.type === "info") {
                doc.getElementById("notifyInfo").style.display = "block";
            } else if (e.data.type === "error") {
                doc.getElementById("notifyError").style.display = "block";
            } else if (e.data.type === "success") {
                doc.getElementById("notifySuccess").style.display = "block";
            }
        } else if (e.data.action === "hide") {
            doc.getElementById("notifyInfo").style.display = "none";
            doc.getElementById("notifyError").style.display = "none";
            doc.getElementById("notifySuccess").style.display = "none";
        }
    })
})