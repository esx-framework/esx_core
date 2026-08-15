window.addEventListener('message', function (event) {
    var data = event.data;
    if (!data || data.action !== 'medalClip') return;

    fetch('http://localhost:12665/api/v1/event/invoke', {
        method: 'POST',
        headers: {
            'publicKey': data.publicKey,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data.payload)
    }).catch(function () {});
});
