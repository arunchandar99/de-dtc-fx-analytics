{% macro calculate_percentage (numerator, denominator, decimal_places = 2) %}

    round(
        ({{numerator}}/nullif({{denominator}},0))*100, {{decimal_places}}
    )
{% endmacro %}