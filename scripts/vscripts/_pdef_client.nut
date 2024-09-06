IncludeScript("_pdef")
// Client/UI implementation of GetPersistentVar
function GetPersistentVar(name) {
    if (!IsDelta()) { return OldPersistentVar(name) }
    if (!IsValidKey(name)) return null
    local value = GetPersistentString(name, "")
    local unpackedKey = UnpackKey(name)
    local type = pdef_keys[unpackedKey]
    
    if (type == "int") {
        return (value == "") ? 0 : value.tointeger()
    } else if (type == "float") {
        return (value == "") ? 0.0 : value.tofloat()
    } else if (type == "bool") {
        return (value == "") ? false : (value == "1")
    } else if (type == "string") {
        return value
    } else {
        return null
    }
}

// Client/UI implementation of GetPersistentVarAsInt
function GetPersistentVarAsInt(name) {
    if (!IsDelta()) { return OldPersistentVarAsInt(name) }
    local value = GetPersistentVar(name)
    return (typeof value == "integer") ? value : 0
}