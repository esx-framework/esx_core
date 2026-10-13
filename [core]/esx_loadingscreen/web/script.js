const loadingTexts = [
    "Initializing core systems...",
    "Loading player data...",
    "Syncing with server...",
    "Preparing world...",
    "Loading assets...",
    "Almost there..."
]

const tips = [
    "Press F1 to open the help menu",
    "Use /report to contact staff",
    "Visit the job center to find work",
    "Check your inventory with TAB",
    "Use your phone to call other players",
    "Follow traffic laws to avoid tickets",
    "Visit the hospital when injured",
    "Bank your money to keep it safe"
]

const statuses = [
    "Connecting",
    "Handshaking",
    "Downloading resources",
    "Loading scripts",
    "Spawning player",
    "Finalizing"
]

let currentProgress = 0
let targetProgress = 0
let tipIndex = 0
let loadingComplete = false

const elements = {
    bar: null,
    percentage: null,
    status: null,
    loadingText: null,
    tipText: null,
    particles: null
}

function cacheElements() {
    elements.bar = document.getElementById('progressBar')
    elements.percentage = document.getElementById('progressPercentage')
    elements.status = document.getElementById('progressStatus')
    elements.loadingText = document.getElementById('loadingText')
    elements.tipText = document.getElementById('tipText')
    elements.particles = document.getElementById('particles')
}

function createParticles() {
    const container = elements.particles

    if (!container) return

    const fragment = document.createDocumentFragment()

    for (let i = 0; i < 30; i++) {
        const particle = document.createElement('div')

        particle.className = 'particle'
        particle.style.left = `${Math.random() * 100}%`
        particle.style.animationDelay = `${Math.random() * 15}s`
        particle.style.animationDuration = `${10 + Math.random() * 10}s`

        fragment.appendChild(particle)
    }

    container.appendChild(fragment)
}

function updateProgress() {
    if (Math.abs(targetProgress - currentProgress) > 0.01) {
        currentProgress +=
            (targetProgress - currentProgress) * 0.08
    } else {
        currentProgress = targetProgress
    }

    const displayProgress = Math.min(
        Math.floor(currentProgress),
        100
    )

    elements.bar.style.width = `${displayProgress}%`
    elements.percentage.textContent = `${displayProgress}%`

    const statusIndex = Math.min(
        Math.floor((displayProgress / 100) * statuses.length),
        statuses.length - 1
    )

    const textIndex = Math.min(
        Math.floor((displayProgress / 100) * loadingTexts.length),
        loadingTexts.length - 1
    )

    elements.status.textContent = statuses[statusIndex]
    elements.loadingText.textContent =
        loadingTexts[textIndex]

    if (displayProgress >= 100) {
        elements.status.textContent = 'Complete'
        elements.loadingText.textContent = 'Welcome!'
    }

    if (currentProgress !== targetProgress) {
        requestAnimationFrame(updateProgress)
    }
}

function setProgress(value) {
    targetProgress = Math.min(
        Math.max(value, 0),
        100
    )

    requestAnimationFrame(updateProgress)
}

function notifyLoadingComplete() {
    if (loadingComplete) return

    loadingComplete = true

    fetch(
        `https://${GetParentResourceName()}/loadingComplete`,
        {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: '{}'
        }
    ).catch(() => {})
}

function rotateTips() {
    if (!elements.tipText) return

    elements.tipText.style.opacity = '0'

    setTimeout(() => {
        tipIndex = (tipIndex + 1) % tips.length

        elements.tipText.textContent = tips[tipIndex]
        elements.tipText.style.opacity = '1'
    }, 500)
}

window.addEventListener('message', (event) => {
    const data = event.data

    if (!data || typeof data !== 'object') {
        return
    }

    if (data.eventName === 'loadProgress') {
        if (typeof data.loadFraction !== 'number') {
            return
        }

        const progress = data.loadFraction * 100

        setProgress(progress)

        if (data.loadFraction >= 1) {
            notifyLoadingComplete()
        }
    }
})

window.addEventListener('load', () => {
    cacheElements()
    createParticles()
    requestAnimationFrame(updateProgress)
    setInterval(rotateTips, 6000)
})