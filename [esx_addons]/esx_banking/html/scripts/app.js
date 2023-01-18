var LOADED = true
class Components{
	static allComponents = []
	static generateAllComponents(generatedData,generateType = "bank"){
		$("#wrapper").empty()
		generatedData.forEach((form)=>{
			let objData = {}
			if(form.elementID.substring(1) == "transfer" && generateType == "bank"){
				objData = new MultiComponentsForm(form)
			}else if(form.componentName == "trans" && generateType == "bank"){
				objData = this.generateTransactionContainer(form)
			}
			else if(form.componentName == "pincodePanel" && generateType == "atm"){
				objData = this.generatePincodeContainer(form)
			}
			else if(form.componentName == "moreGraph" && generateType == "bank"){
				objData = this.generateMainTemplate(form)
				this.generateMenuTemplate(form)
			}
			else if(form.componentName == "atmComponent" && generateType == "atm"){
				objData = this.generateAtmTemplate(form)
			}
			else{
				if(generateType == "bank"){
					if(form.componentName == "pincodePanel" || form.componentName == "atmComponent"){
						return
					}
				}
				else if(generateType == "atm"){
					if(form.componentName == "trans" || form.componentName == "moreGraph"){
						return
					}
				}
				objData = new SingleComponentsForm(form)
			}
			if(form.componentName != undefined){
				this.allComponents[form.componentName] = objData
			}else{
				this.allComponents[form.elementID.substring(1)] = objData
			}
		})
	}

	static getComponent(componentName){
		if(this.allComponents[componentName] != undefined){
			return this.allComponents[componentName]
		}
		return false
	}

	static loader(appendedDiv, state){
		$(appendedDiv).empty()
		if(state == "show"){
			$(appendedDiv).append(`
			<svg class="circular-loader" viewBox="25 25 50 50">
				<circle class="loader-path" cx="50" cy="50" r="20"></circle>
			</svg>`);
			$(appendedDiv).fadeIn(200)
			LOADED = true


			setTimeout(() => {
				$(`${appendedDiv}`).fadeOut(200)
				$("#wrapper").fadeIn().css("display","flex");
				if(appendedDiv == ".loader") $("#container").fadeIn().css("display","flex")
				LOADED = false
			}, 2500);
		}else if(state == "hide"){
			$(`${appendedDiv}`).fadeOut(200)
			if(appendedDiv == ".loader"){
				$("#wrapper").fadeOut(200)
				$("#container").fadeOut(200)
			} 
		}
	}

	static generateTransactionContainer(formData){
		$(formData.elementID).empty()
	return	$(formData.elementID).html(`<h3>${formData.title}</h3>
		<p>${formData.description}</p>
		<div id="graph-container">
			<canvas id="smallGraph" width="400" height="400"></canvas>
		</div>
		<div id="buttons-container">
			<button class="accept-button" id="more_history">${formData.moreHistoryText}</button>
			<button class="accept-button" id="more_graph">${formData.moreGraphText}</button>
		</div>
		<div id="transactions-container"></div>`);
	}

	static generatePincodeContainer(formData){
	return	$(formData.elementID).append(`
				<div id="pincode-container">
					<div id="pincode-panel">
						<h4>${formData.title}</h4>
						<div class="pincode-input"></div>
						<div class="pincode-numbers">
							<div class="deleteButton">${formData.deleteButtonText}</div>
							<div>${formData.loginButtonText}</div>
						</div>
						<div class="button-groups">
							<button class="pin-button exit-button">${formData.closeButtonText}</button>
						</div>
					</div>
				</div>`);
		
	}
	
	static generateMainTemplate(formData){
		return	$(formData.elementID).append(`
			<div id="container">
					<div id="modal-container">
						<div id="title-container">
							<h3>${formData.title}</h3>
							<button id="close-button">${formData.closeButtonText}</button>
						</div>
						<div id="more-modal-container"></div>
					</div>
			</div>`);
	}

