{% snapshot snp_employees %}

{{
    config(
        target_schema='snapshots',
        unique_key='employee_id',
        strategy='check',
        check_cols=['branch_id', 'employee_role', 'status']
    )
}}

select * from {{ ref('stg_employees') }}

{% endsnapshot %}