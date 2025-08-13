function main()
{
    Globalize( CreateMatchGoalsForGamemode )

    CreateMatchGoalsForGamemode( GameRules.GetGameMode() )
}

function CreateMatchGoalsForGamemode( gamemode )
{
    switch( gamemode )
    {
        case ATTRITION:
            level.performanceGoals <- [4, 9, 14, 19, 24]
        default:
            level.performanceGoals <- [4, 9, 14, 19, 24] // use AT as default for now
    }
}

function Leagues_CalculateSkill_Attrition( player )
{
    local score = player.GetAssaultScore()
    local deaths = player.GetDeathCount()

    local adjustedScore = score - ( deaths * 3 )

    return adjustedScore
}