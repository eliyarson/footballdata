select
dim_goals.goal_player as player_name,
case
when dim_goals.is_home=True then fct_matches.match_hometeam_name else fct_matches.match_awayteam_name end as team_name,
count(dim_goals.id) as goals
from dim_goals 
left join fct_matches on dim_goals.match_id=fct_matches.match_id
where
match_round <=14
group by 1,2
order by goals desc, player_name asc