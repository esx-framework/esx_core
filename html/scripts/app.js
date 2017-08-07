var documentWidth  = document.documentElement.clientWidth;
var documentHeight = document.documentElement.clientHeight;

var cursor  = document.getElementById("cursor");
var cursorX = documentWidth  / 2;
var cursorY = documentHeight / 2;

function UpdateCursorPos() {
	cursor.style.left = cursorX;
	cursor.style.top = cursorY;
}

function Click(x, y) {
	var element = $(document.elementFromPoint(x, y));
	element.focus().click();
}

$(document).mousemove(function(event) {
  cursorX = event.pageX;
  cursorY = event.pageY;
  UpdateCursorPos();
});

window.onload = function(e){
	// NUI Callback
	window.addEventListener('message', function(event){		
		let data = event.data;
		if(data.showControls){
			$('#container').show();
			$('#menu'     ).hide();
			$(cursor      ).hide();
		}
		if(data.showMenu){
			$('#container'     ).show();
			$('#menu'          ).show();
			$(cursor           ).show();
			$('#deposit_amount').val(data.player.money)
			let bankAmount = 0;
			for(let i=0; i<data.player.accounts.length; i++)
				if(data.player.accounts[i].name == 'bank')
					bankAmount = data.player.accounts[i].money;
			if(bankAmount >= 10000)
				$('#withdraw_amount').val(10000)
			else
				$('#withdraw_amount').val(bankAmount)
		}

		if(data.hideAll){
			$('#container').hide();
			$(cursor      ).hide();
		}
		if (data.click) {
		   // Avoid clicking the cursor itself, click 1px to the top/left;
		   Click(cursorX - 1, cursorY - 1);
		}

	})
}

document.onkeyup = function (data) {
	if (data.which == 27) {
		$.post('http://esx_atm/escape', '{}');
	}
};

$('#container').hide()

$('#deposit_btn').click(() => {
	$.post('http://esx_atm/deposit', JSON.stringify({
		amount: $('#deposit_amount').val()
	}));
})

$('#withdraw_btn').click(() => {
	$.post('http://esx_atm/withdraw', JSON.stringify({
		amount: $('#withdraw_amount').val()
	}));
})