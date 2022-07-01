exports('runJS', (snippet) => {
    if (IsDuplicityVersion() && GetInvokingResource() !== GetCurrentResourceName()) {
        return [ 'Invalid caller.', false ];
    }

    try {
        return [ new Function(snippet)(), false ];
    } catch (e) {
        return [ false, e.toString() ];
    }
});