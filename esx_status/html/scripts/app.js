(function () {
	let status = [];

	let renderStatus = function () {

		$('#status_list').html('');

		for (let i = 0; i < status.length; i++) {

			if (!status[i].visible) {
				continue;
			}

			let statusDiv = $(
				'<div class="status">' +
					'<div class="status_inner">' +
						'<div class="status_val"></div>' +
					'</div>' +
				'</div>');

			statusDiv.find('.status_inner')
				.css({ 'border': '1px solid ' + status[i].color })
				;

			statusDiv.find('.status_val')
				.css({
					'background-color': status[i].color,
					'width': (status[i].percent) + '%'
				})
				;

			$('#status_list').append(statusDiv);
		}

	};

	window.onData = function (data) {
		if (data.update) {
			status.length = 0;

			for (let i = 0; i < data.status.length; i++) {
				status.push(data.status[i]);
			}

			renderStatus();
		}

		if (data.setDisplay) {
			$('#status_list').css({ 'opacity': data.display });
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', function (event) {
			onData(event.data);
		});
	};

})();