	static generateMenuTemplate(formData){
		$("#container").append(`
			<div id="menu">
				<div id="first-column">

					<h3>${formData.bankTitle}</h3>
					<div id="bankcard"></div>

					<div id="your-money-panel"></div>

					<div id="info-panel">
						<div id="cpincode"></div>
					</div>
					<hr>
					<button class="exit-button">${formData.mainExitButtonText}</button>

				</div>

				<div id="second-column">
					<div id="withdraw"></div>

					<div id="deposit"></div>

					<div id="transfer"></div>
				</div>

				<div id="third-column">
					<div id="transactions-container"></div>
				</div>
			</div>`);
	}

	static generateAtmTemplate(formData){
		$(formData.elementID).append(`
			<div id="atm-container">
				<div class="firstGridColumn">
					<h3>${formData.title}</h3>
					<div id="bankcard"></div>
					<div id="your-money-panel"></div>
					<hr>
					<button class="exit-button">${formData.closeButtonText}</button>
				</div>
				<div class="secondGridColumn"></div>
			</div>
		`);

		return $(`${formData.elementID} #atm-container`)
	}

}

class SingleComponentsForm {
	elementID = ""
	buttonText = ""
	inputPlaceholder = ""
	title = ""
	description = ""
	type = "number"
	template = ""
	name = ""

	constructor(form){
		this.elementID = form.elementID
		this.buttonText = form.buttonText
		this.inputPlaceholder = form.inputPlaceholder
		this.title = form.title
		this.description = form.description
		this.type = form.type
		this.name = form.name
		this.renderInputAndButton()
	}

	setElementId(newElementID){
		this.elementID = newElementID
	}

	renderInputAndButton(){

		this.template = `<h3>${this.title}</h3><p>${this.description}</p>`;

		if(this.type == "password"){
			this.template += `<input type="password" name="pincode" pattern="/^-?\d+\.?\d*$/" onKeyPress="if(this.value.length==4) return false;" placeholder="${this.inputPlaceholder}">`
		}
		else{
			this.template += `<input type="number" name="${this.name}" pattern="/^-?\d+\.?\d*$/" placeholder="${this.inputPlaceholder}">`
		}

		this.template += `<button class="accept-button disable-button" disabled>
					<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path d="M20.285 2l-11.285 11.567-5.286-5.011-3.714 3.716 9 8.728 15-15.285z"/></svg>
					${this.buttonText}</button>`;

		$(this.elementID).append(`<div>${this.template}</div>`);
	}

	show(){
		$(this.elementID).fadeIn();
	}

	hide(){
		$(this.elementID).fadeOut();
	}
}

class MultiComponentsForm {
	elementID = ""
	buttonText = ""
	inputPlaceholder = ""
	inputPlaceholder2 = ""
	title = ""
	description = ""

	constructor(form){
		this.elementID = form.elementID
		this.buttonText = form.buttonText
		this.inputPlaceholder = form.inputPlaceholder
		this.inputPlaceholder2 = form.inputPlaceholder2
		this.title = form.title
		this.description = form.description
		this.renderInputAndButtonGroups()
	}

	renderInputAndButtonGroups(){
		$(this.elementID).html(`<h3>${this.title}</h3>
		<p>${this.description}</p>
		<div class="input-groups-container">
			<input type="number" name="moneyAmount" placeholder="${this.inputPlaceholder}">
			<input type="number" name="playerId" placeholder="${this.inputPlaceholder2}">
			<button class="accept-button disable-button" disabled>
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path d="M20.285 2l-11.285 11.567-5.286-5.011-3.714 3.716 9 8.728 15-15.285z"/></svg>
				${this.buttonText}
			</button>
		</div>`);
	}

	show(){
		$(this.elementID).fadeIn();
	}

	hide(){
		$(this.elementID).fadeOut();
	}
}

