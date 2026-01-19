{% macro dollars_to_cents(amount, decimal_places = 2) %}
    round(
        {{amount}}*100,{{decimal_places }}
    )
{% endmacro %}