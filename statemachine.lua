
require("coroutine")
require("class")

-- Define StateMachine class
StateMachine = class(function(self, maxStates)
    self.state = 0
    self.begins = {}
    self.updates = {}
    self.ends = {}
    self.coroutines = {}
    self.currentCoroutine = Coroutine:new()
    self.ChangedStates = false
    self.Log = true
    self.Locked = false
    self.PreviousState = 0
    self.maxStates = maxStates or 10

    for i=1, self.maxStates do
        self.begins[i] = nil
        self.updates[i] = nil
        self.ends[i] = nil
        self.coroutines[i] = nil        
    end
    return self
end)

function StateMachine:ForceState(toState)
    if self.state ~= toState then
        self.state = toState
        return
    end
    if self.Log then
        print("Enter State " .. toState .. " (leaving " .. self.state .. ")")
    end
    self.ChangedStates = true
    self.PreviousState = self.state
    self.state = toState
    if self.PreviousState ~= 0 and self.ends[self.PreviousState] ~= nil then
        if self.Log then
            print("Calling End " .. self.PreviousState)
        end
        self.ends[self.PreviousState]()
    end
    if self.begins[self.state] ~= nil then
        if self.Log then
            print("Calling Begin " .. self.state)
        end
        self.begins[self.state]()
    end
    if self.coroutines[self.state] ~= nil then
        if self.Log then
            print("Starting Coroutine " .. self.state)
        end
        self.currentCoroutine:Replace(self.coroutines[self.state]())
    else
        self.currentCoroutine:Cancel()
    end
end

function StateMachine:SetCallbacks(state, onUpdate, coroutine, begin, ends)
    self.updates[state] = onUpdate
    self.begins[state] = begin
    self.ends[state] = ends
    self.coroutines[state] = coroutine
end

function StateMachine:ReflectState(from, index, name)
    self.updates[index] = from[name .. "Update"]
    self.begins[index] = from[name .. "Begin"]
    self.ends[index] = from[name .. "End"]
    self.coroutines[index] = from[name .. "Coroutine"]
end

function StateMachine:Update()
    self.ChangedStates = false
    if self.updates[self.state] ~= nil then
        self.state = self.updates[self.state]()
    end
    if self.currentCoroutine.Active then
        self.currentCoroutine:Update()
        if not self.ChangedStates and self.Log and self.currentCoroutine.Finished then
            print("Finished Coroutine " .. self.state)
        end
    end
end

function StateMachine:LogAllStates()
    for i = 1, self.maxStates do
        self:LogState(i)
    end
end

function StateMachine:LogState(index)
    local str = "State " .. index .. ": "
    if self.updates[index] ~= nil then
        str = str .. "U"
    end
    if self.begins[index] ~= nil then
        str = str .. "B"
    end
    if self.ends[index] ~= nil then
        str = str .. "E"
    end
    if self.coroutines[index] ~= nil then
        str = str .. "C"
    end
    print(str)
end

function StateMachine:GetState()
    return self.state
end

function StateMachine:SetState(value)
    if self.Locked or self.state == value then
        return
    end
    if self.Log then
        print("Enter State ", value, " (leaving ", self.state, ")")
    end
    self.ChangedStates = true
    self.PreviousState = self.state
    self.state = value
    if self.PreviousState ~= 0 and self.ends[self.PreviousState] ~= nil then
        if self.Log then
            print("Calling End " .. self.PreviousState)
        end
        self.ends[self.PreviousState]()
    end
    if self.begins[self.state] ~= nil then
        if self.Log then
            print("Calling Begin " .. self.state)
        end
        self.begins[self.state]()
    end
    if self.coroutines[self.state] ~= nil then
        if self.Log then
            print("Starting Coroutine " .. self.state)
        end
        self.currentCoroutine:Replace(self.coroutines[self.state])
    else
        self.currentCoroutine:Cancel()
    end
end

function StateMachine:__index(key)
    if key == "State" then
        return self:GetState()
    end
    return StateMachine[key]
end

function StateMachine:__newindex(key, value)
    if key == "State" then
        self:SetState(value)
    else
        rawset(self, key, value)
    end
end

return StateMachine



