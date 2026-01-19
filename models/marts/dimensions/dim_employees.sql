with source as (
    select * from {{ ref('stg_employees') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as employee_key,
    employee_id,
    employee_first_name,
    employee_last_name,
    concat(employee_first_name, ' ', employee_last_name) as employee_full_name,
    employee_role,
    manager_id,
    branch_id,
    hire_date,
    status
from source