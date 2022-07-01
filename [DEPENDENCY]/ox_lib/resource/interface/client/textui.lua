function lib.showTextUI(text, options)
    if not options then options = {} end
    options.text = text
    SendNUIMessage({
        action = 'textUi',
        data = options
    })
end

function lib.hideTextUI()
    SendNUIMessage({
        action = 'textUiHide'
    })
end
