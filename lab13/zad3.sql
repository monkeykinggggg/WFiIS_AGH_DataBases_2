-- W aplikacji konsolowej korzystano z kodu T_SQL:

SELECT 
    DATEADD(MINUTE, DATEDIFF(MINUTE, 0, data) / @interval * @interval, 0) AS IntervalStart,
    COUNT(*) AS MeasurementCount,
    MIN(ch4) AS MinValue,
    MAX(ch4) AS MaxValue
FROM Pomiary
WHERE data BETWEEN @from AND @to
GROUP BY DATEADD(MINUTE, DATEDIFF(MINUTE, 0, data) / @interval * @interval, 0)
ORDER BY IntervalStart;
