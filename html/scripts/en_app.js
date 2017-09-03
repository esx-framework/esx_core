(function(){

	let DefaultTpl = 
		'<div class="head"><span>{{title}}</span></div>' +
			'<div class="menu-items">' + 
				'{{#items}}<div class="menu-item" data-remove-on-select="{{removeOnSelect}}" data-value="{{value}}">{{label}}</div>{{/items}}' +
			'</div>'+
		'</div>'
	;

	let DefaultWithTypeAndCountTpl = 
		'<div class="head"><span>{{title}}</span></div>' +
			'<div class="menu-items">' + 
				'{{#items}}<div class="menu-item" data-value="{{value}}" data-remove-on-select="{{removeOnSelect}}" data-type="{{type}}" data-count="{{count}}">{{label}}</div>{{/items}}' +
			'</div>'+
		'</div>'
	;

	let CustomersTpl = 
		'<thead>' +
			'<tr>' +
				'<td>Client</td>' +
				'<td>Solde</td>' +
				'<td>Actions</td>' +
			'</tr>' +
		'</thead>' +
		'<tbody>' +
		'{{#customers}}' +
			'<tr>' +
				'<td>{{name}}</td>' +
				'<td>${{bank_savings}}</td>' +
				'<td>' +
					'<button class="transfer-btn" data-identifier="{{identifier}}">Transfer</button>' +
					'<button class="withdraw-btn" data-identifier="{{identifier}}">Withdrawal</button>' +
				'</td>' +
			'</tr>' +
		'{{/customers}}' +
		'</tbody>'
	;

	let menus = {

		banque : {
		  title     : 'Bank',
		 	visible   : false,
		 	current   : -1,
		 	hasControl: false,
		 	template  : DefaultTpl,

		  items: [
		  	{label: 'Clients',                value: 'customers'},
		  	{label: 'Withdraw Company Money', value: 'withdraw_society_money'},
		  	{label: 'Launder Money',  value: 'wash_money'}
		  ]
		},

		banque_actions : {
		  title     : 'Bank',
		 	visible   : false,
		 	current   : 0,
		 	hasControl: true,
		 	template  : DefaultTpl,

		  items: []
		},
	}

	let renderMenus = function(){
		for(let k in menus){

			let elem = $('#menu_' + k);

			elem.html(Mustache.render(menus[k].template, menus[k]));

			if(menus[k].visible)
				elem.show();
			else
				elem.hide();

		}
	}

	let showMenu = function(menu){

		currentMenu = menu;

		for(let k in menus)
			menus[k].visible = false;

		menus[menu].visible = true;

		renderMenus();

		if(menus[currentMenu].items.length > 0){

			$('#menu_' + currentMenu + ' .menu-item').removeClass('selected');
			$('#menu_' + currentMenu + ' .menu-item:eq(0)').addClass('selected');

			menus[currentMenu].current = 0;
			currentVal                 = menus[currentMenu].items[menus[currentMenu].current].value;
			currentType                = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('type');
			currentAction              = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('action');
			currentCount               = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('count');
		}

		$('#ctl_return').show();

		isMenuOpen        = true
		isShowingControls = false
	}

	let hideMenus = function(){
		
		for(let k in menus)
			menus[k].visible = false;

		renderMenus();
		isMenuOpen = false;
	}

	let showControl = function(control){

		hideControls();
		$('#ctl_' + control).show();
		isShowingControls = true;
		currentControl    = control;
	}

	let hideControls = function(){

		for(let k in menus)
			$('#ctl_' + k).hide();

		$('#ctl_return').hide();

		isShowingControls = false;
	}

	let showCustomers = function(customers, bankMoney){

		let view = {
			customers: customers
		}

		$('#bank-money').text('$' + bankMoney)
		$('#customer-list').html(Mustache.render(CustomersTpl, view));

		$('#customer-list .transfer-btn').click(function(){
			showTransferDialog($(this).data('identifier'))
		});

		$('#customer-list .withdraw-btn').click(function(){
			showWithdrawBankSavingsDialog($(this).data('identifier'))
		});

		$('#customers').show();
		$(cursor).show();
	}

	let hideCustomers = function(){
		$('#customers').hide();
		$(cursor).hide();
	}

	let showTransferDialog = function(identifier){
		$('#transfer-dialog-amount').val('');
		$('#transfer-dialog-identifier').val(identifier);
		$('#transfer-dialog').show();
	}

	let hideTransferDialog = function(){
		$('#transfer-dialog').hide();
	}

	let showWithdrawBankSavingsDialog = function(identifier){
		$('#withdraw-bank-savings-dialog-amount').val('');
		$('#withdraw-bank-savings-dialog-identifier').val(identifier);
		$('#withdraw-bank-savings-dialog').show();
	}

	let hideWithdrawBankSavingsDialog = function(){
		$('#withdraw-bank-savings-dialog').hide();
	}

	let showBillingDialog = function(){
		$('#billing-dialog-amount').val('');
		$('#billing-dialog').show();
		$(cursor).show();
	}

	let hideBillingDialog = function(){
		$('#billing-dialog').hide();
		$(cursor).hide();
	}

	let showWithdrawDialog = function(){
		$('#withdraw-dialog-amount').val('');
		$('#withdraw-dialog').show();
		$(cursor).show();
	}

	let hideWithdrawDialog = function(){
		$('#withdraw-dialog').hide();
		$(cursor).hide();
	}

	let showWashMoneyDialog = function(){
		$('#washmoney-dialog-amount').val('');
		$('#washmoney-dialog').show();
		$(cursor).show();
	}

	let hideWashMoneyDialog = function(){
		$('#washmoney-dialog').hide();
		$(cursor).hide();
	}

	let showWithdrawSocietyMoneyDialog = function(){
		$('#withdraw-society-money-dialog-amount').val('');
		$('#withdraw-society-money-dialog').show();
		$(cursor).show();
	}

	let hideWithdrawSocietyMoneyDialog = function(){
		$('#withdraw-society-money-dialog').hide();
		$(cursor).hide();	
	}

	$('#transfer-dialog-send').click(function(){

		$.post('http://esx_bankerjob/transfer', JSON.stringify({
			identifier: $('#transfer-dialog-identifier').val(),
			amount    : parseFloat($('#transfer-dialog-amount').val())
		}))

		hideTransferDialog();

	});

	$('#withdraw-bank-savings-dialog-send').click(function(){

		$.post('http://esx_bankerjob/withdraw_bank_savings', JSON.stringify({
			identifier: $('#withdraw-bank-savings-dialog-identifier').val(),
			amount    : parseFloat($('#withdraw-bank-savings-dialog-amount').val())
		}))

		hideWithdrawBankSavingsDialog();

	});

	$('#billing-dialog-send').click(function(){

		$.post('http://esx_bankerjob/billing', JSON.stringify({
			amount: parseFloat($('#billing-dialog-amount').val())
		}))

		hideBillingDialog();

	});

	$('#withdraw-dialog-send').click(function(){

		$.post('http://esx_bankerjob/withdraw', JSON.stringify({
			amount: parseFloat($('#withdraw-dialog-amount').val())
		}))

		hideWithdrawDialog();

	});

	$('#washmoney-dialog-send').click(function(){

		$.post('http://esx_bankerjob/wash_money', JSON.stringify({
			amount: parseFloat($('#washmoney-dialog-amount').val())
		}))

		hideWashMoneyDialog();

	});

	$('#withdraw-society-money-dialog-send').click(function(){
		$.post('http://esx_bankerjob/withdraw_society_money', JSON.stringify({
			amount: parseFloat($('#withdraw-society-money-dialog-amount').val())
		}))

		hideWithdrawSocietyMoneyDialog();
	});

	let documentWidth  = document.documentElement.clientWidth;
	let documentHeight = document.documentElement.clientHeight;

	let cursor  = document.getElementById("cursor");
	let cursorX = documentWidth  / 2;
	let cursorY = documentHeight / 2;

	function UpdateCursorPos() {
    cursor.style.left = cursorX;
    cursor.style.top  = cursorY;
	}

	function Click(x, y) {
    let element = $(document.elementFromPoint(x, y));
    element.focus().click();
	}

	function scrollCustomers(direction){

		let element = $('#customers .head-content')[0];

		if(direction == 'UP')
			element.scrollTop -= 32;

		if(direction == 'DOWN')
			element.scrollTop += 32;

	}

  $(document).mousemove(function(event) {
    cursorX = event.pageX;
    cursorY = event.pageY;
    UpdateCursorPos();
  });

	let isMenuOpen           = false
	let isShowingControls    = false;
	let currentMenu          = null;
	let currentControl       = null;
	let currentVal           = null;
	let currentType          = null;
	let currentAction        = null;
	let currentCount         = null;
	
	renderMenus();

	window.onData = function(data){

		if(data.click === true){
			Click(cursorX - 1, cursorY - 1);
		}

		if(data.showControls === true){
			currentMenu = data.controls;
			showControl(data.controls);
		}

		if(data.showControls === false){
			hideControls();
		}

		if(data.showMenu === true){
			hideControls();

			if(data.items)
				menus[data.menu].items = data.items

			showMenu(data.menu);
		}

		if(data.showMenu === false){
			hideMenus();
		}

		if(data.showCustomers === true){
			showCustomers(data.customers, data.bankMoney);
		}

		if(data.showCustomers === false){
			hideCustomers();
		}

		if(data.showBillingDialog === true){
			showBillingDialog();
		}

		if(data.showBillingDialog === false){
			hideBillingDialog();
		}

		if(data.showWithdrawDialog === true){
			showWithdrawDialog();
		}

		if(data.showWithdrawDialog === false){
			hideWithdrawDialog();
		}

		if(data.showWashMoneyDialog === true){
			showWashMoneyDialog();
		}

		if(data.showWashMoneyDialog === false){
			hideWashMoneyDialog();
		}

		if(data.showWithdrawSocietyMoneyDialog === true){
			showWithdrawSocietyMoneyDialog();
		}

		if(data.showWithdrawSocietyMoneyDialog === false){
			hideWithdrawSocietyMoneyDialog();
		}

		if(data.move && isMenuOpen){

			if(data.move == 'UP'){
				if(menus[currentMenu].current > 0)
					menus[currentMenu].current--;
			}

			if(data.move == 'DOWN'){
				
				let max = $('#menu_' + currentMenu + ' .menu-item').length;

				if(menus[currentMenu].current < max - 1)
					menus[currentMenu].current++;
			}

			$('#menu_' + currentMenu + ' .menu-item').removeClass('selected');
			$('#menu_' + currentMenu + ' .menu-item:eq(' + menus[currentMenu].current + ')').addClass('selected');

			currentVal    = menus[currentMenu].items[menus[currentMenu].current].value;
			currentType   = $('#menu_' + currentMenu + ' .menu-item:eq(' + menus[currentMenu].current + ')').data('type');
			currentAction = $('#menu_' + currentMenu + ' .menu-item:eq(' + menus[currentMenu].current + ')').data('action');
			currentCount  = $('#menu_' + currentMenu + ' .menu-item:eq(' + menus[currentMenu].current + ')').data('count');
		}

		if(data.enterPressed){

			if(isShowingControls){

				$.post('http://esx_bankerjob/select_control', JSON.stringify({
					control: currentControl,
				}))

				hideControls();
				showMenu(currentMenu);
			
			} else if(isMenuOpen) {		

				if(menus[currentMenu].current != -1){
					$.post('http://esx_bankerjob/select', JSON.stringify({
						menu  : currentMenu,
						val   : currentVal,
						type  : currentType,
						action: currentAction,
						count : currentCount
					}))
				}

				let elem = $('#menu_' + currentMenu + ' .menu-item.selected')

				if(elem.data('remove-on-select') == true){
					
					elem.remove();

					menus[currentMenu].items.splice(menus[currentMenu].current, 1)
					menus[currentMenu].current = 0;

					$('#menu_' + currentMenu + ' .menu-item').removeClass('selected');
					$('#menu_' + currentMenu + ' .menu-item:eq(0)').addClass('selected');
					
					currentVal    = menus[currentMenu].items[0].value;
					currentType   = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('type');
					currentAction = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('action');
					currentCount  = $('#menu_' + currentMenu + ' .menu-item:eq(0)').data('count');
				}

			} 

		}

		if(data.backspacePressed){

			if(isMenuOpen && currentMenu == 'banque'){
				hideMenus();
				$('#ctl_return').hide();
				showControl('banque');
			}

			if(isMenuOpen && currentMenu == 'banque_actions'){
				hideMenus();
				$('#ctl_return').hide();
			}

		}
	}

  document.onkeyup = function (data) {
    if (data.which == 27) {
      $.post('http://esx_bankerjob/escape', '{}');
    }
  };

  document.onwheel = function (data) {

    if (data.deltaY < 0) {
      scrollCustomers('UP');
    }

    if (data.deltaY > 0) {
      scrollCustomers('DOWN');
    }

  };

	$('form').submit(function(){
		return false;
	});

	window.onload = function(e){ window.addEventListener('message', function(event){ onData(event.data) }); }

})()