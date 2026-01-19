{{
    config(
        materialized='incremental',
        unique_key='transaction_line_id'
    )
}}

with transactions as (
    select * from {{ ref('stg_transactions') }}
), 

customers as (
    select * from {{ ref('dim_customers') }}
), 

employees as (
    select * from {{ ref('dim_employees') }}
), 

branches as (
    select * from {{ ref('dim_branches') }}
), 

currencies as (
    select * from {{ ref('dim_currencies') }}
)

select 
    -- primary key 
    t.transaction_line_id, 
    t.transaction_id, 

    --surrogate foreign keys for dimensions 
    c.customer_key, 
    e.employee_key, 
    b.branch_key, 
    src.currency_key as source_currency_key, 
    tgt.currency_key as target_currency_key, 

    --natural keys for reference 
    t.customer_id, 
    t.employee_id, 
    t.branch_id, 
    t.source_currency_code, 
    t.target_currency_code, 

    --dates
    t.transaction_timestamp, 
    t.service_start_time, 
    t.service_end_time, 

    --other dimensions 
    t.transaction_type, 
    t.transaction_status, 
    t.is_fee_waived, 
    t.payment_method, 

    --measures
    t.source_currency_amount, 
    t.target_currency_amount, 
    t.market_rate, 
    t.exchange_rate_applied, 
    t.fee_amount,

    --metadata
    t.loaded_at

from transactions t 
left join customers c on t.customer_id = c.customer_id
left join employees e on t.employee_id = e.employee_id
left join branches b on t.branch_id = b.branch_id
left join currencies src on t.source_currency_code = src.currency_code 
left join currencies tgt on t.target_currency_code = tgt.currency_code

{% if is_incremental() %}
    where t.loaded_at > (select max(loaded_at) from {{ this }})
{% endif %}
