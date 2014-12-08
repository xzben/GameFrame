
function clone(object)
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

--Create an class.
function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end

        cls.ctor    = function() end
        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            -- instance:ctor(...)
            -- 递归执行构造函数    
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

    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            -- instance:ctor(...)
            -- 递归执行构造函数    
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

        
        --[[
        此方法用于构造集成于C++对象的lua对象，并执行相应的构造函数.
        ------------------------------------------------------------------------------------------------------------------------
        每个C++对象需要存贮自己的成员变量的值，这个值不能够存贮在元表里(因为元表是类共用的)，所以每个对象要用一个私有的表来存贮，
        这个表在tolua里叫做peer表。元表的__index指向了一个C函数，当在Lua中要访问一个C++对象的成员变量(准确的说是一个域)时，
        会调用这个C函数，在这个C函数中，会查找各个关联表来取得要访问的域，这其中就包括peer表的查询。 
        --]]
        function cls.extend(target, ...)
            -- 先继承C++对象
            local t = tolua.getpeer(target)
            if not t then
                t = {}
                tolua.setpeer(target, t)
            end
            setmetatable(t, cls)
            -- 递归执行构造函数
            do
                local create
                create = function(c,...)
                    if c.super then
                        create(c.super,...)
                    end
                    if c.ctor then
                        c.ctor(target,...)
                    end
                end
                create(cls,...)
            end
            return target            
        end
    end

    return cls
end

function schedule(node, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    local action = cc.RepeatForever:create(sequence)
    node:runAction(action)
    return action
end

function performWithDelay(node, callback, delay)
    local delay = cc.DelayTime:create(delay)
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
    node:runAction(sequence)
    return sequence
end
