WITH p AS (
    SELECT
        resource_id,
        date,
        start_time,
        end_time,

        -- Start date parts
        CAST(substr(start_time, 1, instr(start_time, '/') - 1) AS INTEGER) AS start_mm,
        CAST(
            substr(
                start_time,
                instr(start_time, '/') + 1,
                instr(substr(start_time, instr(start_time, '/') + 1), '/') - 1
            ) AS INTEGER
        ) AS start_dd,
        CAST(substr(start_time, instr(start_time, ' ') - 4, 4) AS INTEGER) AS start_yyyy,

        -- Start time parts
        CAST(
            substr(
                start_time,
                instr(start_time, ' ') + 1,
                instr(substr(start_time, instr(start_time, ' ') + 1), ':') - 1
            ) AS INTEGER
        ) AS start_hh,
        CAST(substr(start_time, length(start_time) - 1, 2) AS INTEGER) AS start_mi,
  

        -- End date parts
        CAST(substr(end_time, 1, instr(end_time, '/') - 1) AS INTEGER) AS end_mm,
        CAST(
            substr(
                end_time,
                instr(end_time, '/') + 1,
                instr(substr(end_time, instr(end_time, '/') + 1), '/') - 1
            ) AS INTEGER
        ) AS end_dd,
        CAST(substr(end_time, instr(end_time, ' ') - 4, 4) AS INTEGER) AS end_yyyy,

        -- End time parts
        CAST(
            substr(
                end_time,
                instr(end_time, ' ') + 1,
                instr(substr(end_time, instr(end_time, ' ') + 1), ':') - 1
            ) AS INTEGER
        ) AS end_hh,
        CAST(substr(end_time, length(end_time) - 1, 2) AS INTEGER) AS end_mi

    FROM test_dein11test_dein11
),
cte2 as(
SELECT
    resource_id,
    date,
    start_time,
    end_time,

    datetime(
        printf(
            '%04d-%02d-%02d %02d:%02d:00',
            start_yyyy,
            start_mm,
            start_dd,
            start_hh,
            start_mi
        )
    ) AS start_timestamp,

    datetime(
        printf(
            '%04d-%02d-%02d %02d:%02d:00',
            end_yyyy,
            end_mm,
            end_dd,
            end_hh,
            end_mi
        )
    ) AS end_timestamp

FROM p)

select resource_id, date, 
min(start_timestamp) as clock_in_time,
max(end_timestamp) as clock_out_time,
round(sum(strftime('%s', end_timestamp) - strftime('%s', start_timestamp))/(60*60.0), 3) AS diff_hours
-- sum(strftime('%s', end_timestamp) - strftime('%s', start_timestamp)) AS diff_seconds
from cte2
where end_timestamp>=start_timestamp
group by  resource_id, date
;


