if CLIENT then
    --Client
    net.Receive( "InfoMessage" , function()
        chat.AddText(Color(0,255,255),"'!p' has been replaced with '!pmsg'. you can mute the chat of someone with '!pmute' and unmute with '!punmute' (Your client only.).")
    end )
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
    
    function shouldHideChat( text )
        local HideTable = {
            "pmsg",
            "pmute",
            "punmute"
        }
        for k,v in pairs(HideTable) do
            local len = string.len( v )
            if text:Left(len)==v then
                return true
            end
        end
        return false
    end

    local mutedTable = {}
    local Prefixes = {
        "!",
        "/"
    }

    hook.Add( "OnPlayerChat" , "ChatStuff" , function( msgply , text , bTeam , bDead )
        if msgply==LocalPlayer() then
            local Args = string.Explode( " " , text )
            local PRFX = string.Left( Args[1] , 1 )
            local result = findInTable( PRFX , Prefixes )
            if result then
                local Command = Args[1]:sub(2)
                local WTR = true
                if Command=="pmute" then
                    if table.Count(Args)>1 then
                        table.remove( Args , 1 )
                        local searchQuery = string.lower(table.concat( Args , " " ))
                        local player = findByName( searchQuery )
                        if not player:IsPlayer() then
                            msgply:ChatPrint( "Player invalid or doesn't exist." )
                        else
                            local result = findInTable( player , mutedTable )
                            if result then
                                msgply:ChatPrint( "Player is already muted by you." )
                            elseif player~=LocalPlayer() then
                                table.insert( mutedTable , player )
                                msgply:ChatPrint( "Muted "..player:GetName().."." )
                            elseif player==LocalPlayer() then
                                msgply:ChatPrint( "Player cannot be yourself." )
                            end
                        end
                    else
                        chat.AddText( "Insufficient arguments provided." )
                    end
                elseif Command=="punmute" then
                    if table.Count(Args)>1 then
                        table.remove( Args , 1 )
                        local searchQuery = string.lower(table.concat( Args , " " ))
                        local player = findByName( searchQuery )
                        if not player:IsPlayer() then
                            msgply:ChatPrint( "Player invalid or doesn't exist." )
                        else
                            local result,index = findInTable( player , mutedTable )
                            if result then
                                if player!=LocalPlayer() then
                                    table.remove( mutedTable , index )
                                    msgply:ChatPrint( "Player unmuted." )
                                elseif player==LocalPlayer() then
                                    msgply:ChatPrint( "Player cannot be yourself." )
                                end
                            else
                                msgply:ChatPrint( "Player is not muted." )
                            end
                        end
                    else
                        chat.AddText( "Insufficient arguments provided." )
                    end
                elseif Command=="pmsg" then
                    table.remove( Args , 1 )
                    if table.Count( Args )>1 then
                        local searchQuery
                        local message
                        if Args[1]:Left(1)!='"' then
                            searchQuery = string.lower( Args[1] )
                            table.remove( Args , 1 )
                            message = table.concat( Args , " " )
                        else
                            local NewArgs = string.Explode( '"' , string.lower( table.concat( Args , " " ) ) )
                            searchQuery = NewArgs[2]
                            message = string.TrimLeft( NewArgs[3] , " " )
                        end
                        print( searchQuery , message )
                        local player = findByName( searchQuery )
                        if not player:IsPlayer() then
                            msgply:ChatPrint( "Player invalid or doesn't exist." )
                        else
                            if message==nil then
                                msgply:ChatPrint( "No message argument provided." )
                            else
                                net.Start("PrivateMessage")
                                net.WriteEntity( player ) --Recepient
                                net.WriteString( message ) --Message
                                net.SendToServer()
                            end
                        end
                    else
                        chat.AddText( "Insufficient arguments provided." )
                    end
                else
                    WTR = false
                end
                return WTR
            end
        else
            local result = findInTable( msgply , mutedTable )
            if result then
                return true
            end
            local PRFX = string.Left( text , 1 )
            local result = findInTable( PRFX , Prefixes )
            if result then
                local a = text:sub( 2 )
                if shouldHideChat( a ) then
                    return true
                end
            end
        end

    end )
    net.Receive( "ReturnMessage" , function()
        local msgData = net.ReadTable()
        local FromColor = team.GetColor(msgData.From:Team())
        local ToColor = team.GetColor(msgData.To:Team())
        local result = findInTable( msgData.From , mutedTable )
        if not result then
            chat.AddText(Color(255,255,255),"[",FromColor,msgData.From:GetName(),Color(255,255,255),"]-->[",ToColor,msgData.To:GetName(),Color(255,255,255),"]: "..msgData.Message)
        end
    end )
else
    --Server
    print( "Client-side ChatMute Loaded." )

    util.AddNetworkString( "InfoMessage" )
    util.AddNetworkString( "PrivateMessage" )
    util.AddNetworkString( "ReturnMessage" )
    net.Receive( "PrivateMessage" , function( len , ply )
        local sender = ply
        local recepient = net.ReadEntity()
        local message = net.ReadString()
        local msgData = {
            From = sender,
            To = recepient,
            Message = message
        }
        net.Start( "ReturnMessage" )
        net.WriteTable( msgData )
        net.Send( { recepient , sender } )
    end )

    hook.Add( "PlayerInitialSpawn" , "Info" , function( ply )
        net.Start( "InfoMessage" )
        net.Send( ply )
    end )
end
--Shared
