select 
data:employee_id::varchar as employee_id, 
data:branch_id::varchar as branch_id,  
data:first_name::varchar as employee_first_name, 
data:last_name::varchar as employee_last_name, 
data:hire_date::date as hire_date, 
data:manager_id::varchar as manager_id, 
data:role::varchar as employee_role, 
data:status::varchar as status, 
loaded_at
from {{ source('raw', 'raw_employees') }}