$(".character-box").hover(
    function() {
        $(this).css({
            "background": "rgb(34, 31, 39)",
            "transition": "200ms",
        });
    }, function() {
        $(this).css({
            "background": "rgba(44, 51, 69, 0.6)",
            "transition": "200ms",          
        });
    }
);

$(document).ready(() => {
	$(".character-info-new").html(translate.new)
	$(".btn-delete").html(translate.delete);
	$(".modalTitle").html(translate.modalTitle);
	$(".modalText").html(translate.modalText);
});

$(".character-box").click(function () {
    $(".character-box").removeClass('active-char');
    $(this).addClass('active-char');
    $(".character-buttons").css({"display":"block"});
    if ($(this).attr("data-ischar") === "true") {
        $("#delete").css({"display":"block"});
    } else {
        $("#delete").css({"display":"none"});
    }
});

$(".character-box").click(function () {
    if ($(this).attr("data-ischar") === "true") {
        $("#play-char").html(translate.play);
    } else {
        $("#play-char").html(translate.playNew);
    }
});


$("#play-char").click(function () {
    $.post("http://esx_kashacters/CharacterChosen", JSON.stringify({
        charid: Number($('.active-char').attr("data-charid")),
        ischar: ($('.active-char').attr("data-ischar") == "true"),
    }));
    Kashacter.CloseUI();
});

$("#deletechar").click(function () {
    $.post("http://esx_kashacters/DeleteCharacter", JSON.stringify({
        charid: Number($('.active-char').attr("data-charid")),
    }));
    Kashacter.CloseUI();
});

(() => {
    Kashacter = {};

    Kashacter.ShowUI = function(data) {
        $('body').css({"display":"block"});
        $('.main-container').css({"display":"block"});
        if(data.characters !== null) {
            $.each(data.characters, function (index, char) {
                if (char.charid !== 0) {
                    var charid = char.identifier.charAt(4);
                    $('[data-charid=' + charid + ']').html('<h3 class="character-fullname">'+ char.firstname +'</h3><div class="character-info"><p class="character-info-name"><strong>' + `${translate.name}: ` + '</strong><span>' + char.firstname +' '+ char.lastname +'</span></p><p class="character-info-work"><strong>' + `${translate.job}: ` + '</strong><span>'+ char.job +' '+ char.job_grade +'</span></p><p class="character-info-money"><strong>' + `${translate.money}: ` + '</strong><span> $'+ char.money +'</span></p><p class="character-info-bank"><strong>' + `${translate.bank}: ` + '</strong><span> $'+ char.bank +'</span></p> <p class="character-info-dateofbirth"><strong>' + `${translate.dob}: ` + '</strong><span>'+ char.dateofbirth +'</span></p> <p class="character-info-gender"><strong>' + `${translate.gender}: ` + '</strong><span>'+ char.sex +'</span></p></div>').attr("data-ischar", "true");
                }
            });
        }
    };

    Kashacter.CloseUI = function() {
        $('body').css({"display":"none"});
        $('.main-container').css({"display":"none"});
        $(".character-box").removeClass('active-char');
        $("#delete").css({"display":"none"});
		$(".character-box").html('<h3 class="character-fullname">Empty Slot</h3><div class="character-info"><p class="character-info-new">' + `${translate.new}` + '</p></div>').attr("data-ischar", "false");
    };
    window.onload = function(e) {
        window.addEventListener('message', function(event) {
            switch(event.data.action) {
                case 'openui':
                    Kashacter.ShowUI(event.data);
                    break;
            }
        })
    }

})();