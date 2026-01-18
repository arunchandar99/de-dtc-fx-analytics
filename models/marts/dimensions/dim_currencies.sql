with source as (
select
* 
from {{ ref('stg_currencies') }}
) 

select 
{{dbt_utils.generate_surrogate_key(['currency_id'])}} as currency_key, 
currency_id, 
currency_code, 
currency_name, 
country, 
is_active
from source 