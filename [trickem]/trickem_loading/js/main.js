const tips = [
    "Welcome to TrickEm City - Where the 70s never ended.",
    "Hit the disco floor at Studio 54 to earn some bread and meet new cats.",
    "Cruise the strip in a classic muscle car - nothing beats a '70 Challenger.",
    "The fuzz is always watching. Keep your nose clean or pay the price.",
    "Visit the tailor to get your threads right - bell-bottoms are mandatory.",
    "Need some scratch? Check the job board at the unemployment office.",
    "The taxi hustle is real - pick up fares and earn honest bread.",
    "Keep your ride in check at the local garage. Burnt rubber ain't free.",
    "The Disco Inferno club is the place to be after dark.",
    "Doctors at the county hospital can patch you up, no questions asked.",
    "Groovy rides at the dealership - from Pintos to Cadillacs.",
    "The streets talk. Build your rep and the city opens up.",
    "Bank of TrickEm - where your bread is safe... mostly.",
    "Need a piece? Know the right people. This ain't no toy store.",
    "Every cat starts somewhere. Work your way up from the bottom.",
    "The mechanic shop is always hiring. Honest work for honest pay.",
    "Watch out for the heat - they cruise in unmarked rides too.",
    "The 70s are alive and well in TrickEm City. Stay groovy, baby."
];

let currentTip = 0;
let loadProgress = 0;

function showNextTip() {
    const tipEl = document.getElementById('tip-text');
    if (tipEl) {
        tipEl.style.opacity = '0';
        setTimeout(() => {
            currentTip = (currentTip + 1) % tips.length;
            tipEl.textContent = tips[currentTip];
            tipEl.style.opacity = '1';
        }, 500);
    }
}

function updateLoadBar() {
    const fill = document.getElementById('loading-bar-fill');
    if (fill && loadProgress < 90) {
        loadProgress += Math.random() * 8 + 2;
        if (loadProgress > 90) loadProgress = 90;
        fill.style.width = loadProgress + '%';
    }
}

// Show initial tip
document.addEventListener('DOMContentLoaded', () => {
    const tipEl = document.getElementById('tip-text');
    if (tipEl) {
        tipEl.textContent = tips[Math.floor(Math.random() * tips.length)];
    }

    // Cycle tips every 6 seconds
    setInterval(showNextTip, 6000);

    // Simulate loading progress
    setInterval(updateLoadBar, 800);
});

// Handle FiveM loading events
const handlers = {
    startInitFunctionOrder(data) {
        document.getElementById('loading-text').innerHTML =
            'Initializing ' + (data.type === 'init' ? 'resources' : 'map') + '<span class="dots"></span>';
    },

    performMapLoadFunction(data) {
        document.getElementById('loading-text').innerHTML =
            'Loading the city<span class="dots"></span>';
    },

    onLogLine(data) {
        // Update loading text based on log messages
        if (data.message && data.message.includes('Loading')) {
            const msg = data.message.substring(0, 60);
            document.getElementById('loading-text').innerHTML =
                msg + '<span class="dots"></span>';
        }
    }
};

window.addEventListener('message', (e) => {
    (handlers[e.data.eventName] || function() {})(e.data);
});