class Render {
	fullRenderData = {}
	elementID = ""
	language = ""
	constructor(elementID){
		this.elementID = elementID
	}
	renderBankCard(){
		const bankData =  this.fullRenderData
		$("#bankcard").empty();
		let template = `<div class="title">
		<h3>${bankData.bankName}</h3>
		<svg id="bank-svg" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="11445.527 -3691.757 35 25">
			<defs>
			<style>
				.cls-1 {
				fill: orange;
				}
		
				.cls-1, .cls-3 {
				stroke: #6c7679;
				}
		
				.cls-2 {
				clip-path: url(#clip-path);
				}
		
				.cls-3, .cls-5 {
				fill: none;
				}
		
				.cls-4 {
				stroke: none;
				}
			</style>
			<clipPath id="clip-path">
				<rect id="Rectangle_13866" data-name="Rectangle 13866" class="cls-1" width="35" height="25" rx="2"/>
			</clipPath>
			</defs>
			<g id="Group_11188" data-name="Group 11188" transform="translate(11445.527 -3691.757)">
			<g id="Mask_Group_274" data-name="Mask Group 274" class="cls-2">
				<g id="Group_11186" data-name="Group 11186" transform="translate(-1.4 -5.405)">
				<g id="Rectangle_13856" data-name="Rectangle 13856" class="cls-1" transform="translate(1.4 5.405)">
					<rect class="cls-4" width="35" height="25" rx="5"/>
					<rect class="cls-5" x="0.5" y="0.5" width="34" height="24" rx="4.5"/>
				</g>
				<g id="Rectangle_13857" data-name="Rectangle 13857" class="cls-1" transform="translate(0 18.919)">
					<path class="cls-4" d="M3.243,0h7.07A6.486,6.486,0,0,1,16.8,6.486v0a9.73,9.73,0,0,1-9.73,9.73H3.243A3.243,3.243,0,0,1,0,12.973V3.243A3.243,3.243,0,0,1,3.243,0Z"/>
					<path class="cls-5" d="M3.353.5h6.924A6.023,6.023,0,0,1,16.3,6.523v0a9.193,9.193,0,0,1-9.193,9.193H3.353A2.853,2.853,0,0,1,.5,12.863V3.353A2.853,2.853,0,0,1,3.353.5Z"/>
				</g>
				<g id="Rectangle_13858" data-name="Rectangle 13858" class="cls-1" transform="translate(37.8 16.216) rotate(180)">
					<path class="cls-4" d="M3.243,0h7.07A6.486,6.486,0,0,1,16.8,6.486v0a9.73,9.73,0,0,1-9.73,9.73H3.243A3.243,3.243,0,0,1,0,12.973V3.243A3.243,3.243,0,0,1,3.243,0Z"/>
					<path class="cls-5" d="M3.353.5h6.924A6.023,6.023,0,0,1,16.3,6.523v0a9.193,9.193,0,0,1-9.193,9.193H3.353A2.853,2.853,0,0,1,.5,12.863V3.353A2.853,2.853,0,0,1,3.353.5Z"/>
				</g>
				<g id="Rectangle_13859" data-name="Rectangle 13859" class="cls-1">
					<path class="cls-4" d="M3.243,0H7.07A9.73,9.73,0,0,1,16.8,9.73v0a6.486,6.486,0,0,1-6.486,6.486H3.243A3.243,3.243,0,0,1,0,12.973V3.243A3.243,3.243,0,0,1,3.243,0Z"/>
					<path class="cls-5" d="M3.353.5H7.107A9.193,9.193,0,0,1,16.3,9.693v0a6.023,6.023,0,0,1-6.023,6.023H3.353A2.853,2.853,0,0,1,.5,12.863V3.353A2.853,2.853,0,0,1,3.353.5Z"/>
				</g>
				<g id="Rectangle_13860" data-name="Rectangle 13860" class="cls-1" transform="translate(37.8 35.135) rotate(180)">
					<path class="cls-4" d="M3.243,0H7.07A9.73,9.73,0,0,1,16.8,9.73v0a6.486,6.486,0,0,1-6.486,6.486H3.243A3.243,3.243,0,0,1,0,12.973V3.243A3.243,3.243,0,0,1,3.243,0Z"/>
					<path class="cls-5" d="M3.353.5H7.107A9.193,9.193,0,0,1,16.3,9.693v0a6.023,6.023,0,0,1-6.023,6.023H3.353A2.853,2.853,0,0,1,.5,12.863V3.353A2.853,2.853,0,0,1,3.353.5Z"/>
				</g>
				<line id="Line_737" data-name="Line 737" class="cls-3" y2="3.378" transform="translate(11.55 15.878)"/>
				<line id="Line_738" data-name="Line 738" class="cls-3" y2="3.378" transform="translate(26.25 15.878)"/>
				</g>
				<g id="Group_11187" data-name="Group 11187" transform="translate(-1.4 -5.405)">
				<g id="Rectangle_13861" data-name="Rectangle 13861" class="cls-1" transform="translate(1.4 5.405)">
					<rect class="cls-4" width="35" height="25" rx="5"/>
					<rect class="cls-5" x="0.5" y="0.5" width="34" height="24" rx="4.5"/>
				</g>
				<g id="Rectangle_13862" data-name="Rectangle 13862" class="cls-1" transform="translate(0 18.919)">
					<path class="cls-4" d="M3.243,0h7.07A6.486,6.486,0,0,1,16.8,6.486v0a9.73,9.73,0,0,1-9.73,9.73H3.243A3.243,3.243,0,0,1,0,12.973V3.243A3.243,3.243,0,0,1,3.243,0Z"/>
					<path class="cls-5" d="M3.353.5h6.924A6.023,6.023,0,0,1,16.3,6.523v0a9.193,9.193,0,0,1-9.193,9.193H3.353A2.853,2.853,0,0,1,.5,12.863V3.353A2.853,2.853,0,0,1,3.353.5Z"/>
				</g>
				<g id="Rectangle_13863" data-name="Rectangle 13863" class="cls-1" transform="translate(37.8 16.216) rotate(180)">
					<path class="cls-4" d="M3.243,0h7.07A6.486,6.486,0,0,1,16.8,6.486v0a9.73,9.73,0,0,1-9.73,9.73H3.243A3.243,3.243,0,0,1,0,12.973V3.243A3.243,3.243,0,0,1,3.243,0Z"/>
					<path class="cls-5" d="M3.353.5h6.924A6.023,6.023,0,0,1,16.3,6.523v0a9.193,9.193,0,0,1-9.193,9.193H3.353A2.853,2.853,0,0,1,.5,12.863V3.353A2.853,2.853,0,0,1,3.353.5Z"/>
				</g>
				<g id="Rectangle_13864" data-name="Rectangle 13864" class="cls-1">
					<rect class="cls-4" width="16.8" height="16.216" rx="3"/>
					<rect class="cls-5" x="0.5" y="0.5" width="15.8" height="15.216" rx="2.5"/>
				</g>
				<g id="Rectangle_13865" data-name="Rectangle 13865" class="cls-1" transform="translate(37.8 35.135) rotate(180)">
					<rect class="cls-4" width="16.8" height="16.216" rx="3"/>
					<rect class="cls-5" x="0.5" y="0.5" width="15.8" height="15.216" rx="2.5"/>
				</g>
				<line id="Line_739" data-name="Line 739" class="cls-3" y2="3.378" transform="translate(11.55 15.878)"/>
				<line id="Line_740" data-name="Line 740" class="cls-3" y2="3.378" transform="translate(26.25 15.878)"/>
				</g>
			</g>
			<g id="Rectangle_13867" data-name="Rectangle 13867" class="cls-3">
				<rect class="cls-4" width="35" height="25" rx="2"/>
				<rect class="cls-5" x="0.5" y="0.5" width="34" height="24" rx="1.5"/>
			</g>
			</g>
		</svg>
	</div>
	<div class="content">
		<p>Debit Card</p>
		<div class="card-data">
			<p>${bankData.name}</p>
			<p>${bankData.createdDate}</p>
		</div>
		<p class="cardnumber">${bankData.cardNumber}</p>
		</div>`;
		$(template).appendTo("#bankcard");
	}

