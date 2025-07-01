-- Я просто пытался понять че такое lua
-- мб тут везде неправильный синтаксис
-- вот например, обязательно ли именовать свойства с заглвной буквы или можно привычно маленькие
-- но вообще круто, что есть типизация

type PlayerData = {
	name: string,
	health: number,
	isAlive: boolean
}

local player: PlayerData = {
	name = "player1",
	health = 12,
	isAlive = true
}

type Array<T> = { [number]: T }

function map<T, U>(arr: Array<T>, f(T) -> U): Array<U>
	local result: Array<U> = {}
	for i, v in ipairs(arr) do
		result[i] = f(v)
	end
	return result
end

local arr = {1, 2, 3, 4}

map(arr, function(item): return item * 2)


-- INVENTORY --

type Base = { name: string }
type Potion = Base & { effect: string }
type Weapon = Base & {
	damage: number,
	attack: (Weapon) -> void
 }
type Item = Potion | Weapon
	
type Inventory = {
	items: {Item & { id: number } },
	add: (Inventory, Item) -> (),
	get: (Inventory) -> Item?,
	has: (Inventory, number) -> boolean
}

function createInventory(): Inventory
	return {
		items = {},
		add = function(self, item)
			if #self.items == 0 then
				local newItem = table.clone(item)
				newItem.id = 1
				table.insert(self.items, newItem)
			else
				local newId = self.items[#self.items].id + 1
				local newItem = table.clone(item)
				newItem.id = newId
				table.insert(self.items, newItem)
			end
		end,
		get = function(self, index)
			return self.items[index]
		end,
		has = function(self, id)
			for i in #self.items do
				if self.items[i].id == id then 
					return true
			end
			return false
		end
	}
end

local potion: Potion = { name = "Health Potion", effect = "Restore 50 HP"}
local weapon: Weapon = { 
	name = "Sword", 
	damage = 12, 
	attack = function(self)
		print(`Attack: ${self.damage}`) 
	end
}

local inventory = createInventory<Item>()
inventory:add(potion)
inventory:add(weapon)

if inventory:has(1):
	local item = inventory:get(1)
	if (item :: Potion) then
		print((item :: Potion).effect)
	end
end

if inventory:has(2):
	local item = inventory:get(2)
	if (item :: Weapon) then
		print((item :: Weapon):attack())
	end
end