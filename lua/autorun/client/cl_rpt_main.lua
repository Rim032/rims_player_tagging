timer.Simple(24, function()
    --print("[RPT DEBUG] PLAYER SPAWNED?! 111")
    net.Start("rpt_is_user_fully_auth")
    net.SendToServer(ply)
end)

net.Receive("rpt_user_fully_auth", function(len, ply)
    --print("[RPT DEBUG] USER AUTH NET MSG RECEIVED!")
    rpt_file_create()
end)

net.Receive("rpt_get_user_ui_file", function(len, ply)
    if file.Exists("pt32_ui.txt", "data") == false then
        rpt_file_create()
    else
        ui_file = file.Read("pt32_ui.txt", "data")
    end

    net.Start("rpt_send_user_ui_file")
        net.WriteString(tostring(ui_file))
    net.SendToServer()
end)

local delay = 24
local last_ocr = -delay

hook.Add("Think", "cl_rpt_think_hk", function()
    local time_psd = CurTime() - last_ocr
    if time_psd > delay then
        rpt_file_tamper_check()
        last_ocr = CurTime()
    end
end)

function rpt_file_create()
    local ply = LocalPlayer()

    if ply:IsValid() == false then return end
    if ply:SteamID64() == nil then return end
    if ply:SteamID() == nil then return end
    --print("[RPT DEBUG] File creation function running!")

    local ply_idA = ply:SteamID64()
    local ply_idB = ply:SteamID()

    local ply_file_msg = {ply_idA, ply_idB}

    if file.Exists("pt32_ui.txt", "data") == false then
        file.Write("pt32_ui.txt", util.Base64Encode(table.concat(ply_file_msg, " ", 1, 2))) //No, I am not trying to legitimately encrypt it. I know Base64 can be easily broken.
    end
end

function rpt_file_tamper_check()
    local ply = LocalPlayer()

    if ply:IsValid() == false then return end
    if ply:SteamID64() == nil then return end
    if ply:SteamID() == nil then return end
    --print("[RPT DEBUG] File tamper check function running!")

    if file.Exists("pt32_ui.txt", "data") == false then 
        rpt_file_create()
    else
        if file.Read("pt32_ui.txt", "data") == "" or file.Read("pt32_ui.txt", "data") == nil or file.Read("pt32_ui.txt", "data") ~= util.Base64Encode((ply:SteamID64().. " " ..ply:SteamID())) then
            net.Start("rpt_user_reportA")
            net.SendToServer(ply)
    
            rpt_file_create()
        end
    end
end

