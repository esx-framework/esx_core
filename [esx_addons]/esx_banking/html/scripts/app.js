$(window).ready(function () {
	window.addEventListener('message', function (event) {
		let data = event.data;
		if (data.showMenu) {
			$('#container').fadeIn();
			$('#menu').fadeIn();
			$('#deposit_amount').val(data.player.money);

			let bankAmount = 0;
			for (let i = 0; i < data.player.accounts.length; i++) {
				if (data.player.accounts[i].name == 'bank') {
					bankAmount = data.player.accounts[i].money;
					$('#player-details').html("Money: $" + data.player.money);
					$('#bank-details').html("Bank Balance: $" + bankAmount);
				}
			}

			$('#withdraw_amount').val(bankAmount);
		} else if (data.hideAll) {
			$('#container').fadeOut();
		}
		if(data.history) {
			//Play with this poop
			$('#transaction-list').html(getHistory(data.history))
		}
		
	});

	document.onkeyup = function (data) {
		if (data.which == 27) {
			$.post('http://esx_banking/escape', '{}');
		}
	};

	$('#container').hide();

	$('#deposit_btn').on('click', function () {
		$.post('http://esx_banking/deposit', JSON.stringify({
			amount: $('#deposit_amount').val()
		}));

		$('#deposit_amount').val(0);
	})

	$('#deposit_amount').on("keyup", function (e) {
		if (e.keyCode == 13) {
			$.post('http://esx_banking/deposit', JSON.stringify({
				amount: $('#deposit_amount').val()
			}));

			$('#deposit_amount').val(0);
		}
	});

	$('#withdraw_btn').on('click', function () {
		$.post('http://esx_banking/withdraw', JSON.stringify({
			amount: $('#withdraw_amount').val()
		}));

		$('#withdraw_amount').val(0);
	});

	$('#withdraw_amount').on("keyup", function (e) {
		if (e.keyCode == 13) {
			$.post('http://esx_banking/withdraw', JSON.stringify({
				amount: $('#withdraw_amount').val()
			}));

			$('#withdraw_amount').val(0);
		}
	});

	function getHistory(history) {
		let html = '';
		let jsonData = JSON.parse(history[0]).reverse()
		for(let i = 0; i < jsonData.length; i++){
			html += "<div class='transaction-listing'>"
			if(jsonData[i].type.toString() === "withdraw"){
				html += "<div style='color: green;'>$+" + jsonData[i].amount + "</div>";
			}else{
				html += "<div style='color: red;'>$-" + jsonData[i].amount + "</div>";
			}
				html += "<div> " + jsonData[i].type + "</div>";
			html += "</div>"
		}
		return html;
	}

});
