local __classRegister       = setmetatable({}, {__mode ="kv"})
local __classObjectRegister = setmetatable({}, {__mode ="kv"})

local error         = error
local type          = type
local pairs         = pairs
local setmetatable  = setmetatable
local getmetatable  = getmetatable

local function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
 
local function class(classname, super)
	local superType = type(super)
	local cls = nil	

    if super and superType ~= "function" and superType ~= "table" then
        superType = nil
        error("the super class must be a function or table!!!!!!")
        return cls
    end
	
    if superType == "function" then
        cls = {}
        cls.__create = super

        cls.ctor    = function() end
        cls.destroy = nil
        __classRegister[cls] = classname
		
		
		
        function cls.new(...)
            local instance = cls.__create(...)			
			__classObjectRegister[instance] = cls
            for k,v in pairs(cls) do
                instance[k] = v
            end
						
            return instance:ctor(...)
        end
	else
		if super then
			cls = clone(super)
			cls.super = super
		else
			cls = { ctor = function() end }
		end
		
		__classRegister[cls] = classname
		cls.__index = cls
		
		function cls.new(...)		
			local instance = setmetatable({}, cls)
			__classObjectRegister[instance] = cls
			
			do
				local create
				create = function(c, ...)
					if c.super then
						create(c.super, ...)
					end
					
					if c.ctor then
						c.ctor(instance, ...)
					end
				end
				create(cls, ...)
			end
			return instance
		end
    end
    
    return cls
end

local function getClassName( cls )
	if __classRegister[cls] then
		return __classRegister[cls]		
	elseif  __classObjectRegister[cls] then
		return __classRegister[__classObjectRegister[cls]]
	end
	
	return "unknown"
end

local function isClassObj(obj, cls)
	if __classObjectRegister[obj] and __classObjectRegister[obj] == cls then
		return true
	end
	
	return false
end

local function getObjectCount()
	local count = 0
	for _, _ in pairs(__classObjectRegister) do
		count = count + 1
	end
	return count
end

local classHelper = {
	clone = clone,	-- 复制一个 table
	getClassName = getClassName, -- 获取一个类 或者 类对象的类名字
	isClassObj = isClassObj, -- 判断一个对象是否是一个类的实例
	getObjectCount = getObjectCount, -- 统计当前实例化的类对象的个数
	
}

return class, classHelper
