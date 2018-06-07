$(window).ready(function () {
    // NUI Callback
    window.addEventListener('message', function (event) {
        let data = event.data;
        if (data.showControls) {
            $('#container').show();
            $('#menu').hide();
        }
        if (data.showMenu) {
            $('#container').show();
            $('#menu').show();
            $('#deposit_amount').val(data.player.money);
            let bankAmount = 0;
            for (let i = 0; i < data.player.accounts.length; i++)
                if (data.player.accounts[i].name == 'bank')
                    bankAmount = data.player.accounts[i].money;
            if (bankAmount >= 10000) {
                $('#withdraw_amount').val(10000);
            } else {
                $('#withdraw_amount').val(bankAmount);
            }
        }

        if (data.hideAll) {
            $('#container').hide();
        }
    });

    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post('http://esx_atm/escape', '{}');
        }
    };

    $('#container').hide();

    $('#deposit_btn').on('click', function () {
        $.post('http://esx_atm/deposit', JSON.stringify({
            amount: $('#deposit_amount').val()
        }));
    })

    $('#withdraw_btn').on('click', function () {
        $.post('http://esx_atm/withdraw',
            JSON.stringify({
                amount: $('#withdraw_amount').val()
            })
        );
    });
});
