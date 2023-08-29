create table fct_matches as (
with src as (
select
data->>'match_id' as match_id,
upper(data->>'match_referee') as match_referee,
upper(data->>'match_status') as match_status,
data->>'match_date' as match_date,
data->>'match_round' as match_round,
data->>'league_id' as league_id,
upper(data->>'league_name') as league_name,
data->>'league_year' as league_year,
data->>'match_hometeam_score' as match_hometeam_score,
upper(data->>'match_hometeam_name') as match_hometeam_name,
data->>'match_hometeam_id' as match_hometeam_id,
data->>'match_awayteam_score' as match_awayteam_score,
upper(data->>'match_awayteam_name') as match_awayteam_name,
data->>'match_awayteam_id' as match_awayteam_id,
inserted_at
from raw_football_data
),
results as (
select
*,
case
when match_hometeam_score > match_awayteam_score then 'WIN'
when match_hometeam_score < match_awayteam_score then 'LOSS'
when match_hometeam_score = match_awayteam_score then 'DRAW'
end as hometeam_result,
case
when match_hometeam_score < match_awayteam_score then 'WIN'
when match_hometeam_score > match_awayteam_score then 'LOSS'
when match_hometeam_score = match_awayteam_score then 'DRAW'
end as awayteam_result
from 
src
),
points as (
select
*,
case
when hometeam_result = 'WIN' then 3
when hometeam_result = 'DRAW' then 1
when hometeam_result = 'LOSS' then 0
end as hometeam_points,
case
when awayteam_result = 'WIN' then 3
when awayteam_result = 'DRAW' then 1
when awayteam_result = 'LOSS' then 0
end as awayteam_points
from
results
),
dedup as (
  select *,
    row_number() OVER (
        PARTITION BY
            match_id
        ORDER BY
            inserted_at DESC
        ) AS row_version
  from points
)
select * from points
where league_year = '2022/2023'
and league_name = 'PREMIER LEAGUE'
order by match_date
)
