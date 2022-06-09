const w = window
const doc = document
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

$(function () {
    w.addEventListener('message', function(e) {
        $(".text").text('')
        if (e.data.action === "show") {
            if (e.data.type === "info") {
                
                finalarr = conv(e.data.message)
                
                $(".text").append(finalarr);
                finalarr = []
                doc.getElementById("notifyInfo").style.display = "block";
            } else if (e.data.type === "error") {
                finalarr = conv(e.data.message)
                
                $(".text").append(finalarr);
                finalarr = []
                doc.getElementById("notifyError").style.display = "block";
            } else if (e.data.type === "success") {
                finalarr = conv(e.data.message)
                
                $(".text").append(finalarr);
                finalarr = []
                doc.getElementById("notifySuccess").style.display = "block";
            }
        } else if (e.data.action === "hide") {
            doc.getElementById("notifyInfo").style.display = "none";
            doc.getElementById("notifyError").style.display = "none";
            doc.getElementById("notifySuccess").style.display = "none";
        }
    })
})

function conv(spoop) {
				let finalarr = []
                var arr = spoop.split("~")
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
                  x = i + 1
                  if (i == 0) {
                    if (arr1.startsWith("~")) {
                    
                    } else {
                    let arr3 = $('<span>' + arr[i] + '</span>');
                    arr3.css(whitec)
                    
                    finalarr.push(arr3)
                    }
                  }
              
                  if (redTrue) {
                    arr3 = PushData(arr[x], redc)
                    
                    finalarr.push(arr3)
                  } else if (greenTrue) {
                    arr3 = PushData(arr[x], greenc)

                    finalarr.push(arr3)
                  } else if (whiteTrue) {
                    arr3 = PushData(arr[x], whitec)
                    
                    finalarr.push(arr3)
                  } else if (blackTrue) {
                    arr3 = PushData(arr[x], blackc)
                      
                    finalarr.push(arr3)
                  } else if (blueTrue) {
                    arr3 = PushData(arr[x], bluec)
                    
                    finalarr.push(arr3)
                  } else if (yellowTrue) {
                    arr3 = PushData(arr[x], yellowc)
                    
                    finalarr.push(arr3)
                  } else if (greyTrue) {
                    arr3 = PushData(arr[x], greyc)
                    
                    finalarr.push(arr3)
                  } else if (darkgreyTrue) {
                    arr3 = PushData(arr[x], darkgreyc)
                    
                    finalarr.push(arr3)
                  } else if (orangeTrue) {
                    arr3 = PushData(arr[x], orangec)
                    
                    finalarr.push(arr3)
                  } else if (purpleTrue) {
                    arr3 = PushData(arr[x], purplec)
                    finalarr.push(arr3)
                  }
              
              
                }
  return finalarr
}
function PushData(data, color) {
                    
                    
    let arr3 = $('<span>' + data + '</span>');
    arr3.css(color)
                    
    return arr3
}