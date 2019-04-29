function NumberDictionary(Dict)
    Number = 0
    for _,v in pairs(Dict) do
        Number = Number+1
    end
    return Number
end

return NumberDictionary