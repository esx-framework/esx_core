// Placeholder for future disco NUI effects
window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'showDiscoEffects') {
        document.getElementById('disco-effects').classList.remove('hidden');
    }

    if (data.type === 'hideDiscoEffects') {
        document.getElementById('disco-effects').classList.add('hidden');
    }
});
