with transactions as (
    select * from {{ ref('fct_transactions') }}
), 

branches as (
    select * from {{ ref('dim_branches') }}
), 

final as (
select 
t.branch_id, b.branch_name, date(t.transaction_timestamp) as transaction_date,  count (t.transaction_id) as transaction_count, (sum(source_currency_amount)) as total_amount, sum(fee_amount) as total_fees
from transactions t 
left join branches b 
on t.branch_key = b.branch_key
group by t.branch_id, b.branch_name,date(t.transaction_timestamp)
)

select 
branch_id, 
branch_name, 
transaction_date, 
transaction_count,
sum(transaction_count) over (partition by branch_id order by transaction_date asc) as running_total_transaction_count,  
lag(transaction_count) over (partition by branch_id order by transaction_date asc) as prev_day_transaction_count,
dense_rank() over (partition by transaction_date order by transaction_count desc) as daily_rank_transaction_count, 
total_amount, 
total_fees

from final
order by transaction_date asc