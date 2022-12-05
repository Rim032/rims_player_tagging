rpt = rpt or {}
rpt.version = 1.14
rpt.build_date = "12/5/2022"

rpt.allowed_ranks = {
    ["owner"] = true,
    ["founder"] = true,
    ["superadmin"] = true,
    ["admin"] = true,
}


if SERVER then
    include("rpt/server/sv_rpt_main.lua")
    AddCSLuaFile("autorun/client/cl_rpt_main.lua")
end


if CLIENT then
    include("autorun/client/cl_rpt_main.lua")
end

hook.Add("PostGamemodeLoaded", "rpt_sv_backup_load", function()
    timer.Simple(10, function()
        if SERVER then
            include("rpt/server/sv_rpt_main.lua")
        
            MsgC(Color(69, 140, 255), "##[Rim's Player Tagging: Server Initialized]##\n")
        end
    end)
end)
