local dashcamActive = false
local cameraHandle = nil

local screenEffect = "HeistLocate"

RegisterCommand("dashcam", function(source, args, raw)
    if dashcamActive then
        DisableDash()
    else
        if IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
            EnableDash()
        end
    end
end, false)

Citizen.CreateThread(function()
    while true do
        if dashcamActive then

            if dashcamActive and not IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
                DisableDash()
                dashcamActive = false
            end

            if IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) and dashcamActive then
                UpdateDashcam()
            end

        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if dashcamActive then
            local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
            local bonPos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "windscreen"))
            local vehRot = GetEntityRotation(vehicle, 0)
            SetCamCoord(cameraHandle, bonPos.x, bonPos.y, bonPos.z)
            SetCamRot(cameraHandle, vehRot.x, vehRot.y, vehRot.z, 0)
        end
        Citizen.Wait(0)
    end
end)

function EnableDash()
    StartScreenEffect(screenEffect, -1, false)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    RenderScriptCams(1, 0, 0, 1, 1)
    cameraHandle = cam
    SendNUIMessage({
        type = "enabledash"
    })
    dashcamActive = true
end

function DisableDash()
    StopScreenEffect(screenEffect)
    RenderScriptCams(0, 0, 1, 1, 1)
    DestroyCam(cameraHandle, false)
    SendNUIMessage({
        type = "disabledash"
    })
    dashcamActive = false
end

function UpdateDashcam()
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
    local gameTime = GetGameTimer()
    local year, month, day, hour, minute, second = GetLocalTime()
    local unitNumber = GetPlayerServerId(PlayerId())
    local unitName = GetPlayerName(PlayerId())
    local unitSpeed = nil

    if DashcamConfig.useMPH then
        unitSpeed = GetEntitySpeed(vehicle) * 2.23694
    else
        unitSpeed = GetEntitySpeed(vehicle) * 3.6
    end

    SendNUIMessage({
        type = "updatedash",
        info = {
            gameTime = gameTime,
            clockTime = {year = year, month = month, day = day, hour = hour, minute = minute, second = second},
            unitNumber = unitNumber,
            unitName = unitName,
            unitSpeed = unitSpeed,
            useMPH = DashcamConfig.useMPH
        }
    })
end