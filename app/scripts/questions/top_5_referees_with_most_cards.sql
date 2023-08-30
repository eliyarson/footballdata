select 
referee as referee_name,
count(id) as cards
from dim_cards
group by 1
order by count(id) desc, referee asc
limit 5