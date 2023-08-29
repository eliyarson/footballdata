select
match_hometeam_name as team_name,
count(distinct(match_id)) as matches_played,
sum(case when hometeam_result='WIN' then 1 else 0 end) as won,
sum(case when hometeam_result='DRAW' then 1 else 0 end) as draw,
sum(case when hometeam_result='LOSS' then 1 else 0 end) as lost,
sum(match_hometeam_score) as goals_scored,
sum(match_awayteam_score) as goals_conceded,
sum(hometeam_points) as points
from 
fct_matches
group by
team_name