IncludeScript("_pdef")
// Client/UI implementation of GetPersistentVar
function GetPersistentVar(name) {
    if (!IsDelta()) { return OldPersistentVar(name) }
    if (!IsValidKey(name)) return null
    local value = GetPersistentString(name, "pdata_null")
    local unpackedKey = UnpackKey(name)
    local type = pdef_keys[unpackedKey]
    
    if (type == "int") {
        return (value == "pdata_null") ? 0 : value.tointeger()
    } else if (type == "float") {
        return (value == "pdata_null") ? 0.0 : value.tofloat()
    } else if (type == "bool") {
        return (value == "pdata_null") ? false : (value.tointeger() == 1)
    } else if (type == "string") {
        return (value == "pdata_null") ? "" : value
    } else {
        return ((value == "pdata_null") || !PersistenceEnumValueIsValid(type, value)) ? null : value
    }
}

// Client/UI implementation of GetPersistentVarAsInt
function GetPersistentVarAsInt(name) {
    if (!IsDelta()) { return OldPersistentVarAsInt(name) }
    local value = GetPersistentVar(name)
    return (typeof value == "integer") ? value : 0
}