-- สำหรับการทดสอบ เพื่อให้เห็น Session ค้างอยู่ใน pg_stat_activity
select pg_sleep(60);

SELECT
    pid,
    usename,
    datname,
    query,
    now() - query_start AS duration
FROM pg_stat_activity
WHERE
    state = 'active';