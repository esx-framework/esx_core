(() => {
	ESX = {};

	ESX.inventoryNotification = function (add, label, count) {
		let notif = '';

		if (add) {
			notif += '+';
		} else {
			notif += '-';
		}

		if (count) {
			notif += count + ' ' + label;
		} else {
			notif += ' ' + label;
		}

		let elem = $('<div>' + notif + '</div>');
		$('#inventory_notifications').append(elem);

		$(elem).delay(3000).fadeOut(1000, function () {
			elem.remove();
		});
	};

	window.onData = (data) => {
		if (data.action === 'inventoryNotification') {
			ESX.inventoryNotification(data.add, data.item, data.count);
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};
})();
