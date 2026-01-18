select 
data:rate_id::varchar as rate_id, 
data:source_currency_code::varchar as source_currency_code, 
data:target_currency_code::varchar as target_currency_code, 
data:buy_rate::decimal(12,8) as buy_rate, 
data:sell_rate::decimal(12,8) as sell_rate, 
data:market_rate::decimal(12,8) as market_rate,
data:date::date as date, 
data:rate_source::varchar as rate_source, 
loaded_at

from {{ source('raw', 'raw_exchange_rates') }}