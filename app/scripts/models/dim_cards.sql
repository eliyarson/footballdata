drop table dim_cards;
create table dim_cards as (
with src as (
select
data->>'match_id' as match_id,
data->>'match_referee' as match_referee,
data->>'match_date' as match_date,
json_array_elements(data->'cards') as cards,
inserted_at
from
raw_football_data
where data->>'league_year' = '2022/2023'
and upper(data->>'league_name') = 'PREMIER LEAGUE'
and upper(data->>'match_status') = 'FINISHED'
),
treatment as (
select
match_id,
match_date,
upper(match_referee) as referee,
cards->>'time' as card_time,
UPPER(cards->>'card') as card,
UPPER(cards->>'info') as info,
UPPER(cards->>'score_info_time') as score_info_time,
UPPER(coalesce(nullif(cards->>'home_fault',''),nullif(cards->>'away_fault',''))) as player,
coalesce(nullif(cards->>'home_player_id',''),nullif(cards->>'away_player_id','')) as player_id,
case when coalesce(nullif(cards->>'home_fault',''),'0')='0' then False else True end as is_home_fault,
case when coalesce(nullif(cards->>'away_fault',''),'0')='0' then False else True end as is_away_fault,
inserted_at
from src
),
create_id as (
select 
md5(concat(match_id,card,match_date,player_id)) as id,* 
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
select * from dedup where row_version = 1
);