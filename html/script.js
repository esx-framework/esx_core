var documentWidth = document.documentElement.clientWidth;
var documentHeight = document.documentElement.clientHeight;

var cursor = document.getElementById("cursor");
var cursorX = documentWidth / 2;
var cursorY = documentHeight / 2;

function UpdateCursorPos() {
	cursor.style.left = cursorX;
	cursor.style.top = cursorY;
}

function Click(x, y) {
	var element = $(document.elementFromPoint(x, y));
	element.focus().click();
}

$(function() {
	window.addEventListener('message', function(event) {
		if (event.data.type == "enableui") {
			cursor.style.display = event.data.enable ? "block" : "none";
			document.body.style.display = event.data.enable ? "block" : "none";
		} else if (event.data.type == "click") {
			// Avoid clicking the cursor itself, click 1px to the top/left;
			Click(cursorX - 1, cursorY - 1);
		}
	});

	$(document).mousemove(function(event) {
		cursorX = event.pageX;
		cursorY = event.pageY;
		UpdateCursorPos();
	});

	document.onkeyup = function (data) {
		if (data.which == 27) { // Escape key
			$.post('http://esx_identity/escape', JSON.stringify({}));
		}
	};
	
	$("#register").submit(function(e) {
		e.preventDefault(); // Prevent form from submitting
		
		// Verify date
		var date = $("#dateofbirth").val();
		var dateCheck = new Date($("#dateofbirth").val());
		if (dateCheck == "Invalid Date") {
			date == "invalid";
		}
		$.post('http://esx_identity/register', JSON.stringify({
			firstname: $("#firstname").val(),
			lastname: $("#lastname").val(),
			dateofbirth: date,
			sex: $("input[type='radio'][name='sex']:checked").val(),
			height: $("#height").val()
		}));
	});
});
