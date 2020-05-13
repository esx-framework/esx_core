document.getElementById('ui').innerHTML = "<div id='pb'><div id='pbar_outerdiv' style='margin-top: 45.5%; left: 42.5%; background-color: rgba(0,0,0,0.25); width: 15%; height: 30px; z-index: 1; position: relative; border-style: solid; border-radius: 3px; border-width: 2px;'><div id='pbar_innerdiv' style='background-color: rgba(0, 83, 236, 0.95); z-index: 2; height: 100%; width: 0%; border-radius: 3px;'></div><div id='pbar_innertext' style='color: white; z-index: 3; position: absolute; top: 3px; left: 0; width: 100%; height: 100%; font-weight: bold; text-align: center; font-family: Bebas Neue, cursive; margin-top: 2px; letter-spacing: 2px;'>0%</div></div></div>";
$(function(){
	window.onload = (e) => {
	window.addEventListener('message', (event) => {
	var item = event.data;
		if (item !== undefined && item.type === "progressbar") {
			if (item.display === true) {
		        $("#pb").show();
					var start = new Date();
					var maxTime = item.time;
					var text = item.text;
					var timeoutVal = Math.floor(maxTime/100);
					animateUpdate();
					$('#pbar_innertext').text(text);
					function updateProgress(percentage) {
						$('#pbar_innerdiv').css("width", percentage + "%");
					}
					function animateUpdate() {
						var now = new Date();
						var timeDiff = now.getTime() - start.getTime();
						var perc = Math.round((timeDiff/maxTime)*100);
						if (perc <= 100) {
							updateProgress(perc);
							setTimeout(animateUpdate, timeoutVal);
						} else {
							$("#pb").hide();
						}
					}
				} else {
		            $("#pb").hide();
		        }
			}
		});
	};
});