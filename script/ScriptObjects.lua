----------------
--Script Player:
----------------

ScriptPlayer = {}
ScriptPlayer.__index = ScriptPlayer

setmetatable(ScriptPlayer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ScriptPlayer.new (scriptId, scriptFile)
	local self = setmetatable ({}, ScriptPlayer)
		self.scriptId = scriptId
		self.initMethod = nil
		self.variables = nil
		self.methodThreads = {}
		
		self:setScript(scriptFile)
	return self
end

function ScriptPlayer:setScript(scriptFile)
	self.initMethod = scriptFile['init']
	self.variables = scriptFile['variables']
	
	table.sort(scriptFile['threads'], function(a, b) return a.priority < b.priority end)
	
	for i=1, #scriptFile['threads'] do
		table.insert(self.methodThreads, scriptFile['threads'][i].method)
	end
end