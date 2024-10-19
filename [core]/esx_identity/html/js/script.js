let devMode = false

window.addEventListener("message", (event) => {
    if (devMode) {
        document.body.classList.remove('none')
    }
    if (event.data.type === "enableui") {
        document.body.classList[event.data.enable ? "remove" : "add"]("none");
    }
});

document.querySelector("#register").addEventListener("submit", (event) => {
    event.preventDefault();

    const dofVal = document.querySelector("#dob").value;
    if (!dofVal) return;

    const formattedDate = dofVal;

    if (!devMode) {
        fetch("http://esx_identity/register", {
            method: "POST",
            body: JSON.stringify({
                firstname: document.querySelector("#firstname").value,
                lastname: document.querySelector("#lastname").value,
                dateofbirth: formattedDate,
                sex: document.querySelector("input[type='radio'][name='gender']:checked").value,
                height: document.querySelector("#height").value,
            }),
        });
    }

    document.querySelector("#register").reset();
});

document.addEventListener("DOMContentLoaded", () => {
    if (!devMode) {
        fetch("http://esx_identity/ready", {
            method: "POST",
            body: JSON.stringify({}),
        });
    }
});
