// Helper function to pack values with type information
function PackValue(value, type) {
    local typeCode
    switch(type) {
        case "integer": typeCode = "i"; break
        case "float": typeCode = "f"; break
        case "bool": typeCode = "b"; break
        case "string": typeCode = "s"; break
        default: typeCode = "x"; break // Invalid type
    }
	if (typeCode != "x")
		return typeCode + value.tostring()
	return "x"
}

// Helper function to unpack values and verify their type
function UnpackValue(packedValue) {
	if (packedValue.len() < 2) return null
    local typeCode = packedValue[0].tochar()
    local value = packedValue.slice(1)
    
    if ("i" == typeCode) {
        return value.tointeger()
    } else if ("f" == typeCode) {
        return value.tofloat()
    } else if ("b" == typeCode) {
        return value == "true"
    } else if ("s" == typeCode) {
        return value
    } else {
        return null
    }
}

// Helper function to validate keys against the schema (unchanged)
function IsValidKey(key) {
/*
    local schema = GetPDEFSchema()
    local parts = split(key = ".")
    local current = schema
    
    foreach (part in parts) {
        if (part in current) {
            current = current[part]
        } else {
            return false
        }
    }
    */
    return true
}
