local reports = {}


RegisterCommand(Config.CommandReport, function()
    local input = lib.inputDialog('Send Report', {'Describe your problem:'})
    if input and input[1] then
        TriggerServerEvent('adv:report:add', input[1])
        lib.notify({
            title = 'Report Sent',
            description = 'Your report has been successfully submitted.',
            type = 'success'
        })
    else
        lib.notify({
            title = 'Error',
            description = 'You must enter a valid description.',
            type = 'error'
        })
    end
end)


RegisterCommand(Config.ListReport, function()
    TriggerServerEvent('adv:report:checkPermission')
end)


RegisterNetEvent('adv:report:showReports', function(reportsData)
    reports = reportsData
    local options = {}

    for index, report in ipairs(reports) do
        table.insert(options, {
            title = report.playerName,
            description = ('ID: %s\nDescrizione: %s'):format(report.playerId, report.description),
            args = { index = index, playerId = report.playerId }, 
            onSelect = function(args)
                local reportIndex = args.index


                TriggerServerEvent('adv:report:resolve', reportIndex)


                table.remove(reports, reportIndex)


                local updatedOptions = {}
                for i, r in ipairs(reports) do
                    table.insert(updatedOptions, {
                        title = r.playerName,
                        description = ('ID: %s\nDescrizione: %s'):format(r.playerId, r.description),
                        args = { index = i, playerId = r.playerId },
                        onSelect = function(args)
                            TriggerServerEvent('adv:report:resolve', args.index)
                            table.remove(reports, args.index)
                        end
                    })
                end

                lib.registerContext({
                    id = 'report_menu',
                    title = 'Report List',
                    options = updatedOptions
                })
                lib.showContext('report_menu')
            end
        })
    end

    if #options > 0 then
        lib.registerContext({
            id = 'report_menu',
            title = 'Report List',
            options = options
        })
        lib.showContext('report_menu')
    else
        lib.notify({
            title = 'No Report',
            description = 'There are no reports available.',
            type = 'inform'
        })
    end
end)


RegisterNetEvent('adv:report:receivePlayerCoords', function(coords, targetId)
    local playerPed = PlayerPedId()

    if coords and coords.x and coords.y and coords.z then
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
        lib.notify({
            title = 'Teleportation successful',
            description = ('You have been teleported to the player with ID %s.'):format(targetId),
            type = 'success'
        })
    else
        lib.notify({
            title = 'Error',
            description = 'Invalid coordinates for the selected report.',
            type = 'error'
        })
    end
end)
