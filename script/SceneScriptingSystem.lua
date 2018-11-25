----------------------
--Scene Script System:
----------------------

local SceneScriptSystem = {}

---------------
--Dependencies:
---------------

require '/script/ScriptObjects'
SceneScriptSystem.SCRIPT = require '/script/SCENE_SCRIPT'
SceneScriptSystem.SCRIPT_ASSETS = require '/script/SCENE_SCRIPT_ASSET'

-------------------
--System Variables:
-------------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
SceneScriptSystem.id = SYSTEM_ID.SCENE_SCRIPT

SceneScriptSystem.assetsFolderPath = '/script/asset/'

SceneScriptSystem.scriptTable = {}	--?

--set all needed systems below (no shame):
SceneScriptSystem.flagSystem = nil
SceneScriptSystem.entitySystem = nil
SceneScriptSystem.areaSystem = nil

SceneScriptSystem.eventListenerList = {}
SceneScriptSystem.eventDispatcher = nil

----------------
--Event Methods:
----------------

SceneScriptSystem.eventMethods = {

	[1] = {
		[1] = function(request)
			--request.sceneObj.components.script.scriptIdList
			SceneScriptSystem:initScene(request.sceneObj)
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

function SceneScriptSystem:init()
	self:resetScriptTable()
end

function SceneScriptSystem:setDependencies(flagSystem, entitySystem, areaSystem)
	self:setFlagSystem(flagSystem)
	self:setEntitySystem(entitySystem)
	self:setAreaSystem(areaSystem)
end

function SceneScriptSystem:setFlagSystem(flagSystem)
	self.flagSystem = flagSystem
end

function SceneScriptSystem:setEntitySystem(entitySystem)
	self.entitySystem = entitySystem
end

function SceneScriptSystem:setAreaSystem(areaSystem)
	self.areaSystem = areaSystem
end

---------------
--Exec Methods:
---------------

function SceneScriptSystem:initScene(scene)
	self:resetScriptTable()
	self:initScripts(scene.components.script.scriptIdList)
end

function SceneScriptSystem:main(dt)
	self:runScripts(dt)
end

function SceneScriptSystem:loadScriptAsset(scriptId)
	local scriptAsset = self.SCRIPT_ASSETS[scriptId]
	if scriptAsset ~= nil then
		local path = self.assetsFolderPath .. scriptAsset.filepath
		local assetFile = require(path)
		return assetFile
	end
	return nil
end

function SceneScriptSystem:resetScriptTable()
	self.scriptTable = {}
end

function SceneScriptSystem:destroyScript(scriptId)
	for i=1, #self.scriptTable do
		if self.scriptTable[i].scriptId == scriptId then
			table.remove(self.scriptTable, i)
			return true
		end
	end
end

function SceneScriptSystem:runScripts(dt)
	for i=1, #self.scriptTable do
		self:runScript(self.scriptTable[i], dt)
	end
end

function SceneScriptSystem:runScript(scriptPlayer, dt)
	for i=1, #scriptPlayer.methodThreads do
		scriptPlayer.methodThreads[i](self, scriptPlayer, dt)
	end
end

function SceneScriptSystem:initScripts(scriptIdList)
	for i=1, #scriptIdList do
		self:initScript(scriptIdList[i])
	end
end

function SceneScriptSystem:initScript(scriptId)
	local scriptAsset = self:loadScriptAsset(scriptId)
	
	if scriptAsset then
		local scriptPlayer = ScriptPlayer.new(scriptAsset['id'], scriptAsset)
		scriptPlayer.initMethod(self, scriptPlayer)
		table.insert(self.scriptTable, scriptPlayer)
	end
end

----------------
--Return Module:
----------------

return SceneScriptSystem