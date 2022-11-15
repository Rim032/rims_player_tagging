util.AddNetworkString("rpt_is_user_fully_auth")
util.AddNetworkString("rpt_user_fully_auth")

util.AddNetworkString("rpt_get_user_ui_file")
util.AddNetworkString("rpt_send_user_ui_file")

util.AddNetworkString("rpt_user_reportA")


local auto_ban_plys = false
local is_family_sharing_allowed = true

net.Receive("rpt_is_user_fully_auth", function(len, ply)
    if ply:IsFullyAuthenticated() == true and ply:IsConnected() == true and ply:IsValid() == true then
        net.Start("rpt_user_fully_auth")
        net.Send(ply)
    end
end)

net.Receive("rpt_user_reportA", function(len, ply)
    if IsValid(ply) == false then return end
    if ply:OwnerSteamID64() ~= ply:SteamID64() and is_family_sharing_allowed == true then return end 
    
    print("Player:  " ..ply:Nick().. " [" ..ply:SteamID().. "] might be circumventing the player tagging system. (Tampering with ID file or ban evading)")

    ban_malicious_ply(ply)
end)

net.Receive("rpt_send_user_ui_file", function(len, ply)
    if !rpt.allowed_ranks[ply:GetUserGroup()] then return end
    if IsValid(ply) == false then return end

    ui_file = net.ReadString()
    return ui_file
end)



function ban_malicious_ply(ply)
    if ply:IsValid() == false then return end
    if ply:IsBot() then return end

    if ply:OwnerSteamID64() ~= ply:SteamID64() and is_family_sharing_allowed == true then return end 

    if auto_ban_plys == true then
        print("Player:  " ..ply:Nick().. " [" ..ply:SteamID().. "] has been automatically banned for file tampering or ban evading.")
        log_ply_ui_info(ply)

        ply:Ban(0, false)
        ply:Kick("[Auto-Banned] - Duration: Permanently - Reason: Likely ban evading.")
    end
end

function log_ply_ui_info(ply)
    if ply:IsValid() == false then return end
    if ply:IsBot() then return end

    if ply:SteamID64() == nil then return end
    if ply:SteamID() == nil then return end

    local ply_idA = ply:SteamID64()
    local ply_idB = ply:SteamID()

    local ply_file_info = {ply_idA, ply_idB}

    if file.Exists("rpt_ui_list.txt", "data") == false then
        file.Write("rpt_ui_list.txt", table.concat(ply_file_info, " ", 1, 2))
        file.Append("rpt_ui_list.txt", "\n")
    else
        if string.match(tostring(file.Read("rpt_ui_list.txt", "data")), table.concat(ply_file_info, " ", 1, 2), 1) == nil then
            file.Append("rpt_ui_list.txt", table.concat(ply_file_info, " ", 1, 2))
            file.Append("rpt_ui_list.txt", "\n")
        end
    end
end



concommand.Add("rpt_autoban_plys", function( ply, cmd, args)
    if !rpt.allowed_ranks[ply:GetUserGroup()] then return end

    if ply:IsValid() == false then return end
    if ply:IsBot() then return end

    if args[1] == "1" or args[1] == "true" then
        auto_ban_plys = true
    else
        auto_ban_plys = false
    end

    ply:PrintMessage(HUD_PRINTCONSOLE, "Auto-ban Players: " ..tostring(auto_ban_plys).. "\n")

    return auto_ban_plys
end)

concommand.Add("rpt_family_sharing_allowed", function( ply, cmd, args)
    if !rpt.allowed_ranks[ply:GetUserGroup()] then return end

    if ply:IsValid() == false then return end
    if ply:IsBot() then return end

    if args[1] == "0" or args[1] == "false" then
        is_family_sharing_allowed = false
    else
        is_family_sharing_allowed = true
    end

    ply:PrintMessage(HUD_PRINTCONSOLE, "Allowing family sharing players: " ..tostring(is_family_sharing_allowed).. "\n")

    return is_family_sharing_allowed
end)

concommand.Add("rpt_compare_tags", function( ply, cmd, args)
    if !rpt.allowed_ranks[ply:GetUserGroup()] then return end

    if ply:IsValid() == false then return end
    if ply:IsBot() then return end

    for k, v in pairs(player.GetAll()) do
        if args[1] == v:Name() then
            net.Start("rpt_get_user_ui_file")
            net.Send(v)

            local ui_file_correct = true

            if ui_file ~= util.Base64Encode((ply:SteamID64().. " " ..ply:SteamID())) then
                ui_file_correct = false
            end

            if ui_file ~= nil then
                ply:PrintMessage(HUD_PRINTCONSOLE, "\nPlayer: " ..v:Nick().. " - Unique Identifier file contents: \"" ..ui_file.. "\"")
            else
                ply:PrintMessage(HUD_PRINTCONSOLE, "\nPlayer: " ..v:Nick().. " - Unique Identifier file contents: \" N/A (error reading file - TRY AGAIN) \"")
            end
            ply:PrintMessage(HUD_PRINTCONSOLE, "Player: " ..v:Nick().. " - Is the file correct/Not tampered?: " ..tostring(ui_file_correct).. "\n")
        end
    end

    if args[1] == nil then
        ply:PrintMessage(HUD_PRINTCONSOLE, "\n   -Input a player's name (as the argument) to get details about their files and if there's tampering/attempted evasion.")
        ply:PrintMessage(HUD_PRINTCONSOLE, "   -Ex: rpt_compare_tags John24.\n")
    end
end)