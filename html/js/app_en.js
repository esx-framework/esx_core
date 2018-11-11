(function () {

	let MenuTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="dialog {{#isBig}}big{{/isBig}}">' +
			'<div class="head"><span>{{title}}</span></div>' +
				'{{#isDefault}}<input type="text" name="value" id="inputText"/>{{/isDefault}}' +
				'{{#isBig}}<textarea name="value"/>{{/isBig}}' +
				'<button type="button" name="submit">Submit</button>' +
				'<button type="button" name="cancel">Cancel</button>' + 
			'</div>' +
		'</div>'
	;

	window.ESX_MENU       = {};
	ESX_MENU.ResourceName = 'esx_menu_dialog';
	ESX_MENU.opened       = {};
	ESX_MENU.focus        = [];
	ESX_MENU.pos          = {};

	ESX_MENU.open = function (namespace, name, data) {

		if (typeof ESX_MENU.opened[namespace] == 'undefined') {
			ESX_MENU.opened[namespace] = {};
		}

		if (typeof ESX_MENU.opened[namespace][name] != 'undefined') {
			ESX_MENU.close(namespace, name);
		}

		if (typeof ESX_MENU.pos[namespace] == 'undefined') {
			ESX_MENU.pos[namespace] = {};
		}

		if (typeof data.type == 'undefined') {
			data.type = 'default';
		}

		if (typeof data.align == 'undefined') {
			data.align = 'top-left';
		}

		data._index = ESX_MENU.focus.length;
		data._namespace = namespace;
		data._name = name;

		ESX_MENU.opened[namespace][name] = data;
		ESX_MENU.pos[namespace][name] = 0;

		ESX_MENU.focus.push({
			namespace: namespace,
			name: name
		});

		document.onkeyup = function (key) {
			if (key.which == 27) { // Escape key
				$.post('http://' + ESX_MENU.ResourceName + '/menu_cancel', JSON.stringify(data));
			} else if (key.which == 13) { // Enter key
				$.post('http://' + ESX_MENU.ResourceName + '/menu_submit', JSON.stringify(data));
			}
		};

		ESX_MENU.render();

	};

	ESX_MENU.close = function (namespace, name) {

		delete ESX_MENU.opened[namespace][name];

		for (let i = 0; i < ESX_MENU.focus.length; i++) {
			if (ESX_MENU.focus[i].namespace == namespace && ESX_MENU.focus[i].name == name) {
				ESX_MENU.focus.splice(i, 1);
				break;
			}
		}

		ESX_MENU.render();

	};

	ESX_MENU.render = function () {

		let menuContainer = $('#menus')[0];

		$(menuContainer).find('button[name="submit"]').unbind('click');
		$(menuContainer).find('button[name="cancel"]').unbind('click');
		$(menuContainer).find('[name="value"]').unbind('input propertychange');

		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for (let namespace in ESX_MENU.opened) {
			for (let name in ESX_MENU.opened[namespace]) {

				let menuData = ESX_MENU.opened[namespace][name];
				let view = JSON.parse(JSON.stringify(menuData));

				switch (menuData.type) {
					case 'default': {
						view.isDefault = true;
						break;
					}

					case 'big': {
						view.isBig = true;
						break;
					}

					default: break;
				}

				let menu = $(Mustache.render(MenuTpl, view))[0];

				$(menu).css('z-index', 1000 + view._index);

				$(menu).find('button[name="submit"]').click(function () {
					ESX_MENU.submit(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				$(menu).find('button[name="cancel"]').click(function () {
					ESX_MENU.cancel(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				$(menu).find('[name="value"]').bind('input propertychange', function () {
					this.data.value = $(menu).find('[name="value"]').val();
					ESX_MENU.change(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				if (typeof menuData.value != 'undefined')
					$(menu).find('[name="value"]').val(menuData.value);

				menuContainer.appendChild(menu);
			}
		}

		$(menuContainer).show();
		$("#inputText").focus();
	};

	ESX_MENU.submit = function (namespace, name, data) {
		$.post('http://' + ESX_MENU.ResourceName + '/menu_submit', JSON.stringify(data));
	};

	ESX_MENU.cancel = function (namespace, name, data) {
		$.post('http://' + ESX_MENU.ResourceName + '/menu_cancel', JSON.stringify(data));
	};

	ESX_MENU.change = function (namespace, name, data) {
		$.post('http://' + ESX_MENU.ResourceName + '/menu_change', JSON.stringify(data));
	};

	ESX_MENU.getFocused = function () {
		return ESX_MENU.focus[ESX_MENU.focus.length - 1];
	};

	window.onData = (data) => {

		switch (data.action) {
			case 'openMenu': {
				ESX_MENU.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeMenu': {
				ESX_MENU.close(data.namespace, data.name);
				break;
			}
		}

	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();