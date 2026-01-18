with shifts as (
    select * from {{ ref('stg_shifts') }} 
), 

employee as (
    select * from {{ ref('dim_employees') }}
), 

branch as (
    select * from {{ ref('dim_branches') }}
)

select 

    --primary key 
    s.shift_id, 

    --surrogate foreign keys for dimensions 
    e.employee_key, 
    b.branch_key,

    --natural foreign keys for reference
    s.employee_id, 
    s.branch_id, 

    --date 
    s.shift_date, 
    s.scheduled_start_time, 
    s.actual_start_time, 
    s.scheduled_end_time, 
    s.actual_end_time, 
    s.scheduled_hours, 
    s.actual_hours

from shifts s
left join employee e on s.employee_id = e.employee_id
left join branch b on s.branch_id = b.branch_id 
