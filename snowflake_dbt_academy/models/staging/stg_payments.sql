WITH source_data AS (
    SELECT *
    FROM {{ source('raw_data', 'payments') }}
),

renamed AS (
    SELECT
        payment_id::INTEGER AS payment_id,,
        order_id::INTEGER AS order_id,
        CASE
            WHEN p.payment_method IN ('credit_card', 'cc', 'visa', 'mastercard', 'amex') THEN 'credit_card'
            WHEN p.payment_method IN ('bank_transfer', 'wire', 'ach') THEN 'bank_transfer'
            WHEN p.payment_method IN ('paypal', 'venmo') THEN 'digital_wallet'
            WHEN p.payment_method = 'gift_card' THEN 'gift_card'
            ELSE 'other'
        END AS payment_method_clean,
        -- ENFORCE PRECISE FINANCIAL DECIMAL PRECISION
        amount::DECIMAL(10, 2) AS payment_amount,
        lower(trim(status)) AS payment_status
    FROM source_data
)

SELECT * FROM renamed