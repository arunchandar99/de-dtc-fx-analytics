select 

data:branch_id::varchar as branch_id, 
data:branch_name::varchar as branch_name, 
data:address::varchar as branch_address, 
data:state::varchar as branch_state, 
data:zip_code::varchar as branch_zip_code,
data:city::varchar as branch_city, 
data:region::varchar as branch_region,
data:number_of_windows::int as number_of_windows, 
data:open_date::date as branch_open_date, 
data:scheduled_open_time::varchar as scheduled_open_time, 
data:scheduled_close_time::varchar as scheduled_close_time, 
loaded_at

from {{ source('raw', 'raw_branches') }}

