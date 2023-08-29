with src as (
select
data->>'match_id' as match_id,
md5(cast(data->'cards' as text)) as sk,
json_array_elements(data->'cards') as cards
from
raw_football_data
),
treatment as (
select
sk,
match_id,
cards->>'time' as card_time,
UPPER(cards->>'card') as card,
UPPER(cards->>'info') as info,
UPPER(cards->>'score_info_time') as score_info_time,
UPPER(coalesce(nullif(cards->>'home_fault',''),nullif(cards->>'away_fault',''))) as player,
coalesce(nullif(cards->>'home_player_id',''),nullif(cards->>'away_player_id','')) as player_id,
case when coalesce(nullif(cards->>'home_fault',''),'0')='0' then False else True end as is_home_fault,
case when coalesce(nullif(cards->>'away_fault',''),'0')='0' then False else True end as is_away_fault
from src
)

select * from treatment