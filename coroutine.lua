require("class")
require("runLater")

Coroutine = {}
Coroutine.__index = Coroutine


function Coroutine:new(functionCall, removeOnComplete)
    self.RemoveOnComplete = removeOnComplete or true
    self.enumerators = {}
    self.paused = false
    self.Active = true
    self.Finished = false
    self.waitTimer = 0
    self.ended = false
    self.Current = 0
    self.resume = coroutine.resume
    table.insert(self.enumerators, functionCall)
    if functionCall then
        self.Active = true
        self.Visible = false
        table.insert(self.enumerators, functionCall)
    else
        self.Active = false
        self.Visible = false
    end
    return self
end



-- define a function to push a new coroutine onto the stack
function Coroutine:Push(func)
    table.insert(self.enumerators, func)
end

-- define a function to pop the top coroutine off the stack
function Coroutine:Pop()
    table.remove(self.enumerators, #self.enumerators)
end

function Coroutine:Peek()
    if (#self.enumerators <= 0) then
        return print("Coroutine stack is empty.")
    end
    return (#self.enumerators - 1)
end

-- define a function to update the current coroutine

function Coroutine:Update()
        self:orig_Update()
end

function Coroutine:Cancel()
    self.Active = false
    self.Finished = true
    self.waitTimer = 0
    self.enumerators = {}
    self.ended = true
end

function Coroutine:Replace(functionCall)
    self.Active = true
    self.Finished = false
    self.waitTimer = 0
    self.enumerators = {}
    table.insert(self.enumerators, coroutine.create(functionCall))
    self.ended = true
end

function Coroutine:Current()
	if (#self.enumerators <= 0) then
		return nil;
	end
	return Coroutine:Peek();
end

function Coroutine:Jump()
    self.waitTimer = 0
end

function Coroutine:Pause()
    self.paused = true
end

function Coroutine:Resume()
    self.paused = false
end

function Coroutine:Wait(num)
    self.waitTimer = num
    coroutine.yield()
end

function Coroutine:orig_Update()
    self.ended = false
    if (self.waitTimer > 0.0) then
        self.waitTimer = self.waitTimer - (1/60)
    elseif (#self.enumerators <= 0) then
        return
    end
    local enumerator = self.enumerators[#self.enumerators]
    if self.Finished then
        self.Active = false
        return
    end

    if coroutine.status(self.enumerators[#self.enumerators]) == "dead" then
        self.ended = true
        self.Finished = true
        return self.resume(self.enumerators[#self.enumerators])
    end

    if coroutine.status(self.enumerators[#self.enumerators]) == "suspended" then
        if self.waitTimer <= 0 then
            self.resume(self.enumerators[#self.enumerators])
        end
    end
end


function MoveNext(enumerator)
    local position = -1
    position = position + 1
    return (position < #enumerator)
end
