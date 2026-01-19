{% macro calculate_spread(sell_rate, buy_rate, decimal_places = 4) %}
    round(
        ({{sell_rate}} - {{buy_rate}}) / nullif({{buy_rate}},0),{{decimal_places}}
    )

{% endmacro %}