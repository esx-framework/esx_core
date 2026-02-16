function formatMoney(amount) {
    return '$' + amount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

function padZero(num) {
    return num.toString().padStart(2, '0');
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'updateHud') {
        // Health bar
        document.getElementById('health-fill').style.width = data.health + '%';

        // Armor bar
        document.getElementById('armor-fill').style.width = data.armor + '%';

        // Money
        document.getElementById('cash-value').textContent = formatMoney(data.cash);
        document.getElementById('bank-value').textContent = formatMoney(data.bank);

        // Job
        document.getElementById('job-name').textContent = data.job;
        document.getElementById('job-grade').textContent = data.jobGrade;

        // Location
        document.getElementById('street-display').textContent = data.street;
        document.getElementById('time-display').textContent =
            padZero(data.hour) + ':' + padZero(data.minute);

        // Vehicle
        const vehicleHud = document.getElementById('vehicle-hud');
        if (data.inVehicle) {
            vehicleHud.classList.remove('hidden');
            document.getElementById('speed-value').textContent = data.speed;
            document.getElementById('fuel-fill').style.width = data.fuel + '%';
        } else {
            vehicleHud.classList.add('hidden');
        }
    }

    if (data.type === 'toggleHud') {
        const container = document.getElementById('hud-container');
        if (data.visible) {
            container.classList.remove('hidden');
        } else {
            container.classList.add('hidden');
        }
    }
});
