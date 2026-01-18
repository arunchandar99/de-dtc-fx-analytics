with source as (
select 
* 
from {{ ref('stg_customers') }}
) 

select 
{{dbt_utils.generate_surrogate_key(['customer_id'])}} as customer_key, 
customer_id, 
customer_first_name, 
customer_last_name, 
concat(customer_first_name, ' ', customer_last_name) as customer_full_name, 
customer_email, 
customer_phone_number,
customer_type, 
created_at, 
customer_source, 
verification_status
from source 