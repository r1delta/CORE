IncludeScript("_pdef")
// Client/UI implementation of GetPersistentVar
function GetPersistentVar(name) {
    if (!IsValidKey(name)) return 0
    
    local packedValue = GetPersistentString(name, "")
    if (packedValue == "") return 0
    
    local unpackedValue = UnpackValue(packedValue)
    return (unpackedValue != null) ? unpackedValue : 0
}

// Client/UI implementation of GetPersistentVarAsInt
function GetPersistentVarAsInt(name) {
    local value = GetPersistentVar(name)
    return (typeof value == "integer") ? value : 0
}
