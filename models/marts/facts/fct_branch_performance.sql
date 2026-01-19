with final as (
    select
        branch_id,
        branch_name,
        transaction_count,
        total_amount,
        total_fees,
        (case 
            when transaction_count > 100 then 'busy day'
            when transaction_count > 50 then 'normal day'
            else 'slow day'
        end) as day_type
    from {{ ref('int_daily_branch_summary') }}
),

branch_totals as (
    select
        branch_id,
        sum(transaction_count) as branch_total_transactions
    from final
    group by branch_id
    having sum(transaction_count) > 30000
)

select 
    f.branch_id, 
    f.branch_name,
    f.day_type,
    sum(f.transaction_count) as total_transactions,
    sum(f.total_amount) as final_total_amount, 
    sum(f.total_fees) as final_total_fees,
    count(f.day_type) as count_days_by_performance
from final f
inner join branch_totals bt on f.branch_id = bt.branch_id
group by f.branch_id, f.branch_name, f.day_type
order by f.branch_name