	renderMyMoneySection(){
		const moneyData =  this.fullRenderData
		$("#your-money-panel").empty();
		let template = `<h3>${this.language.your_money_title}</h3>
		<p>${this.language.your_money_desc}</p>
		<div id="money-containers">`;
			moneyData.accountsData.forEach((data)=>{
			template += `
				<div class="money-container">
					<h4>${this.language[`your_money_${data.name}_label`]}</h4>
					<span id="money-${data.name}">${this.language.moneyFormat.replace("__replaceData__",data.amount)}</span>
				</div>
			`;
			})

			template += "</div>"

			$(template).appendTo("#your-money-panel");
	}

	renderTransactions(){
		const transactionData = this.fullRenderData
		$("#transactions-container").empty();
		if(transactionData.length == 0){ return}

		for(let i = 0; i < transactionData.slice(0,3).length; i++){
			let oneRow = `
				<div class="transaction-container">
					<div class="transaction">
						<h4>${transactionData[i].type}</h4>
						<span>${Utils.dateFormat(transactionData[i].time)}</span>
					</div>
					<span class=${transactionData[i].type == this.language.withdraw || transactionData[i].type == this.language.transfer ? "red-text" : "green-text" }>${transactionData[i].type == this.language.withdraw || transactionData[i].type == this.language.transfer ? "-" : "+"}${this.language.moneyFormat.replace("__replaceData__",transactionData[i].amount)}</span>
				</div>
			`;

			$(oneRow).appendTo("#transactions-container");	
		}
	}

