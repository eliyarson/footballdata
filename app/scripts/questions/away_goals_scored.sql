select
match_awayteam_name as team_name,
sum(match_awayteam_score::int) as goals_scored
from 
fct_matches
group by
team_name
order by goals_scored desc, team_name asc