require '/state/StateInitializer'
require '/scene/GameScene'

local sceneInitializer = GameSceneInitializer.new(1)
local stateInitializer = StateInitializer.new(4)

local stateInitParams = stateInitializer:getInitParameters()
stateInitParams.sceneInitializer = sceneInitializer

return stateInitializer