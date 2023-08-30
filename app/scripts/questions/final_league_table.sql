with home_result as (
select
match_hometeam_name as team_name,
count(distinct(match_id)) as matches_played,
sum(case when hometeam_result='WIN' then 1 else 0 end) as won,
sum(case when hometeam_result='DRAW' then 1 else 0 end) as draw,
sum(case when hometeam_result='LOSS' then 1 else 0 end) as lost,
sum(match_hometeam_score::int) as goals_scored,
sum(match_awayteam_score::int) as goals_conceded,
sum(hometeam_points) as points
from 
fct_matches
group by
team_name
),
away_result as (
select
match_awayteam_name as team_name,
count(distinct(match_id)) as matches_played,
sum(case when awayteam_result='WIN' then 1 else 0 end) as won,
sum(case when awayteam_result='DRAW' then 1 else 0 end) as draw,
sum(case when awayteam_result='LOSS' then 1 else 0 end) as lost,
sum(match_awayteam_score::int) as goals_scored,
sum(match_hometeam_score::int) as goals_conceded,
sum(awayteam_points) as points
from 
fct_matches
group by
team_name
),
union_scores as (
select
*
from
home_result
union all
select
*
from
away_result
),
final_result as (
select
rank () over (
order by sum(points) desc,
sum(goals_scored-goals_conceded) desc,
sum(goals_scored) desc,
sum(goals_conceded) asc, 
sum(won) desc ) as position,
team_name,
sum(matches_played) as matches_played,
sum(won) as won,
sum(draw) as draw,
sum(lost) as lost,
sum(goals_scored) as goals_scored,
sum(goals_conceded) as goals_conceded,
sum(points) as points
from union_scores
group by team_name
)
select * from final_result order by position asc