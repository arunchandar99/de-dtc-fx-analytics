with daily_cash_inventory as (
    select * from {{ ref('stg_daily_cash_inventory') }}
), 

branch as (
    select * from {{ ref('dim_branches') }}
), 

currency as (
    select * from {{ ref('dim_currencies') }}
)

select 

    --primary key 
    d.inventory_id, 

    --surrogate foreign keys 
    b.branch_key, 
    c.currency_key, 

    --natural keys for reference 
    d.branch_id, 
    d.currency_code, 

    --date
    d.inventory_date, 

    --measures
    d.opening_balance, 
    d.closing_balance, 
    d.expected_closing_balance, 
    d.variance


from daily_cash_inventory d 
left join branch b on d.branch_id = b.branch_id 
left join currency c on d.currency_code = c.currency_code