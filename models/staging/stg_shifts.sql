select 

data:shift_id::varchar as shift_id, 
data:shift_date::date as shift_date, 
data:employee_id::varchar as employee_id, 
data:branch_id::varchar as branch_id, 
data:scheduled_hours::float as scheduled_hours, 
data:actual_hours::float as actual_hours, 
data:scheduled_start_time::timestamp as scheduled_start_time, 
data:actual_clock_in::timestamp as actual_start_time, 
data:scheduled_end_time::timestamp as scheduled_end_time, 
data:actual_clock_out::timestamp as actual_end_time, 
loaded_at

from {{ source('raw', 'raw_shifts') }}