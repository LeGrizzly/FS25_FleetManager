FleetManagerGui = {}
local FleetManagerGui_mt = Class(FleetManagerGui, TabbedMenu)

function FleetManagerGui:new(messageCenter, l10n, inputManager)
    local self = TabbedMenu.new(nil, FleetManagerGui_mt, messageCenter, l10n, inputManager)
    self.messageCenter = messageCenter
    self.l10n = l10n
    self.inputManager = g_inputBinding
    return self
end

function FleetManagerGui:onGuiSetupFinished()
    FleetManagerGui:superClass().onGuiSetupFinished(self)

    self.clickBackCallback = self:makeSelfCallback(self.onButtonBack)

    self.pageVehicles:initialize()
    self:setupPages()
    self:setupMenuButtonInfo()
end

function FleetManagerGui:setupPages()
    local iconPath = Utils.getFilename("images/MenuIcon.dds", FleetManager.MOD_DIR)

    self:registerPage(self.pageVehicles, 1)
    self:addPageTab(self.pageVehicles, iconPath, GuiUtils.getUVs({0, 0, 1024, 1024}))
    self:rebuildTabList()
end

function FleetManagerGui:setupMenuButtonInfo()
    local onButtonBackFunction = self.clickBackCallback

    self.defaultMenuButtonInfo = {
        {
            inputAction = InputAction.MENU_BACK,
            text = g_i18n:getText("button_back"),
            callback = onButtonBackFunction
        }
    }

    self.defaultMenuButtonInfoByActions[InputAction.MENU_BACK] = self.defaultMenuButtonInfo[1]

    self.defaultButtonActionCallbacks = {
        [InputAction.MENU_BACK] = onButtonBackFunction,
    }
end

function FleetManagerGui:exitMenu()
    if FleetManager.debug then print("FleetManagerGui:exitMenu") end
    self:changeScreen()
end
