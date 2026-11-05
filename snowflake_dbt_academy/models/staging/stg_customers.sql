WITH 
source_data as (
    SELECT *
    FROM {{ source('raw_data', 'customers') }} c
),

country_map as (
    SELECT * FROM {{ ref('country_mapping') }}
),

cleaned_data as(
    SELECT
    customer_id::integer AS customer_id,
    UPPER(TRIM(first_name)) AS first_name,
    UPPER(TRIM(last_name)) AS last_name,
    LOWER(TRIM(email)) AS email,
    COALESCE(TRIM(phone), 'N/A') AS phone,
    UPPER(TRIM(country)) AS country_code,
    created_at::timestamp_ntz AS created_at,
    coalesce(cm.country_code, trim(UPPER(s.country))) AS country_standard,
    --ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(c.email)) ORDER BY c.created_at DESC) AS rn
    FROM source_data s
    left join country_map cm
        on trim(UPPER(s.country)) = upper(cm.country_raw)
    WHERE created_at IS NOT NULL
    AND email IS NOT NULL
    AND email LIKE '%@%'
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY LOWER(TRIM(email)) 
        ORDER BY created_at DESC
    ) = 1
)
 
SELECT * 
FROM cleaned_data