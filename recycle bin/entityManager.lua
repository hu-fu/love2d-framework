-----------------------------
--entity/module manager(0.1):
-----------------------------

--NEW VERSION -> entitydb.lua

entityManager = {}
entityManager.__index = entityManager

setmetatable(entityManager, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function entityManager.new ()
	local self = setmetatable ({}, entityManager)
		
		self.entityList = {}
		
		self.playerStateList = {}
		
		self.positionList = {}
		self.spriteList1 = {}
		self.spriteList2 = {}
		self.hitboxList = {}
		
		self.idleList = {}
		self.movementList = {}
		self.attackList = {}
		self.interruptList = {}
		
		self.colliderList = {}
		
		self.componentAList = {}
		self.componentBList = {}
		
	return self
end

----------------------
--init/load functions:
----------------------
--Used on loading
--Initialize entities/components from a DB (2D Array)
--can we make this a single function?

function entityManager:loadEntityList(template)
	local indexTable = {}
	local index = 0
	
	for i=1, #template do
		index = #self.entityList + 1
		table.insert(self.entityList, new.entity(index, template[i][1]))
		
		indexTable[template[i][1]] = index
	end
	
	return indexTable
end

function entityManager:loadComponentAList(indexTable, template)
	local index = 0
	local entity = nil
	
	for i=1, #template do
		index = #self.componentAList + 1
		entity = self.entityList[indexTable[template[i][1]]]
		
		table.insert(self.ComponentAList, new.componentA(index, entity, template[i][2]))
	
		entity.componentA = index
	end
end

function entityManager:loadComponentBList(indexTable, template)
	local index = 0
	local entity = nil
	
	for i=1, #template do
		index = #self.componentBList + 1
		entity = self.entityList[indexTable[template[i][1]]]
		
		table.insert(self.ComponentBList, new.componentB(index, entity, self.componentAList[entity.componentA], template[i][2]))
	
		entity.componentB = index
	end
end

---------------------
--Component creation:
---------------------

function entityManager:createEntity(id)
	local index = #self.entityList + 1
	table.insert(self.entityList, entity.new(index, id))
	
	return index
end

function entityManager:createComponentA(entity, template)
	--Check if component already exists (return its index if it does):
	if entity.componentA ~= nil then return entity.componentA end
	
	local index = #self.componentAList + 1
	table.insert(self.componentAList, componentA.new(index, entity, template[1]))
	
	entity.componentA = index
	
	return index
end

function entityManager:createComponentB(entity, template)
	if entity.componentB ~= nil then return entity.componentB end
	
	--Check if dependencies exist (return false if they don't):
	if entity.componentA == nil then
		return false
	end
	
	local componentA = self.componentAList[entity.componentA]
	local index = #self.componentBList + 1
	
	table.insert(self.componentBList, componentB.new(index, entity, componentA, template[1]))
	
	entity.componentB = index
	
	return index
end

--------------------
--Component removal:
--------------------

function entityManager:removeEntity(id, delete)
--delete: true -> deletes entity permanently

	local index = self:getEntityIndex(id)
	
	if index ~= false then
		local entity = self.entityList[self:getEntityIndex(id)]
		
		if entity.componentA ~= nil then self:removeComponentA(entity.componentA) end
		if entity.componentB ~= nil then self:removeComponentB(entity.componentB) end
		
		if delete == true then
			table.remove(self.entityList, index)
			self:setEntityIndex ()
		end
	end
end

function entityManager:removeComponentA(index)
------------------
--USE AS TEMPLATE:
------------------
--Overwrite the element in 'index' with the last element in list and deletes it
	
	--stop if element doesn't exist
	if self.componentAList[index] == nil then return false end
	
	--store reference to element and unregister it in parent entity
	local delElement = self.componentAList[index]
	
	delElement.entity.componentA = nil
	
	--delete dependent components, if they exist:
	if delElement.entity.componentB ~= nil then self:removeComponentB(delElement.entity.componentB) end
	
	--if delElement isn't the last one on list, replace it
	if delElement.index ~= #self.componentAList then
		local lastElement = self.componentAList[#self.componentAList]
		
		delElement.entity = lastElement.entity
		delElement.entity.componentA = index
		delElement.value = lastElement.value
		
		--Set dependent component pointers to match new object:
		if delElement.entity.componentB ~= nil then self.componentBList[delElement.entity.componentB].componentA = delElement end
	end
	
	--delete the last object from list
	self.componentAList[#self.componentAList] = nil
	
	return true
end

function entityManager:removeComponentB(index)

	if self.componentBList[index] == nil then return false end
	
	local delElement = self.componentBList[index]
	
	delElement.entity.componentB = nil
	
	if delElement.index ~= #self.componentBList then
		local lastElement = self.componentBList[#self.componentBList]
		
		delElement.entity = lastElement.entity
		delElement.entity.componentB = index
		delElement.componentA = lastElement.componentA
		delElement.value = lastElement.value
	end
	
	self.componentBList[#self.componentBList] = nil
	
	return true
end

-------------------
--Search functions:
-------------------

function entityManager:getEntityIndex (id)
--given entity.id returns entity index in entityList
	
	for i = 1, #self.entityList do
		if self.entityList[i].id == id then
			return i
		end
	end

	return false
end

------------------------
--Maintenance functions:
------------------------

function entityManager:setEntityIndex ()
--sets the correct index for all entities

	for i=1, #self.entityList do
		self.entityList[i].index = i
	end
end