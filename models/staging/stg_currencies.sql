select 
    data:currency_id::varchar as currency_id, 
    data:currency_code::varchar as currency_code, 
    data:currency_name::varchar as currency_name, 
    data:country::varchar as country, 
    data:is_active::boolean as is_active,
    loaded_at
from {{ source('raw', 'raw_currencies') }}