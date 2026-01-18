with exchange_rates as (
    select * from {{ ref('stg_exchange_rates') }}
),

currencies as (
select * from {{ ref('dim_currencies') }}
) 

select 
    --Primary Key 
    r.rate_id, 

    --Surrogate foreign keys (from dimensions)
    src.currency_key as source_currency_key, 
    tgt.currency_key as target_currency_key, 

    --Natural Keys (for reference)
    r.source_currency_code, 
    r.target_currency_code, 

    --Date 
    r.date as rate_date, 

    --Measures 
    r.buy_rate, 
    r.sell_rate, 
    r.market_rate, 
    r.rate_source

from exchange_rates r 
left join currencies src on r.source_currency_code = src.currency_code  
left join currencies tgt on r.target_currency_code = tgt.currency_code