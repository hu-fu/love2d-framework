-----------------
--Action Methods:
-----------------

ACTION_METHODS = {}

ACTION_METHODS.ACTION_CALL_TYPES = require '/action/ACTION_CALL_TYPE'

function ACTION_METHODS:resetComponent(component)
	component.currentTime = 0
	component.updatePoint = 0
	component.currentMethodIndex = 1
	self:resetMethodThreads(component)
end

function ACTION_METHODS:resetMethodThreads(component)
	for i=#component.methodThreads, 1, -1 do
		table.remove(component.methodThreads, i)
	end
end

function ACTION_METHODS:resetAction(component)
	self:resetComponent(component)
	self:startAction(component)
end

function ACTION_METHODS:startAction(component)
	if component.action then
		if #component.action.methods > 0 then
			component.updatePoint = component.action.methods[1].callTime
		else
			component.updatePoint = components.action.totalTime
		end
	end
end

function ACTION_METHODS:endAction(system, component)
	self:resetComponent(component)
	component.action = nil
	system:onActionEnd(component)	--ouch!
end

function ACTION_METHODS:onActionEnd(component)
	--virtual
end

function ACTION_METHODS:updateAction(system, component)
	local action = component.action
	
	while component.currentMethodIndex <= #action.methods and 
		action.methods[component.currentMethodIndex].callTime <= component.currentTime do
		
		self:runActionMethod(system, component, action.methods[component.currentMethodIndex])
		component.updatePoint = action.methods[component.currentMethodIndex].callTime
		component.currentMethodIndex = component.currentMethodIndex + 1
	end
end

function ACTION_METHODS:playAction(dt, system, component)
	
	component.currentTime = component.currentTime + dt
	
	if component.currentTime >= component.action.totalTime then
		self:updateAction(system, component)
		
		if component.action.replay then
			self:resetAction(component)
		else
			self:endAction(system, component)
		end
	else
		self:runMethodThreads(dt, system, component, component.methodThreads)
		
		if component.currentTime >= component.updatePoint then
			self:updateAction(system, component)
		end
	end
end

function ACTION_METHODS:runMethodThreads(dt, system, component, threadList)
	for i=1, #threadList do
		self:runMethodThread(dt, system, component, threadList[i], dt)
	end
end

function ACTION_METHODS:runMethodThread(dt, system, component, actionMethod)
	if (component.currentTime % actionMethod.timeFrequency) - dt <= 0 then	--absolute genius
		self.runActionMethodByCallType[self.ACTION_CALL_TYPES.ONCE](system, component, actionMethod)
	end
end

function ACTION_METHODS:runActionMethod(system, component, actionMethod)
	self.runActionMethodByCallType[actionMethod.callType](system, component, actionMethod)
end

ACTION_METHODS.runActionMethodByCallType = {
	[ACTION_METHODS.ACTION_CALL_TYPES.ONCE] = function(system, component, actionMethod)
		--regular single method call:
		actionMethod.method(component.action, system, component)
	end,
	
	[ACTION_METHODS.ACTION_CALL_TYPES.THREAD_START] = function(system, component, actionMethod)
		--add to thread:
		table.insert(component.methodThreads, actionMethod)
	end,
	
	[ACTION_METHODS.ACTION_CALL_TYPES.THREAD_STOP] = function(system, component, actionMethod)
		--[[remove from thread (what this doesn't work it cant work what the fuck are you even doing):
		for i=#component.methodThreads, 1, -1 do
			if component.methodThreads[i].method == actionMethod.method then
				table.remove(component.methodThreads, i)
				break
			end
		end
		]]
		
		for i=#component.methodThreads, 1, -1 do
			if component.methodThreads[i].id == actionMethod.id then
				table.remove(component.methodThreads, i)
				break
			end
		end
	end,
	
	[ACTION_METHODS.ACTION_CALL_TYPES.NONE] = function(system, component, actionMethod)
		--ignore
	end
}

return ACTION_METHODS