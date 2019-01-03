---------------
--Sound System:
---------------
--TODO: fade out/fade in (can be applied via external script)
--TODO: distance effects
--TODO: apply sound effect to audio (not needed?)

local SoundSystem = {}

---------------
--Dependencies:
---------------

require '/sound/SoundObjects'
SoundSystem.SOUND = require '/sound/SOUND'
SoundSystem.SOUND_TYPE = require '/sound/SOUND_TYPE'
SoundSystem.SOUND_REQUEST = require '/sound/SOUND_REQUEST'
SoundSystem.SOUND_ASSET = require '/sound/SOUND_ASSET'
SoundSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
SoundSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'

-------------------
--System Variables:
-------------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
SoundSystem.id = SYSTEM_ID.SOUND

SoundSystem.BGM_VOLUME = 0.0
SoundSystem.EFFECT_VOLUME = 0.0
SoundSystem.LISTEN_RADIUS = 1000		--in px
SoundSystem.DISTANCE_MULTIPLIER = 0.1

SoundSystem.soundDataTable = {}
SoundSystem.audioSourceTable = {}
SoundSystem.activePlayers = {}
SoundSystem.soundListener = nil

SoundSystem.soundPlayerObjectPool = SoundPlayerObjectPool.new(50, false)

SoundSystem.requestStack = {}

SoundSystem.eventDispatcher = nil
SoundSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

SoundSystem.eventMethods = {

	[1] = {
		[1] = function(request)
			--set sound config
			--TODO: changes sound values according to request
		end,
		
		[2] = function(request)
			--set sound listener entity
			SoundSystem:setSoundListener(request.entityDb)
		end,
		
		[3] = function(request)
			--request into stack
			SoundSystem:addRequestToStack(request)
		end,
		
	}
}

---------------
--Init Methods:
---------------

function SoundSystem:setDefaultVolumeValues()
	SoundSystem.BGM_VOLUME = 0.1
	SoundSystem.EFFECT_VOLUME = 0.1
end

function SoundSystem:setVolumeValues(bgmVolume, effectVolume)
	SoundSystem.BGM_VOLUME = bgmVolume
	SoundSystem.EFFECT_VOLUME = effectVolume
end

function SoundSystem:buildSoundDataTable()
	for soundId, soundAsset in pairs(self.SOUND_ASSET) do
		self.soundDataTable[soundId] = love.sound.newSoundData(soundAsset.filename)
	end
end

function SoundSystem:buildAudioSourceTable()
	for soundId, soundData in pairs(self.soundDataTable) do
		self.audioSourceTable[soundId] = love.audio.newSource(soundData, self.SOUND_ASSET[soundId].sourceType)
	end
end

SoundSystem.soundPlayerObjectPool.getCurrentAvailableObject = function()
	for i=1, #SoundSystem.soundPlayerObjectPool.objectPool do
		local index = ((i + SoundSystem.soundPlayerObjectPool.currentIndex) % 
			#SoundSystem.soundPlayerObjectPool.objectPool) + 1
		if not SoundSystem.soundPlayerObjectPool.objectPool[index].state then
			SoundSystem.soundPlayerObjectPool.currentIndex = index
			return SoundSystem.soundPlayerObjectPool.objectPool[index]
		end
	end
	
	return nil
end

function SoundSystem:setSoundListener(entityDb)
	--not pretty but it does the job
	--assign listener as the player controlled entity
	
	local dbTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.INPUT)
	local entity = nil
	
	for i=1, #dbTable do
		if dbTable[i].state then
			entity = dbTable[i]
			break
		end
	end
	
	if entity then
		if entity.componentTable.hitbox then
			self.soundListener = entity.componentTable.hitbox
		elseif entity.componentTable.spritebox then
			self.soundListener = entity.componentTable.spritebox
		end
	end
end

function SoundSystem:init()
	
end

---------------
--Exec Methods:
---------------

function SoundSystem:update(dt)
	self:resolveRequestStack()
	self:updateSoundPlayers()
end

function SoundSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function SoundSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function SoundSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function SoundSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

SoundSystem.resolveRequestMethods = {
	[SoundSystem.SOUND_REQUEST.PLAY_SOUND] = function(self, request)
		SoundSystem:playSound(request.audioId, request.soundType, request.playerId, request.playerName, 
			request.volumePercentage, request.loop, request.effectId, request.parentEntity,
			request.distance, request.x, request.y)
	end,
	
	[SoundSystem.SOUND_REQUEST.STOP_SOUND] = function(self, request)
		SoundSystem:stopSound(request.playerId, request.playerName)
	end,
	
	[SoundSystem.SOUND_REQUEST.REPEAT_SOUND] = function(self, request)
		SoundSystem:repeatSound(request.playerId, request.playerName)
	end,
	
	[SoundSystem.SOUND_REQUEST.PAUSE_SOUND] = function(self, request)
		SoundSystem:pauseSound(request.playerId, request.playerName)
	end,
	
	[SoundSystem.SOUND_REQUEST.RESUME_SOUND] = function(self, request)
		SoundSystem:resumeSound(request.playerId, request.playerName)
	end,
	
	[SoundSystem.SOUND_REQUEST.STOP_ALL] = function(self, request)
		SoundSystem:stopAll()
	end,
	
	[SoundSystem.SOUND_REQUEST.SET_VOLUME] = function(self, request)
		SoundSystem:changeVolume(request.playerId, request.playerName, request.volumePercentage)
	end,
	
	[SoundSystem.SOUND_REQUEST.STOP_BGM] = function(self, request)
		SoundSystem:stopCurrentBgm()
	end,
}

