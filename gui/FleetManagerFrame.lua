FleetManagerFrame = {}
local FleetManagerFrame_mt = Class(FleetManagerFrame, TabbedMenuFrameElement)

function FleetManagerFrame:new(l10n)
    local self = TabbedMenuFrameElement.new(nil, FleetManagerFrame_mt)
    self.l10n = l10n
    self.vehicles = {}
    return self
end

function FleetManagerFrame:copyAttributes(src)
    FleetManagerFrame:superClass().copyAttributes(self, src)
    self.l10n = src.l10n
end

function FleetManagerFrame:initialize()
    if FleetManager.debug then print("FleetManagerFrame:initialize") end

    self.backButtonInfo = {inputAction = InputAction.MENU_BACK}
    self.activateButtonInfo = {
        profile = "buttonActivate",
        inputAction = InputAction.MENU_ACTIVATE,
        text = self.l10n:getText("button_enterVehicle"),
        callback = function()
            self:onButtonEnterVehicle()
        end
    }
end

function FleetManagerFrame:onGuiSetupFinished()
    FleetManagerFrame:superClass().onGuiSetupFinished(self)
    self.vehicleList:setDataSource(self)
end

function FleetManagerFrame:getMenuButtonInfo()
    local buttons = {}
    table.insert(buttons, self.backButtonInfo)
    table.insert(buttons, self.activateButtonInfo)
    return buttons
end

function FleetManagerFrame:onFrameOpen()
    if FleetManager.debug then print("FleetManagerFrame:onFrameOpen") end

    self.itemDetailsMap:setIngameMap(g_currentMission.hud:getIngameMap())
    FleetManagerFrame:superClass().onFrameOpen(self)

    self:rebuildTable()

    self:setSoundSuppressed(true)
    FocusManager:setFocus(self.vehicleList)
    self:setSoundSuppressed(false)
end

function FleetManagerFrame:onFrameClose()
    FleetManagerFrame:superClass().onFrameClose(self)
    self.vehicles = {}
    self.itemDetailsMap:onClose()
end

function FleetManagerFrame:rebuildTable()
    self.vehicles = {}

    if g_currentMission.vehicleSystem.vehicles ~= nil then
        for _, vehicle in ipairs(g_currentMission.vehicleSystem.vehicles) do
            if vehicle.getIsEnterable ~= nil
                and vehicle:getIsEnterable()
                and vehicle.propertyState ~= VehiclePropertyState.SHOP_ITEM then
                table.insert(self.vehicles, vehicle)
            end
        end
    end

    if FleetManager.debug then
        print("FleetManagerFrame: Found " .. #self.vehicles .. " vehicles")
    end

    self.vehicleList:reloadData()

    if #self.vehicles > 0 then
        self.itemDetailsMap:setVisible(true)
    else
        self.itemDetailsMap:setVisible(false)
    end
end

function FleetManagerFrame:getNumberOfItemsInSection(list, section)
    return #self.vehicles
end

function FleetManagerFrame:populateCellForItemInSection(list, section, index, cell)
    local vehicle = self.vehicles[index]
    if vehicle == nil then return end

    local nameElement = cell:getAttribute("title")
    if nameElement ~= nil then
        nameElement:setText(vehicle:getFullName())
    end

    local iconElement = cell:getAttribute("icon")
    if iconElement ~= nil then
        local storeItem = g_storeManager:getItemByXMLFilename(vehicle.configFileName)
        if storeItem ~= nil and storeItem.imageFilename ~= nil then
            iconElement:setImageFilename(storeItem.imageFilename)
        end
    end

    local distElement = cell:getAttribute("distance")
    if distElement ~= nil then
        local distText = "-"
        if g_currentMission.player ~= nil and g_currentMission.player.rootNode ~= nil and vehicle.rootNode ~= nil then
            local x, y, z = getWorldTranslation(vehicle.rootNode)
            local px, py, pz = getWorldTranslation(g_currentMission.player.rootNode)
            local dist = MathUtil.vector3Length(x-px, y-py, z-pz)
            distText = string.format("%.0f m", dist)
        end
        distElement:setText(distText)
    end
end

function FleetManagerFrame:onListSelectionChanged(list, section, index)
    local vehicle = self.vehicles[index]
    if vehicle == nil then return end

    local x, _, z = getWorldTranslation(vehicle.rootNode)

    if self.itemDetailsMap ~= nil then
        self.itemDetailsMap:setCenterToWorldPosition(x, z)
        self.itemDetailsMap:setMapZoom(7)
        self.itemDetailsMap:setMapAlpha(1)
    end

    if self.locationText ~= nil then
        self.locationText:setText(string.format("%s: %.0f, %.0f", g_i18n:getText("ui_location"), x, z))
    end
end

function FleetManagerFrame:onButtonEnterVehicle()
    if self.vehicleList == nil then return end
    local index = self.vehicleList.selectedIndex
    local vehicle = self.vehicles[index]
    if vehicle ~= nil then
        FleetManager.gui:exitMenu()
        g_localPlayer:requestToEnterVehicle(vehicle)
    end
end
