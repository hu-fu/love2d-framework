----------------
--Flag database:
----------------

FlagDatabase = {}
FlagDatabase.__index = FlagDatabase

setmetatable(FlagDatabase, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function FlagDatabase.new (flagEnum)
	local self = setmetatable ({}, FlagDatabase)
		self.stateTable = {}
		self:buildStateTable(flagEnum)
	return self
end

function FlagDatabase:buildStateTable(flagEnum)
	for flagName, flagId in pairs(flagEnum) do
		self.stateTable[flagId] = false
	end
end

function FlagDatabase:modifyAllFlags(stateModifier)
	for flagId, state in pairs(stateModifier) do
		self.stateTable[flagId] = state
	end
end

function FlagDatabase:modifyFlag(flagId, state)
	self.stateTable[flagId] = state
end

function FlagDatabase:getStateTable()
	return self.stateTable
end