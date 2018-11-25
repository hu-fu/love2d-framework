--------------
--Scene Stack:
--------------

SceneStack = {}
SceneStack.__index = SceneStack

setmetatable(SceneStack, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SceneStack.new (maxScenes)
	local self = setmetatable ({}, SceneStack)
		--some kind of LIFO stack I don't know I'm not an engineer
		
		self.stack = {}
		self.maxScenes = maxScenes
	return self
end

function SceneStack:pushScene(scene)
	self:removeSceneById(scene.components.main.id)
	
	table.insert(self.stack, 1, scene)
	
	if #self.stack > self.maxScenes then
		self:popScene()
	end
end

function SceneStack:popScene()
	table.remove(self.stack)
end

function SceneStack:getCurrent()
	if #self.stack > 0 then
		return self.stack[1]
	end
	return nil	--default empty scene
end

function SceneStack:getScene(sceneId)
	for i=2, #self.stack do
		if self.stack[i].id == sceneId then
			return self.stack[i]
		end
	end
	return nil
end

function SceneStack:clear()
	for i=#self.stack, -1, 1 do
		self:destroyScene(self.stack[i])
		table.remove(self.stack)
	end
end

function SceneStack:removeScene(scene)
	for i=1, #self.stack do
		if self.stack[i] == scene then
			table.remove(self.stack, i)
			return nil
		end
	end
end

function SceneStack:removeSceneById(sceneId)
	for i=1, #self.stack do
		if self.stack[i].components.main.id == sceneId then
			table.remove(self.stack, i)
			return nil
		end
	end
end

function SceneStack:destroyScene(scene)
	--do stuff
end