	setData(newData,newLanguage){
		this.fullRenderData = newData;
		this.language = newLanguage;
	}

	refresh(newData){
		switch (this.elementID) {
			case "your_money":
				$("#money-cash").html(`${this.language.moneyFormat.replace("__replaceData__",newData.money)} `);
				$("#money-bank").html(`${this.language.moneyFormat.replace("__replaceData__",newData.bankMoney)}`);
				break;
			case "transaction": 
				this.fullRenderData = newData
				this.renderTransactions()
				break;
			default:
				break;
		}
	}
}

class Pincode {
	elementID = ""
	pincode = ""
	constructor(elementID){
		this.elementID = elementID
		this.renderPinInputs()
		this.renderPassCode()
		this.hide(false)
	}

	setPincode(newPincode){
		this.pincode += newPincode
	}

	getPincode(){
		return this.pincode
	}

	renderPassCode(){
		$("#container").fadeOut()
		this.pincode = ""
		$(`${this.elementID} .pincode-input`).empty()
		for(let i = 0; i < 4;i++){
			$(`${this.elementID} .pincode-input`).append(`<span></span>`);
		}
		$(".pincode-numbers div:nth-child(12)").addClass("disable-button")
		$(".pincode-numbers div:nth-child(12)").prop("disabled",true)
	}

	renderPinInputs(){
		let numbers = [1,2,3,4,5,6,7,8,9,0]
		numbers.forEach((number)=>{
			$(`<div>${number}</div>`).insertBefore(`.pincode-numbers .deleteButton`)
		})
	}

	show(){
		$(this.elementID).fadeIn(100)
	}

	hide(anim = true){
		if(anim){
			$(this.elementID).fadeOut(200)
		}
		else{
			$(this.elementID).hide()
		}
	}
}

var timeZone = ""
class Utils {
	static dateFormat(date){
		if(typeof(date) == "number"){
			var newDate = new Date(date)
		}else{
			var newDate = date
		}
		return newDate.toLocaleString([Utils.getTimeZone()], {
			weekday:"long",
			hour:"2-digit",
			minute:"2-digit",
		}).capitalize()
	}

	static setCardData(value){
		if(localStorage.getItem("CARD_DATA") == null){
			localStorage.setItem("CARD_DATA",JSON.stringify(value))
		}
	}

	static getCardData(){
		return JSON.parse(localStorage.getItem("CARD_DATA"))
	}

	static genMonth() {
		var date = new Date();
		var arr  = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
		var rNum = Math.floor(Math.random() * arr.length);
		var year = date.getFullYear().toString();
		year = year.substr(2, year.length);
		year = parseInt(parseInt(year) + 2);
		return parseInt(rNum + 1) + '/' + year;
	}

	static genCardNumber() {
		let char = '0123456789'
		let genNum = ''
		for (let i = 0; i < 16; i++) {
			var rnum = Math.floor(Math.random() * char.length);
			genNum += char.substring(rnum, rnum + 1);
			if((i + 1) % 4 == 0){
				genNum += " "
			}
		}
		return genNum;
	}

	static setTimeZone(newTimeZone){
		timeZone = newTimeZone
	}

	static getTimeZone(){
		return timeZone
	}
}

