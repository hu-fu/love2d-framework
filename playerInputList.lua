-----------------------------------
--Key/Input ID List (test version):
-----------------------------------

keyInputIdMap = {}

keyInputIdMap.PRESS = 1
keyInputIdMap.RELEASE = 2

keyInputIdMap.PRESS_UP = 1
keyInputIdMap.RELEASE_UP = 2
keyInputIdMap.PRESS_LEFT = 3
keyInputIdMap.RELEASE_LEFT = 4
keyInputIdMap.PRESS_DOWN = 5
keyInputIdMap.RELEASE_DOWN = 6
keyInputIdMap.PRESS_RIGHT = 7
keyInputIdMap.RELEASE_RIGHT = 8

keyInputIdMap.defaultMapping = {
	['up'] = {PRESS_UP,RELEASE_UP},
	['left'] = {PRESS_LEFT,RELEASE_LEFT},
	['down'] = {PRESS_DOWN,RELEASE_DOWN},
	['right'] = {PRESS_RIGHT,RELEASE_RIGHT}
}

keyInputIdMap.currentMapping = {
	['up'] = {PRESS_UP,RELEASE_UP},
	['left'] = {PRESS_LEFT,RELEASE_LEFT},
	['down'] = {PRESS_DOWN,RELEASE_DOWN},
	['right'] = {PRESS_RIGHT,RELEASE_RIGHT}
}

return keyInputIdMap