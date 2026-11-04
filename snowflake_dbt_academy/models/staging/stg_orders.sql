WITH source_data AS (
    SELECT *
    FROM {{ source('raw_data', 'orders') }}
),

renamed AS (
    SELECT
        order_id::integer as order_id,
        customer_id::integer as customer_id,
        order_date::date as order_date,
        status::varchar as order_status,
        shipping_method,
        CASE
            WHEN status = 'completed' THEN 'completed'
            WHEN status = 'shipped' THEN 'in_transit'
            WHEN status IN ('pending', 'processing') THEN 'open'
            WHEN status IN ('cancelled', 'canceled', 'refunded') THEN 'cancelled'
            ELSE 'other'
        END AS order_status_clean,
        LOWER(TRIM(shipping_method)) AS shipping_method_clean,
    from Source_data
)

SELECT * FROM renamed