FleetManager = {}
FleetManager.MOD_DIR = g_currentModDirectory
FleetManager.debug = true
FleetManager.gui = nil

if FleetManager.debug then
    print("FleetManager: Loading... MOD_DIR=" .. tostring(FleetManager.MOD_DIR))
end

local function sourceFile(relativePath)
    local fullPath = Utils.getFilename(relativePath, FleetManager.MOD_DIR)
    if fileExists(fullPath) then
        source(fullPath)
        if FleetManager.debug then print("FleetManager: Sourced " .. relativePath) end
    else
        print("FleetManager: ERROR - Could not find " .. fullPath)
    end
end

sourceFile("gui/FleetManagerFrame.lua")
sourceFile("gui/FleetManagerGui.lua")

function FleetManager:loadMap(name)
    if self.debug then print("FleetManager: loadMap initializing...") end

    self:loadGui()

    if VehicleSystem ~= nil and VehicleSystem.getNextEnterableVehicle ~= nil then
        VehicleSystem.getNextEnterableVehicle = Utils.overwrittenFunction(
            VehicleSystem.getNextEnterableVehicle,
            FleetManager.getNextEnterableVehicle
        )
        if self.debug then print("FleetManager: TAB override installed") end
    end
end

function FleetManager:loadGui()
    g_gui:loadProfiles(Utils.getFilename("gui/guiProfiles.xml", self.MOD_DIR))

    local vehicleFrame = FleetManagerFrame:new(g_i18n)

    FleetManager.gui = FleetManagerGui:new(g_messageCenter, g_i18n, g_inputBinding)

    g_gui:loadGui(Utils.getFilename("gui/FleetManagerFrame.xml", self.MOD_DIR), "FleetManagerFrame", vehicleFrame, true)

    g_gui:loadGui(Utils.getFilename("gui/FleetManagerGui.xml", self.MOD_DIR), "FleetManagerGui", FleetManager.gui)

    if self.debug then print("FleetManager: GUI loaded") end
end

function FleetManager:getNextEnterableVehicle(superFunc, currentVehicle, direction)
    if g_gui.currentGui == nil then
        if FleetManager.debug then print("FleetManager: TAB pressed - Opening GUI") end
        g_gui:showGui("FleetManagerGui")
    end
    return currentVehicle
end

function FleetManager:deleteMap()
    if self.debug then print("FleetManager: deleteMap cleanup") end
    FleetManager.gui = nil
end

addModEventListener(FleetManager)