function SoundSystem:playSound(audioId, soundType, playerId, playerName, volume, loop, effectId, 
	parentEntity, distance, x, y)
	
	local audioSource = self:getAudioSourceById(audioId)
	local soundPlayer = self.soundPlayerObjectPool:getCurrentAvailableObject()
	
	if audioSource and soundPlayer then
		soundPlayer.id = playerId
		soundPlayer.name = playerName
		soundPlayer.state = true
		soundPlayer.source = audioSource:clone()
		soundPlayer.soundType = soundType
		soundPlayer.volume = volume
		soundPlayer.effect = effectId
		
		soundPlayer.parentEntity = parentEntity
		soundPlayer.distance = distance
		soundPlayer.x = x
		soundPlayer.y = y
		
		self:setVolume(soundPlayer)
		
		table.insert(self.activePlayers, soundPlayer)
		soundPlayer.source:setLooping(loop)
		soundPlayer.source:play()
	end
end

function SoundSystem:setVolume(soundPlayer)
	if soundPlayer.soundType == self.SOUND_TYPE.BGM then
		self:setBgmVolume(soundPlayer)
	else
		self:setEffectVolume(soundPlayer)
	end
end

function SoundSystem:setBgmVolume(soundPlayer)
	soundPlayer.source:setVolume(self.BGM_VOLUME*soundPlayer.volume)
end

function SoundSystem:setEffectVolume(soundPlayer)
	if soundPlayer.distance then
		self:setVolumeBySpatialInfo(soundPlayer)
	else
		soundPlayer.source:setVolume(self.EFFECT_VOLUME*soundPlayer.volume)
	end
end

function SoundSystem:stopSound(playerId, playerName)
	local soundPlayer = self:getActiveSoundPlayer(playerId, playerName)
	
	if soundPlayer then
		soundPlayer.source:stop()
	end
end

function SoundSystem:repeatSound(playerId, playerName)
	local soundPlayer = self:getActiveSoundPlayer(playerId, playerName)
	
	if soundPlayer then
		soundPlayer.source:stop()
		soundPlayer.source:play()
	end
end

function SoundSystem:pauseSound(playerId, playerName)
	local soundPlayer = self:getActiveSoundPlayer(playerId, playerName)
	
	if soundPlayer then
		soundPlayer.source:pause()
	end
end

function SoundSystem:resumeSound(playerId, playerName)
	local soundPlayer = self:getActiveSoundPlayer(playerId, playerName)
	
	if soundPlayer then
		soundPlayer.source:resume()
	end
end

function SoundSystem:stopAll()
	for i=1, #self.activePlayers do
		self.activePlayers[i].source:stop()
	end
end

function SoundSystem:updateSoundPlayers()
	for i=#self.activePlayers, 1, -1 do
		if self.activePlayers[i].state then
			self:updateSoundPlayer(self.activePlayers[i])
		else
			table.remove(self.activePlayers, i)
		end
	end
end

function SoundSystem:updateSoundPlayer(soundPlayer)
	if not soundPlayer.source:isPlaying() then
		soundPlayer.state = false
	elseif soundPlayer.soundType == self.SOUND_TYPE.EFFECT and soundPlayer.distance then
		self:setVolumeBySpatialInfo(soundPlayer)
	end
end

function SoundSystem:deactivateSoundPlayer(soundPlayer)
	soundPlayer.state = false
	soundPlayer.source = nil
	soundPlayer.soundType = nil
	soundPlayer.loop = false
	soundPlayer.effect = nil
	soundPlayer.parentEntity = nil
	soundPlayer.distance = false
	soundPlayer.x = 0
	soundPlayer.y = 0
	soundPlayer.volume = 0
end

function SoundSystem:getAudioSourceById(id)
	return self.audioSourceTable[id]
end

function SoundSystem:getActiveSoundPlayer(playerId, playerName)
	if playerId then
		return self:getSoundPlayerById(playerId)
	elseif playerName then
		return self:getSoundPlayerByName(playerName)
	end
end

function SoundSystem:stopCurrentBgm()
	for i=1, #self.activePlayers do
		if self.activePlayers[i].id == self.SOUND_TYPE.BGM then
			self.activePlayers[i].source:stop()
		end
	end
end

function SoundSystem:getSoundPlayerById(id)
	for i=1, #self.activePlayers do
		if self.activePlayers[i].id == id then
			return self.activePlayers[i]
		end
	end
end

function SoundSystem:getSoundPlayerByName(name)
	for i=1, #self.activePlayers do
		if self.activePlayers[i].name == name then
			return self.activePlayers[i]
		end
	end
end

function SoundSystem:changeVolume(playerId, playerName, volume)
	local soundPlayer = self:getActiveSoundPlayer(playerId, playerName)
	
	if soundPlayer then
		soundPlayer.volume = volume
		self:setVolume(soundPlayer)
	end
end

function SoundSystem:setVolumeBySpatialInfo(soundPlayer)
	if soundPlayer.parentEntity then
		soundPlayer.source:setVolume(self:getVolumeByDistance(soundPlayer.parentEntity.x, 
			soundPlayer.parentEntity.y, soundPlayer.volume))
	else
		soundPlayer.source:setVolume(self:getVolumeByDistance(soundPlayer.x, soundPlayer.y, 
			soundPlayer.volume))
	end
end

function SoundSystem:getVolumeByDistance(x, y, volume)
	--TODO
	return self.EFFECT_VOLUME*volume
end

----------------
--Return Module:
----------------

SoundSystem:setDefaultVolumeValues()
SoundSystem:buildSoundDataTable()
SoundSystem:buildAudioSourceTable()

return SoundSystem