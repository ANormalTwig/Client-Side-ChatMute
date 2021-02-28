if CLIENT then
    --Client
    function findInTable( obj , table )
        local iter
        for k,v in pairs(table) do
            if obj == v then
                return true,iter
            end
        end
        return false,nil
    end
    --returns true and the index of the object if found, otherwise returns false and nil.

    function findByName( plyr )
        local players = player.GetAll()
        for k, ply in ipairs(players) do
            if string.find(string.lower(ply:GetName()), plyr, 1, true) then
                return ply
            end
        end
    end
    --returns first player found based on the given string

    local mutedTable = {}
    local Prefixes = {
        "!",
        "/"
    }

    for i, ply in ipairs( player.GetAll() ) do
        ply:ChatPrint( "Hello World" )
    end

    hook.Add( "OnPlayerChat" , "ChatMute" , function( msgply , text , bTeam , bDead )
        if msgply==LocalPlayer() then
            local Args = string.Explode( " " , text )
            local PRFX = string.Left( Args[1] , 1 )
            local result = findInTable( PRFX , Prefixes )
            if result then
                local Command = Args[1]:sub(2)
                if Command=="pmute" then
                    if table.Count(Args)>1 then
                        
                        table.remove( Args , 1 )
                        local searchQuery = string.lower(table.concat( Args , " " ))
                        local player = findByName( searchQuery )
                        local result = findInTable( player , mutedTable )
                        if result then
                            msgply:ChatPrint( "Player is already muted by you." )
                        elseif player!=LocalPlayer() then
                            table.insert( mutedTable , player )
                            msgply:ChatPrint( "Player muted." )
                        elseif player==LocalPlayer() then
                            msgply:ChatPrint( "Player cannot be yourself." )
                        else
                            msgply:ChatPrint( "Player invalid or doesn't exist." )
                        end
                    else
                        msgply:ChatPrint( "No arguments provided." )
                    end
                elseif Command=="punmute" then
                    table.remove( Args , 1 )
                    local searchQuery = string.lower(table.concat( Args , " " ))
                    local player = findByName( searchQuery )
                    if not player:IsPlayer() then
                        msgply:ChatPrint( "Player invalid or doesn't exist." )
                    end
                    local result,index = findInTable( player , mutedTable )
                    if result then
                        table.remove( mutedTable , index )
                        msgply:ChatPrint( "Player unmuted." )
                    else
                        msgply:ChatPrint( "Player is not muted." )
                    end
                end
            end
        else
            local result = findInTable( msgply , mutedTable )
            if result then
                return true
            end
        end
    end )
else
    --Server
    print("Client-side ChatMute Loaded.")
end
--Shared