with source as (
select 
* 
from {{ ref('stg_branches') }}
)

select 
    {{dbt_utils.generate_surrogate_key(['branch_id'])}}  as branch_key, 
    branch_id,
    branch_name,
    branch_address,
    branch_city,
    branch_state,
    branch_zip_code,
    branch_region,
    number_of_windows,
    branch_open_date,
    scheduled_open_time,
    scheduled_close_time
from source