{% macro transaction_fee_tier (amount) %}
    case    
        when {{amount}} > 10000 then 'premium'
        when {{amount}} >  1000 then 'standard'
        else 'small'
    end 
{% endmacro %}