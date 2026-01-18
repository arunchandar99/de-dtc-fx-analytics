select 

data:customer_id::varchar as customer_id, 
data:first_name::varchar as customer_first_name,
data:last_name::varchar as customer_last_name, 
data:email::varchar as customer_email, 
data:phone::varchar as customer_phone_number,
data:customer_type::varchar as customer_type, 
data:created_at::date as created_at, 
data:acquisition_source::varchar as customer_source,
data:id_type::varchar as verification_type, 
data:id_verification_status::varchar as verification_status, 
loaded_at

from {{ source('raw', 'raw_customers') }}