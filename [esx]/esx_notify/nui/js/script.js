const w = window
const doc = document


$(function () {
    w.addEventListener('message', function(e) {
        $(".text").text('')
        const start = new Date()
        const max = e.data.length
        const val = Math.floor(max/100)
        let current = ""
        let blackc = {'color': '#000'};
        let redc = {'color': '#F00'};
        let greenc = {'color': '#0F0'};
        let bluec = {'color': '#00F'};
        let yellowc = {'color': '#ff0'};
        let greyc = {'color': '#808080'};
        let darkgreyc = {'color': '#a9a9a9'};
        let orangec = {'color': '#FFA500'};
        let purplec = {'color': '#800080'};
        let whitec = {'color': '#FFF'};

        if (e.data.type === "info") {
            doc.getElementById("notifyInfo").style.display = "block";
            let finalarr = []
            



            var arr = e.data.message.split("~")
            for (let i = 0; i < arr.length; i++) {
              let arr1 = arr[i]
              
              let redTrue = arr1.startsWith("r")
              let greenTrue = arr1.startsWith("g")
              let whiteTrue = arr1.startsWith("w")
              let blackTrue = arr1.startsWith("u")
              let blueTrue = arr1.startsWith("b")
              let yellowTrue = arr1.startsWith("y")
              let greyTrue = arr1.startsWith("c")
              let darkgreyTrue = arr1.startsWith("m")
              let orangeTrue = arr1.startsWith("o")
              let purpleTrue = arr1.startsWith("p")

              if (i == 0) {
                if (arr1.startsWith("~")) {

                } else {
                let arr3 = $('<span>' + arr[i] + '</span>');
                arr3.css(whitec)
                
                finalarr.push(arr3)
                }
              }

              if (redTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(redc)
                
                finalarr.push(arr3)
              } else if (greenTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(greenc)
                
                finalarr.push(arr3)
              } else if (whiteTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(whitec)
                
                finalarr.push(arr3)
              } else if (blackTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(blackc)
                
                finalarr.push(arr3)
              } else if (blueTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(bluec)
                
                finalarr.push(arr3)
              } else if (yellowTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(yellowc)
                
                finalarr.push(arr3)
              } else if (greyTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(greyc)
                
                finalarr.push(arr3)
              } else if (darkgreyTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(darkgreyc)
                
                finalarr.push(arr3)
              } else if (orangeTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(orangec)
                
                finalarr.push(arr3)
              } else if (purpleTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(purplec)
                finalarr.push(arr3)
              }


            }
            $(".text").append(finalarr);
            finalarr = []
            RequestAnimUpdate()
            current = "notifyInfo"
        } else if (e.data.type === "error") {
            doc.getElementById("notifyError").style.display = "block";
            let finalarr = []
            



            var arr = e.data.message.split("~")
            for (let i = 0; i < arr.length; i++) {
              let arr1 = arr[i]
              
              let redTrue = arr1.startsWith("r")
              let greenTrue = arr1.startsWith("g")
              let whiteTrue = arr1.startsWith("w")
              let blackTrue = arr1.startsWith("u")
              let blueTrue = arr1.startsWith("b")
              let yellowTrue = arr1.startsWith("y")
              let greyTrue = arr1.startsWith("c")
              let darkgreyTrue = arr1.startsWith("m")
              let orangeTrue = arr1.startsWith("o")
              let purpleTrue = arr1.startsWith("p")

              if (i == 0) {
                if (arr1.startsWith("~")) {

                } else {
                let arr3 = $('<span>' + arr[i] + '</span>');
                arr3.css(whitec)
                
                finalarr.push(arr3)
                }
              }

              if (redTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(redc)
                
                finalarr.push(arr3)
              } else if (greenTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(greenc)
                
                finalarr.push(arr3)
              } else if (whiteTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(whitec)
                
                finalarr.push(arr3)
              } else if (blackTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(blackc)
                
                finalarr.push(arr3)
              } else if (blueTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(bluec)
                
                finalarr.push(arr3)
              } else if (yellowTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(yellowc)
                
                finalarr.push(arr3)
              } else if (greyTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(greyc)
                
                finalarr.push(arr3)
              } else if (darkgreyTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(darkgreyc)
                
                finalarr.push(arr3)
              } else if (orangeTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(orangec)
                
                finalarr.push(arr3)
              } else if (purpleTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(purplec)
                finalarr.push(arr3)
              }


            }
            $(".text").append(finalarr);
            RequestAnimUpdate()
            current = "notifyError"
        } else if (e.data.type === "success") {
            doc.getElementById("notifySuccess").style.display = "block";
            let finalarr = []
            



            var arr = e.data.message.split("~")
            for (let i = 0; i < arr.length; i++) {
              let arr1 = arr[i]
              
              let redTrue = arr1.startsWith("r")
              let greenTrue = arr1.startsWith("g")
              let whiteTrue = arr1.startsWith("w")
              let blackTrue = arr1.startsWith("u")
              let blueTrue = arr1.startsWith("b")
              let yellowTrue = arr1.startsWith("y")
              let greyTrue = arr1.startsWith("c")
              let darkgreyTrue = arr1.startsWith("m")
              let orangeTrue = arr1.startsWith("o")
              let purpleTrue = arr1.startsWith("p")

              if (i == 0) {
                if (arr1.startsWith("~")) {

                } else {
                let arr3 = $('<span>' + arr[i] + '</span>');
                arr3.css(whitec)
                
                finalarr.push(arr3)
                }
              }

              if (redTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(redc)
                
                finalarr.push(arr3)
              } else if (greenTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(greenc)
                
                finalarr.push(arr3)
              } else if (whiteTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(whitec)
                
                finalarr.push(arr3)
              } else if (blackTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(blackc)
                
                finalarr.push(arr3)
              } else if (blueTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(bluec)
                
                finalarr.push(arr3)
              } else if (yellowTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(yellowc)
                
                finalarr.push(arr3)
              } else if (greyTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(greyc)
                
                finalarr.push(arr3)
              } else if (darkgreyTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(darkgreyc)
                
                finalarr.push(arr3)
              } else if (orangeTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(orangec)
                
                finalarr.push(arr3)
              } else if (purpleTrue) {
                x = i + 1
                
                
                let arr3 = $('<span>' + arr[x] + '</span>');
                arr3.css(purplec)
                finalarr.push(arr3)
              }


            }
            $(".text").append(finalarr);
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
