require '/render/RendererLayer'

local DialogueLayer = RendererLayer.new(0, 0, 12, nil)

DialogueLayer.SEGMENT_TYPE = require '/dialogue/SEGMENT_TYPE'
DialogueLayer.PLAYER_TYPE = require '/dialogue/PLAYER_TYPE'
DialogueLayer.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
DialogueLayer.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'

DialogueLayer.dialogueRenderer = require '/render/DialogueRenderer'

DialogueLayer.portraits = nil
DialogueLayer.entityList = nil
DialogueLayer.activePlayers = nil

function DialogueLayer:update(gameRenderer)
	self:reset()
end

function DialogueLayer:draw(canvas)
	for i=1, #self.activePlayers do
		local player = self.activePlayers[i]
		self.drawByPlayerType[player.type](self, canvas, player)
	end
end

DialogueLayer.drawByPlayerType = {
	[DialogueLayer.PLAYER_TYPE.REAL_TIME_TEXT_ONLY] = function(self, canvas, player)
		--incomplete version - for testing only
		
		if player.currentSegment and player.currentSegment.type == self.SEGMENT_TYPE.TEXT then
			local x, y = 0, 0
			
			if player.parentEntity then
				x, y = player.parentEntity.x, player.parentEntity.y
			end
			
			self.dialogueRenderer:drawRealTimeText(canvas, player.currentSegment.text, x, y)
		end
	end,
	
	[DialogueLayer.PLAYER_TYPE.REAL_TIME_PORTRAIT] = function(self, canvas, player)
		--do later
	end,
	
	[DialogueLayer.PLAYER_TYPE.GUI] = function(self, canvas, player)
		--do much later
	end,
}

function DialogueLayer:reset()
	
end

function DialogueLayer:getEntityById(entityId)
	for i=1, #self.entityList do
		if self.entityList[i].id == entityId then
			return self.entityList[i]
		end
	end
end

function DialogueLayer:setEntityList(entityDb)
	self.entityList = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.MAIN)
end

function DialogueLayer:setActivePlayers(activePlayers)
	self.activePlayers = activePlayers
end

function DialogueLayer:setPortraits(portraits)
	self.portraits = portraits
end

return DialogueLayer