select 

    data:transaction_line_id::varchar as transaction_line_id, 
    data:transaction_id::varchar as transaction_id, 
    data:transaction_timestamp::timestamp as transaction_timestamp, 
    data:transaction_status::varchar as transaction_status, 
    data:transaction_type::varchar as transaction_type, 
    data:customer:customer_id::varchar as customer_id, 
    data:employee_id::varchar as employee_id, 
    data:branch_id::varchar as branch_id, 
    data:fee_waived::boolean as is_fee_waived, 
    data:waiver_reason::varchar as waiver_reason, 
    data:payment_method::varchar as payment_method,
    data:service_start_time::timestamp as service_start_time, 
    data:service_end_time::timestamp as service_end_time, 
    data:source_currency_code::varchar as source_currency_code, 
    data:source_amount::float as source_currency_amount, 
    data:target_currency_code::varchar as target_currency_code, 
    data:target_amount::float as target_currency_amount,
    data:market_rate::decimal(12,8) as market_rate, 
    data:exchange_rate_applied::decimal(12,8) as exchange_rate_applied, 
    data:fee_amount::float as fee_amount, 
    loaded_at

from {{ source('raw', 'raw_transactions') }}