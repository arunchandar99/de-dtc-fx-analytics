select 

    data:inventory_id::varchar as inventory_id, 
    data:branch_id::varchar as branch_id, 
    data:date::date as inventory_date, 
    data:currency_code::varchar as currency_code, 
    data:opening_balance::float as opening_balance,
    data:closing_balance::float as closing_balance, 
    data:expected_closing_balance::float as expected_closing_balance, 
    data:variance::float as variance,
    loaded_at
    
from {{ source('raw', 'raw_daily_cash_inventory') }}