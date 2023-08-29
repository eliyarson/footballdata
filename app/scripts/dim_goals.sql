create table dim_goals as (
with src as (
select
data->>'match_id' as match_id,
data->>'match_referee' as match_referee,
data->>'match_date' as match_date,
json_array_elements(data->'goalscorer') as goals,
inserted_at
from
raw_football_data
),
treatment as (
select
match_id,
match_date,
upper(match_referee) as referee,
goals->>'time' as goal_time,
UPPER(goals->>'score_info_time') as score_info_time,
UPPER(goals->>'score') as score,
UPPER(coalesce(nullif(goals->>'home_scorer',''),nullif(goals->>'away_scorer',''))) as goal_player,
UPPER(coalesce(nullif(goals->>'home_assist',''),nullif(goals->>'away_assist',''))) as assist_player,
coalesce(nullif(goals->>'home_scorer_id',''),nullif(goals->>'away_scorer_id','')) as goal_player_id,
coalesce(nullif(goals->>'home_assist_id',''),nullif(goals->>'away_assist_id','')) as goal_assist_id,
inserted_at
from src
),
create_id as (
select 
md5(concat(match_id,match_date,goal_time,goal_player_id,goal_assist_id)) as id,* 
from treatment
),
dedup as (
  select *,
    row_number() OVER (
        PARTITION BY
            id
        ORDER BY
                inserted_at DESC
        ) AS row_version
  from create_id
)
select * from dedup where row_version = 1)
