{% macro cents_to_dollars (amount,decimal_places = 2) %}
    round(
        {{amount}}/100.0, {{decimal_places}}
    )
{% endmacro %}