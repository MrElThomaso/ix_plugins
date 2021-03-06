ITEM.name = "Casual Cloth"
ITEM.desc = "A Casual Cloth for the male."
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.sheet = {1, 15} -- sheetdata [1]<male> index [2]<fancy>
ITEM.width = 1
ITEM.height = 2
ITEM.isCloth = true

if (CLIENT) then
	function ITEM:PaintOver(item, w, h)
		if (item:GetData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

ITEM:Hook("drop", function(item)
	if (item:getData("equip") == true) then
		local model = string.lower(item.player:GetModel())
		local modelData = RESKINDATA[model]

		item:setData("equip", false)
		item.player:EmitSound("items/ammo_pickup.wav", 80)
		item.player:SetSubMaterial(modelData[1] - 1, "")
	end
end)

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		local model = string.lower(item.player:GetModel())
		local modelData = RESKINDATA[model]

		if (!model) then
			item.player:NotifyLocalized("modelNotSupported", "texcoord")
			
			return false
		end

		item.player:SetSubMaterial(modelData[1] - 1, "")
		item.player:EmitSound("items/ammo_pickup.wav", 80)
		item:setData("equip", false)
		
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:GetData("equip") == true)
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	onRun = function(item)
		local inv = item.player:GetChar():GetInv()

		for k, v in pairs(inv:GetItems()) do
			if (v.id != item.id) then
				local itemTable = ix.item.Instances[v.id]

				if (itemTable.IsCloth and itemTable:GetData("equip")) then
					item.player:notify("You're already wearing cloth")

					return false
				end
			end
		end

		local model = string.lower(item.player:GetModel())
		local modelData = RESKINDATA[model]

		if (!model) then
			item.player:NotifyLocalized("modelNotSupported", "texcoord")
			
			return false
		end

		if (modelData.sheets == item.sheet[1]) then
			local sheet = CITIZENSHEETS[item.sheet[1]][item.sheet[2]]

			if (!sheet) then
				item.player:NotifyLocalized("notValid", "sheetdata")
				return false
			end

			item.player:SetSubMaterial(modelData[1] - 1, sheet)
		else
			item.player:NotifyLocalized("modelNotSupported", "sheetdata")

			return false
		end

		item.player:EmitSound("items/ammo_pickup.wav", 80)
		item:SetData("equip", true)

		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:GetData("equip") != true)
	end
}

ITEM.functions.Preview = {
	tip = "previewTip",
	icon = "icon16/camera.png",
	onRun = function(item)
		netstream.Start(item.player, "ixCitizenPreview", item.sheet)
		return false
	end,
}

function ITEM:onCanBeTransfered(oldInventory, newInventory)
	return !self:GetData("equip")
end