class Graph{
	transData = {}
	graphData = {
		type: 'line',
		data: {
			labels: [],
			datasets: [
				{
					label: "BALANCE",
					data:[],
					backgroundColor: [
						'rgba(75, 192, 192, 0.2)',
					],
					borderColor: [
						'rgba(75, 192, 192, 1)',
					],
					borderWidth: 1
				}
			]
		},
		options: {
			responsive: true,
			maintainAspectRatio:false,
			scales: {
				y: {
					beginAtZero: true
				}
			}
		}
	}

	constructor(transData,title,color){
		this.graphData.data.datasets[0].label = title
		this.transData = transData
		this.calculateGraphData()
	}

	refreshGraphData(newTransData){
		this.transData = newTransData
		this.calculateGraphData()
		this.renderSmallGraph()
	}

	renderSmallGraph(){
		const ctx = $('#smallGraph');
		let chartStatus = Chart.getChart("smallGraph");

		if (chartStatus != undefined) {
			chartStatus.destroy();
		}

		return new Chart(ctx,this.graphData);
	}

	renderBigGraph(){
		const ctx = $('#moreGraph');
		let chartStatus = Chart.getChart("moreGraph");

		if (chartStatus != undefined) {
			chartStatus.destroy();
		}

		return new Chart(ctx,this.graphData);
	}

	calculateGraphData(){
		this.graphData.data.labels = []
		this.graphData.data.datasets[0].data = []
		this.graphData.data.datasets[0].borderColor = [	getComputedStyle(document.body).getPropertyValue('--graphLineColor')]
		this.graphData.data.datasets[0].backgroundColor = [getComputedStyle(document.body).getPropertyValue('--graphLineBackgroundColor')]
		for(let transaction of [...this.transData].slice(0,50).reverse()){
			this.graphData.data.labels.push(Utils.dateFormat(transaction.time))
			this.graphData.data.datasets[0].data.push(transaction.balance)
		}
	}

}

class GlobalStore{

	storedData = {}

	constructor(newStoredData){
		this.storedData = newStoredData
	}

	setStoredData(newStoredData){
		this.storedData = newStoredData
	}

	getStoredData(){
		return this.storedData
	}
}

Object.defineProperty(String.prototype, 'capitalize', {
	value: function() {
		return this.charAt(0).toUpperCase() + this.slice(1);
	},
	enumerable: false
});


