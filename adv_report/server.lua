local reports = {}

RegisterNetEvent('adv:report:add', function(description)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerName = xPlayer.getName()

    table.insert(reports, {
        reportId = #reports + 1,
        playerId = src,
        playerName = playerName,
        description = description,
        resolvedBy = nil 
    })

    for _, playerId in ipairs(GetPlayers()) do
        local staffPlayer = ESX.GetPlayerFromId(playerId)
        if staffPlayer and staffPlayer.getGroup() == 'admin' then
            TriggerClientEvent('ox_lib:notify', playerId, {
                title = 'New Report',
                description = ('%s submitted a new report.'):format(playerName),
                type = 'inform'
            })
        end
    end
end)


RegisterNetEvent('adv:report:checkPermission', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if xPlayer.getGroup() == 'admin' then
        TriggerClientEvent('adv:report:showReports', src, reports)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Access denied',
            description = 'You do not have permission to view reports.',
            type = 'error'
        })
    end
end)


RegisterNetEvent('adv:report:resolve', function(reportIndex)
    local src = source
    local xStaff = ESX.GetPlayerFromId(src)
    if not xStaff or xStaff.getGroup() ~= 'admin' then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Access denied',
            description = 'Only staff can resolve reports.',
            type = 'error'
        })
        return
    end

    local report = reports[reportIndex]
    if report then
        report.resolvedBy = GetPlayerName(source)
        local targetId = report.playerId
        table.insert(reports,report.resolvedBy)
        table.remove(reports, reportIndex)

        local targetPlayer = GetPlayerPed(targetId)
        if targetPlayer then
            local coords = GetEntityCoords(targetPlayer)
            TriggerClientEvent('adv:report:receivePlayerCoords', src, coords, targetId)
        else
            TriggerClientEvent('adv:report:receivePlayerCoords', src, nil, targetId)
        end


        ESX.Log(Config.Webhook, "The report opened by: **" .. GetPlayerName(source) .. "** and was taken over by:  **" .. report.resolvedBy .. "**")
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report Resolved',
            description = ('You have solved report #%d.'):format(reportIndex),
            type = 'success'
        })

    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Error',
            description = 'Report not found.',
            type = 'error'
        })
    end
end)

function sendToDiscord(webhook, messaggio)
    local contenuto = {{
        author = {
        name = "ADV DEVELOPMENT",
        icon_url = "https://media.discordapp.net/attachments/1169912186370523137/1340794984768733415/png_Stock.png?ex=67b6f3e3&is=67b5a263&hm=4c7d981ed7147453966674f4582b9d9d49b3b2dfc2a75a7aa73c1de56f3b2933&=&format=webp&quality=lossless&width=676&height=676"
        },
        thumbnail = {
            url = "https://media.discordapp.net/attachments/1169912186370523137/1340794984768733415/png_Stock.png?ex=67b6f3e3&is=67b5a263&hm=4c7d981ed7147453966674f4582b9d9d49b3b2dfc2a75a7aa73c1de56f3b2933&=&format=webp&quality=lossless&width=676&height=676" 
        },
        description = messaggio,
        color = 32768,
        footer = {
        text = "ADV DEVELOPMENT | "..os.date("%x | %X %p"),
        }
    }}
    PerformHttpRequest(webhook , function(err, text, headers) end, 'POST', json.encode({username = name, embeds = contenuto}), { ['Content-Type'] = 'application/json' })
end
  
ESX.Log = function(webhook, messaggio)
    sendToDiscord(webhook, messaggio)
end