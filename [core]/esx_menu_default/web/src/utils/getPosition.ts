export const GetPosition = (pos: string) => {

    pos = pos ? pos : "right-center"

    if (pos == "center") {
        return "top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"
    }

    const classes: string[] = [];


    if (pos.includes("top")) {
        classes.push("top-4");
    } else if (pos.includes("center")) {
        classes.push("top-1/2", "-translate-y-1/2");
    } else {
        classes.push("bottom-4");
    }

    if (pos.includes("left")) {
        classes.push("left-4");
    } else {
        classes.push("right-4");
    }

    return classes.join(" ");
}