$(document).ready(function(){

	var formData 
	var language
	$.getJSON("config.json", function(data){
		let lang = "EN"
		if(data[data.lang] != null){
			lang = data.lang
		}
		Utils.setTimeZone(lang == "HU" ? "hu-HU" : "en-GB")
		formData = new GlobalStore(data[lang]["DYNAMIC_FORM_DATA"])
		language = new GlobalStore(data[lang]["LAUNGAGE"])
	}).fail(function(error){
		console.log("Can't load JSON file! " + error);
	});


	var inputData = new GlobalStore({})
	var transactionData

	let yourMoney = new Render("your_money")
	let transaction = new Render("transaction")
	let bankcard = new Render("bankcard")
	let graph = ""
	var pincode = ""
	var type = ""


	Utils.setCardData({cardNumber:Utils.genCardNumber(), cardExpiry:Utils.genMonth()})

	function bankRender(){
		Components.generateAllComponents(formData.getStoredData())
	}

	function ATMRender(){
		Components.generateAllComponents(formData.getStoredData(),"atm")
		pincode = new Pincode("#pincode-container")
		Components.getComponent("atmComponent").fadeOut()
		Components.getComponent("withdraw").setElementId(".secondGridColumn")
		Components.getComponent("withdraw").renderInputAndButton()
		Components.getComponent("deposit").setElementId(".secondGridColumn")
		Components.getComponent("deposit").renderInputAndButton()

		pincode.show()
	}

	$(document).on('click','.pincode-numbers div',function(){
		if(pincode.getPincode().length + 1 == 4){
			$(".pincode-numbers div:nth-child(12)").removeClass("disable-button")
			$(".pincode-numbers div:nth-child(12)").prop("disabled",false)
		}

		let currentNumber = $(this).text();
		$(".pincode-input span").each(function () {
			let spanText = $(this).attr('number');
			if (!spanText) {
				$(this).attr("number",currentNumber)
				$(this).addClass("circleBackground");
				pincode.setPincode(currentNumber)
				return false;
			}
		})
	})


	$(document).on('click','.pincode-numbers div:nth-child(11)',function(){
		pincode.renderPassCode()
	})

	$(document).on('click','.pincode-numbers div:nth-child(12)',function(){
		$.post('https://esx_banking/checkPincode', JSON.stringify(pincode.getPincode()))
		.then((response) =>{
			if(response.success){
				Components.loader("#pincode-container","show")
				setTimeout(()=>{
					Components.getComponent("atmComponent").fadeIn(200)
				},2800)
			}
			else if(response.error){
				pincode.renderPassCode()
			}
		});
	})


	window.addEventListener('message', ({data}) => {
		const languageText = language.getStoredData()
		if(data.showMenu){
			const datas = data.datas

			transactionData = new GlobalStore(datas.transactionsData)
			const transData = transactionData.getStoredData()
			transData.map((trans)=>{
				trans.id = trans.time
				trans.time = Utils.dateFormat(trans.time)
				switch(trans.type){
					case "WITHDRAW":
						trans.type = languageText.withdraw
						break;
					case "DEPOSIT":
						trans.type = languageText.deposit
						break;
					case "TRANSFER_RECEIVE":
						trans.type = languageText.transferReceive
					break;
					default:
						trans.type = languageText.transfer
						break;
				}
				return trans
			})

			graph = new Graph(transData,languageText.graphTitle)

			if(data.openATM){
				ATMRender()
				type = "ATM"
				transaction.setData(transData,languageText)
			}
			else{
				type = "BANK"
				bankRender()
				graph.renderSmallGraph()

				transaction.setData(transData,languageText)
				transaction.renderTransactions()
			}

			const bankData = Utils.getCardData()
			datas.bankCardData.cardNumber = bankData.cardNumber
			datas.bankCardData.createdDate = bankData.cardExpiry
			bankcard.setData(datas.bankCardData)
			bankcard.renderBankCard()

			yourMoney.setData(datas.your_money_panel,languageText)
			yourMoney.renderMyMoneySection()


			Components.loader(".loader","show")
		}else if(data.updateData){
			const currentInputValues = inputData.getStoredData()
			const updateTransData = transactionData.getStoredData()

			let info
			if(amount = currentInputValues.withdraw){
				info = {label:languageText.withdraw, amount: amount}
			}
			else if(amount = currentInputValues.deposit) {
				info = {label:languageText.deposit, amount: amount}
			}
			else if (amount = currentInputValues.transfer?.moneyAmount){
				info = {label:languageText.transfer, amount: amount}
			}
			else if (currentInputValues.pincode){
				return
			}
			updateTransData.unshift({time:Utils.dateFormat(new Date()),id: new Date().getTime(),amount: info.amount, type:info.label.toUpperCase(), balance: data.data.bankMoney})
			yourMoney.refresh(data.data)	
			transaction.refresh(updateTransData)
			if(type == "BANK") graph.refreshGraphData(updateTransData)
		}
	})

	function resetContainerAndSetTitle(title){
		$("#menu").fadeOut();
		$("#title-container h3").text(title);
		$("#more-modal-container").empty();
	}
	

	$(document).on('click','#more_graph',function(){
		resetContainerAndSetTitle(language.getStoredData().moreGraphTitle)
		$("#modal-container").fadeIn();
		$("#more-modal-container").html('<canvas id="moreGraph"></canvas>');
		graph.renderBigGraph()
	})


	$(document).on('click','#more_history',function(){
		const lang = language.getStoredData()
		resetContainerAndSetTitle(lang.moreHistoryTitle)
		$("#more-modal-container").html(`
		<table id="example" class="display" style="width:100%">
			<thead>
				<tr>
					<th>id</th>	
					<th>type</th>
					<th>balance</th>
					<th>amount</th>
					<th>time</th>
				</tr>
			</thead>
		</table>`);
		$('#example').DataTable({
			"responsive": true,
			"data": transactionData.getStoredData(),
			"columns": [
				{ "data" : "id", },
				{ "data": "type" , "title":lang.tableLang.typeLabel},
				{ "data": "balance" ,"title":lang.tableLang.balanceLabel},
				{ "data": "amount" , "title":lang.tableLang.amountLabel},
				{ "data": "time" , "title":lang.tableLang.timeLabel}
			],
			columnDefs: [
				{
					target: 0,
					visible: false,
					searchable: false,
				},
				{
					target: 4,
					orderable: false,
				},
			],
			createdRow: function (row, data, index) {
				let parseType = data.type.replace(/[\$,]/g, '')
				$('td', row).eq(1).text(`$${data.balance}`)
				if (parseType == lang.deposit || parseType == lang.transferReceive) {
					$('td', row).eq(2).addClass('greenTableText');
					$('td', row).eq(2).html(`+${lang.moneyFormat.replace("__replaceData__",data.amount)}`)
				}
				else if(parseType == lang.withdraw || parseType == lang.transfer){
					$('td', row).eq(2).addClass('redTableText');
					$('td', row).eq(2).html(`-${lang.moneyFormat.replace("__replaceData__",data.amount)}`)
				}
			},
			"order": [[0, 'desc']],
			"scrollY":     "450px",
			"scrollX":     	true,
			"scrollCollapse": true,
			"fixedColumns":   {
				"heightMatch": 'none'
			},
			"language": {
				"url": `https://cdn.datatables.net/plug-ins/9dcbecd42ad/i18n/${lang.tableLang.tableFullLanguage}.json`,
				"search": '', "searchPlaceholder": lang.tableLang.searchInputPlaceholder
			},
			
		});

		$("#modal-container").fadeIn();
	})


	let inputs = {
		first: false,
		second: false
	}

	$(document).on('keyup','input[type="number"] , input[type="password"]',function(){
		let buttonGroup = $(this).closest('.input-groups-container').find('button');

		if(buttonGroup.length > 0){
			let name = $(this).attr("name");
			if(name == "moneyAmount"){
				inputs.first = $(this).val() != ''
			}
			else{
				inputs.second = $(this).val() != ''
			}

			if(inputs.first && inputs.second){
				buttonGroup.removeClass('disable-button')
				buttonGroup.prop('disabled',false)
			}
			else{
				buttonGroup.addClass('disable-button')
				buttonGroup.prop('disabled',true)
			}

			return
		}

		let button = $(this).next('button');

		if($(this).val() != '') {
			if($(this).attr("name") == "pincode" && $(this).val().length < 4){
				return
			}

			button.removeClass('disable-button')
			button.prop('disabled',false)
		}
		else{
			button.addClass('disable-button')
			button.prop('disabled',true)
		}

    });

	$(document).on('click','.accept-button',function(){
		let buttonGroup = $(this).closest('.input-groups-container').find('button');
		let inputValues = {}
		if(buttonGroup.length > 0){
			inputValues["transfer"] = {}
			$(".input-groups-container input").each(function() {
				inputValues["transfer"][$(this).attr('name')] = $(this).val();
				$(this).val(null);
				inputs.first = false
				inputs.second = false
			});
		}
		else{
			let inputValue = $(this).prev('input').val();
			if(inputValue == undefined){return}
			if((inputValue.length == 0 && inputValue <= 0 )){
				return
			}

			inputValues[$(this).prev('input').attr('name')] = inputValue;

			$(this).prev('input').val(null);
		}


		inputData.setStoredData(inputValues)
		$.post('https://esx_banking/clickButton', JSON.stringify(inputValues));

		$(this).addClass('disable-button')
		$(this).prop('disabled',true)
	})


	$(document).on('click','#close-button',function(){
		$("#modal-container").fadeOut();
		$("#menu").fadeIn();
	})

	$(document).on('click','.exit-button',function(){
		Components.loader(".loader","hide")
		$.post('https://esx_banking/close', JSON.stringify({}));
	})

	$(document).keyup(function(e) {
		if(e.which == 27) {
			if (!LOADED) {
				Components.loader(".loader","hide")
				$.post('https://esx_banking/close', JSON.stringify({}));
			}
		}
	});
})
