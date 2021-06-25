(function(){
	
	let ContactTpl = 
		'<div class="contact {{online}}">' +
			'<div class="sender-info">' +
				'<div class="center">' +
					'<span class="sender">{{sender}}</span><br/><span class="phone-number">#{{phoneNumber}}</span>' +
				'</div>' +
			'</div>' +
			'<div class="actions">' +
				'<span class="del-contact" data-contact-number="{{phoneNumberData}}" data-contact-name="{{senderData}}">X</span>' +
				'<span class="new-msg newMsg-btn" data-contact-number="{{phoneNumberData}}" data-contact-name="{{senderData}}"></span>' +
			'</div>' +
		'</div>'
	;
	
	let MessageTpl = 
		'<div class="message">' +
			'<div class="sender-info">' +
				'<div class="center">' +
					'<span class="sender">{{sender}}</span><br/><span class="phone-number">#{{phoneNumber}}</span>' +
				'</div>' + 
			'</div>' + 
			'<div class="body">{{message}}</div>' + 
			'<div class="actions"><span class="new-msg {{anonyme}} reply-btn" data-contact-number="{{phoneNumberData}}" data-contact-name="{{senderData}}"></span><span class="gps {{activeGPS}} gps-btn" data-gpsX="{{gpsLocationX}}" data-gpsY="{{gpsLocationY}}"></span><span class="ok-btn {{showOK}}" data-contact-number="{{okNumberData}}" data-contact-job="{{jobData}}"></span></div>' +
		'</div>'
	;

	let SpecialContactTpl = '<li class="phone-icon" style="background-image: url(\'{{base64Icon}}\');" data-number="{{number}}" data-name="{{name}}">{{name}}</li>';

	let contacts            = [];
	let specialContacts     = [];
	let menu                = [];
	let currentItem         = 0;
	let currentVal          = null;
	let isMessageEditorOpen = false;
	let isMessagesOpen      = false;
	let isPhoneShowed       = false;
	
	let showMain = function() {
		$('.screen').removeClass('active');
		$('.screen *').attr('disabled', 'disabled');
	}
	
	let showRepertoire = function() {
		$('#repertoire').addClass('active');
	}
	
	let hideRepertoire = function() {
		$('#repertoire').removeClass('active');
	}
	
	let showMessages = function(){	
		$('#messages').addClass('active');
		isMessagesOpen = true;
	}

	let hideMessages = function(){		
		$('#messages').removeClass('active');
		isMessagesOpen = false;
	}
	
	let showAddContact = function() {
		$('#contact').addClass('active');
		$('.screen *').attr('disabled', 'disabled');
		$('.screen.active *').removeAttr('disabled');
	}
	
	let hideAddContact = function() {
		$('#contact').removeClass('active');
		$('#contact_name').val('');
		$('#contact_number').val('');
	}
	
	let showNewMessage = function(cnum, cname) {
		$('#writer').addClass('active');
		$('#writer_number').val(cnum);
		$('#writer .header-title').html(cname);
		$('.screen *').attr('disabled', 'disabled');
		$('.screen.active *').removeAttr('disabled');
	}

	let hideNewMessage = function() {		
		$('#writer').removeClass('active');
		$('#writer_number').val('');
		$('#writer_message').val('');
		$('#writer .header-title').html('');
	}
	
	let showGPS = function(xPos, yPos) {
		$.post('http://esx_phone/setGPS', JSON.stringify({
			x: parseFloat(xPos),
			y: parseFloat(yPos)
		}
		));
	}

	let renderContacts = function(){
		
		let contactHTML = '';
		
		if(contacts.length > 0) {

			for(let i=0; i<contacts.length; i++) {
				
				let view = {
					phoneNumber    : contacts[i].value,
					sender         : contacts[i].label,
					phoneNumberData: contacts[i].value,
					senderData     : contacts[i].label,
					online         : contacts[i].online  ? 'online' : '',
					anonyme        : contacts[i].anonyme ? 'online' : ''
				}

				let html = Mustache.render(ContactTpl, view);

				contactHTML += html;
			}

		} else {
			contactHTML = '<div class="contact no-item online"><p class="no-item">No contacts</p></div>';
		}
		
		$('#phone #repertoire .repertoire-list').html(contactHTML);

		$('.contact .del-contact').click(function() {
			let name = $(this).attr('data-contact-name');
			let phoneNumber = $(this).attr('data-contact-number');

			$.post('http://esx_phone/remove_contact', JSON.stringify({
				contactName: name,
				phoneNumber: phoneNumber
			}))
		});
	
		$('.contact.online .new-msg').click(function() {
			showNewMessage($(this).attr('data-contact-number'), $(this).attr('data-contact-name'));
		});
		
	}
	
	$('.contact.online .new-msg').click(function() {
		showNewMessage($(this).attr('data-contact-number'));
	});

	let reloadPhone = function(phoneData){

		contacts = [];

		for(let i=0; i<phoneData.contacts.length; i++){
			contacts.push({
				label : phoneData.contacts[i].name,
				value : phoneData.contacts[i].number,
				online: phoneData.contacts[i].online
			})
		}

		renderContacts();

		$('#phone-number').text('#' + phoneData.phoneNumber);
	}

	let showPhone = function(phoneData){
		reloadPhone(phoneData);
		$('#phone').show();
		showMain();
		isPhoneShowed = true;
	}

	let hidePhone = function(){		
		$('#phone').hide();
		isPhoneShowed = false;
	}
	
	let messages = [];

	let addMessage = function(phoneNumber, pmessage, pposition, panonyme, pjob){
		
		messages.push({
			value   : phoneNumber,
			message : pmessage,
			position: pposition,
			anonyme : panonyme,
			job     : pjob
		})

		let messageHTML = '';
		
		if(messages.length >  0) {
			
			for(let i=0; i<messages.length; i++) {

				let fromName   = "Unknown";
				let fromNumber = messages[i].value;
				let anonyme    = null;
				
				if(messages[i].job != "player")
					fromName = messages[i].job;

				if(messages[i].anonyme) {
					
					if(messages[i].job == "player")
						fromName = "Anonymous";

					fromNumber = "Anonymous";
					anonyme    = 'anonyme';

				} else {

					for(let j=0; j<contacts.length; j++)
						if(contacts[j].value == messages[i].value)
							if(messages[i].job == "player")
								fromName = contacts[j].label;

					anonyme = '';
				}
				
				let view = {
					anonyme        : anonyme,
					phoneNumber    : fromNumber,
					sender         : fromName,
					message        : messages[i].message,
					phoneNumberData: fromNumber,
					senderData     : fromName,
					okNumberData   : fromNumber,
					gpsLocationX   : (messages[i].job == 'player') ? '' : messages[i].position.x,
					gpsLocationY   : (messages[i].job == 'player') ? '' : messages[i].position.y,
					activeGPS      : (messages[i].job == 'player') ? '' : (messages[i].position) ? 'active' : '',
					jobData        : (messages[i].job == 'player') ? '' : messages[i].job,
					showOK         : (messages[i].job == 'player') ? '' : 'showOK'
				}
				
				let html = Mustache.render(MessageTpl, view);

				messageHTML = html + messageHTML;
			}
		} else {
			messageHTML = '<div class="message no-item"><p class="no-item">No messages</p></div>';
		}
		
		$('#phone #messages .messages-list').html(messageHTML);
		
		$('.message .new-msg').click(function() {
			showNewMessage($(this).attr('data-contact-number'), $(this).attr('data-contact-name'));
		});
		
		$('.message .gps').click(function() {
			showGPS($(this).attr('data-gpsX'), $(this).attr('data-gpsY'));
		});
		
		$('.message .ok-btn').click(function() {
			$.post('http://esx_phone/send', JSON.stringify({
				message: $(this).attr('data-contact-job') + ": Received!",
				number : $(this).attr('data-contact-number'),
				anonyme: false
			}))
		});
	}

	let scrollMessages = function(direction){

		let element = $('#messages .container')[0];

		if(direction == 'UP')
			element.scrollTop -= 100;

		if(direction == 'DOWN')
			element.scrollTop += 100;
	}

	let addSpecialContact = function(name, number, base64Icon){
		
		let found = false

		for(let i=0; i<specialContacts.length; i++)
			if(specialContacts[i].number == number)
				found = true;

		if(!found){

			specialContacts.push({
				name      : name,
				number    : number,
				base64Icon: base64Icon
			});

			specialContacts.sort((a,b) => {
				return a.name.localeCompare(b.name);
			});

			renderSpecialContacts();

		}

	}

	let removeSpecialContact = function(number){

		for(let i=0; i<specialContacts.length; i++){
			if(specialContacts[i].number == number){
				specialContacts.splice(i, 1);
				break;
			}
		}

		renderSpecialContacts();

	}

	let renderSpecialContacts = function(){

		$('.phone-icon').unbind('click');

		$('#phone .menu .home').html(
			'<li class="phone-icon" id="phone-icon-rep">Contacts</li>' +
			'<li class="phone-icon" id="phone-icon-msg">Messages</li>'
		);

		for(let i=0; i<specialContacts.length; i++){
			let elem = $(Mustache.render(SpecialContactTpl, specialContacts[i]));
			$('#phone .menu .home').append(elem);
		}

		$('.phone-icon').click(function(event) {

			let id = $(this).attr('id');

			switch(id) {

				case 'phone-icon-rep' : {
					showRepertoire();
					break;
				}

				case 'phone-icon-msg' : {
					showMessages();
					break;
				}

				default : {
					
					let number = $(this).data('number');
					let name   = $(this).data('name');

					showNewMessage(number, name);

					break;
				}
			}

		});
	}

	$('#writer_send').click(function(){
		
		let phoneNumber = null
		
		if(typeof $('#writer_number').val() == 'number')
			phoneNumber = parseInt($('#writer_number').val());
		else if (typeof $('#writer_number').val() == 'string')
			phoneNumber = $('#writer_number').val();

		$.post('http://esx_phone/send', JSON.stringify({
			message: $('#writer_message').val(),
			number : phoneNumber,
			anonyme: $('#writer_anonyme').is(':checked')
		}))

	});

	$('#contact_send').click(function(){

		$.post('http://esx_phone/add_contact', JSON.stringify({
			contactName: $('#contact_name').val(),
			phoneNumber: $('#contact_number').val()
		}))

	});

	// ACTIONS BTNS
	$('#btn-head-back-msg').click(function() {
		hideNewMessage();
		hideMessages();
	});
	
	$('#btn-head-back-rep').click(function() {
		hideRepertoire();
	});
	
	$('#btn-head-back-writer, #writer_cancel').click(function() {
		hideNewMessage();
	});
	
	$('#btn-head-back-contact, #contact_cancel').click(function() {
		hideAddContact();
	});
	
	$('#btn-head-new-message').click(function() {
		showNewMessage('', 'New message');
	});
	
	$('#btn-head-new-contact').click(function() {
		showAddContact();
	});

	$('.phone-icon').click(function(event) {

		let id = $(this).attr('id');

		switch(id) {

			case 'phone-icon-rep' : {
				showRepertoire();
				break;
			}

			case 'phone-icon-msg' : {
				showMessages();
				break;
			}

			default : {
				
				let number = $(this).data('number');
				let name   = $(this).data('name');

				showNewMessage(number, name);

				break;
			}
		}

	});

	window.onData = function(data){

		if(data.scroll === true){
			if(isMessagesOpen)
				scrollMessages(data.direction);
		}

		if(data.reloadPhone === true){
			reloadPhone(data.phoneData);
		}

		if(data.showPhone === true){
			showPhone(data.phoneData);
		}

		if(data.showPhone === false){
			hidePhone();
		}

		if(data.showMessageEditor === false){
			hideNewMessage();
		}

		if(data.newMessage === true){
			addMessage(data.phoneNumber, data.message, data.position, data.anonyme, data.job);
		}

		if(data.contactAdded === true){
			reloadPhone(data.phoneData);
			hideAddContact();
		}

		if(data.contactRemoved === true){
			reloadPhone(data.phoneData);
		}
		
		if(data.addSpecialContact === true){
			addSpecialContact(data.name, data.number, data.base64Icon);
		}

		if(data.removeSpecialContact === true){
			removeSpecialContact(data.number);
		}

		if(data.move && isPhoneShowed){

			if(data.move == 'UP'){
				scroll('UP');
			}

			if(data.move == 'DOWN'){
				scroll('DOWN');
			}
		}

		if(data.enterPressed){

			if(isPhoneShowed) {

				$.post('http://esx_phone/select', JSON.stringify({
					val  : currentVal
				}));

			}

		}

	}

	window.onload = function(e){
		window.addEventListener('message', function(event) {
			onData(event.data)
		});
	}

	document.onkeydown = function (data) {
		if ((data.which == 120 || data.which == 27) && isPhoneShowed) { // || data.which == 8
			$.post('http://esx_phone/escape');
		}
	};

})();
