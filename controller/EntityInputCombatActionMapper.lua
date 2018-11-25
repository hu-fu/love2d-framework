-------------------
--targeting mapper:
-------------------

CombatActionMapper = {}
CombatActionMapper.__index = CombatActionMapper

setmetatable(CombatActionMapper, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function CombatActionMapper.new ()
	local self = setmetatable ({}, CombatActionMapper)
		
		self.COMBAT_REQUEST = require '/combat/COMBAT_REQUEST'
		self.request = nil
	return self
end

function CombatActionMapper:setAttackA()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		--idea: if already set as attB or atkC then set as special attack - cool uh?
		self.request = self.COMBAT_REQUEST.ATTACK_SLOT_A
	end
end

function CombatActionMapper:setAttackB()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.ATTACK_SLOT_B
	end
end

function CombatActionMapper:setAttackC()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.ATTACK_SLOT_C
	end
end

function CombatActionMapper:setAttackMelee()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.ATTACK_MELEE
	end
end

function CombatActionMapper:setAttackRanged()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.ATTACK_RANGED
	end
end

function CombatActionMapper:setAttackIndex()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.ATTACK_INDEX
	end
end

function CombatActionMapper:setAttackCustom()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.ATTACK_CUSTOM
	end
end

function CombatActionMapper:setLockup()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT 
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.LOCKUP
	end
end

function CombatActionMapper:setKnockback()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and 
		self.request ~= self.COMBAT_REQUEST.LOCKUP then
		self.request = self.COMBAT_REQUEST.KNOCKBACK
	end
end

function CombatActionMapper:setSpecialMove()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.SPECIAL_MOVE
	end
end

function CombatActionMapper:setSpecialAttack()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.SPECIAL_ATTACK
	end
end

function CombatActionMapper:setEndAttack()
	if self.request ~= self.COMBAT_REQUEST.END_COMBAT and self.request ~= self.COMBAT_REQUEST.LOCKUP
		and self.request ~= self.COMBAT_REQUEST.KNOCKBACK then
		self.request = self.COMBAT_REQUEST.END_ATTACK
	end
end

function CombatActionMapper:setEndCombat()
	self.request = self.COMBAT_REQUEST.END_COMBAT
end

function CombatActionMapper:resetMapping()
	self.request = nil
end