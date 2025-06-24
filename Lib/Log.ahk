LogError(error, title := "") {
    global configName
    
    if !title
        title := configName
        
    TrayTip(
        Format("{} ({})", error.message, error.extra), 
        Format("{}: {} error", title, error.what), 
        "Icon!"
    )
    
    return false
}

LogWarning(msg := "unknown", title := "", extra := "") {
    global configName 
        
    TrayTip(
        Format("{} ({})", msg, extra), 
        configName ": " title . " warning",
        "Icon!"
    )
        
}