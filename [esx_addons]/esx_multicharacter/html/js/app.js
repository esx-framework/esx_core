var money = Intl.NumberFormat('en-US', {
	style: 'currency',
	currency: 'USD',
	minimumFractionDigits: 0
});

(() => {
    Kashacter = {};

    Kashacter.ShowUI = function(data) {
        $('body').css({"display":"block"});
        $('.main-container').css({"display":"block"});
		$('[data-charid=1]').html('<div class="character-info"><p class="character-info-name"><h1>' + `${translate.name} ` + '</h1><span>' + data.firstname +' '+ data.lastname +'</span></p><p class="character-info-work"><h1>' + `${translate.job} ` + '</h1><span>'+ data.job +' '+ data.job_grade +'</span></p><p class="character-info-money"><h1>' + `${translate.money} ` + '</h1><span> '+ money.format(data.money) +'</span></p><p class="character-info-bank"><h1>' + `${translate.bank} ` + '</h1><span> '+ money.format(data.bank) +'</span></p> <p class="character-info-dateofbirth"><h1>' + `${translate.dob} ` + '</h1><span>'+ data.dateofbirth +'</span></p> <p class="character-info-gender"><h1>' + `${translate.gender} ` + '</h1><span>'+ data.sex +'</span></p></div>').attr("data-ischar", "true");
    };

    Kashacter.CloseUI = function() {
        $('body').css({"display":"none"});
        $('.main-container').css({"display":"none"});
		$('[data-charid=1]').html('<h3 class="character-fullname"></h3><div class="character-info"><p class="character-info-new"></p></div>');
    };

    window.onload = function(e) {
        window.addEventListener('message', function(event) {
            switch(event.data.action) {
                case 'openui':
                    Kashacter.ShowUI(event.data.character);
                    break;
				case 'closeui':
					Kashacter.CloseUI();
					break;
            }
        })
    }

})();
