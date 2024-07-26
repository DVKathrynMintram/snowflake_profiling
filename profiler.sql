DECLARE
    sql VARCHAR(16777216);
    final_sql VARCHAR(16777216);
    c1 CURSOR FOR (SELECT DISTINCT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, ORDINAL_POSITION 
                   FROM DATAVAULT_SHARED.INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'HUB_GL_COA'
                   ORDER BY TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION);
    res RESULTSET;
BEGIN
  final_sql := '';
  FOR record IN c1 DO
    IF(record.data_type = 'TEXT') THEN
        sql := 'SELECT '''||record.table_name||''' AS TABLENAME, 
                       '''||record.column_name||''' AS COLUMN_NAME, 
                       '''||record.data_type||''' AS DATA_TYPE, 
                       '''||record.ordinal_position||''' AS ORDINAL_POSITION,
                       COUNT('||record.column_name||') AS ROW_COUNT,
                       SUM(CASE WHEN (CASE WHEN '||record.column_name||'::VARCHAR = '''' THEN NULL ELSE '||record.column_name||' END ) IS NULL THEN 0 ELSE 1 END)  AS NOT_NULL_COUNT,
                       ROUND(((SUM(CASE WHEN (CASE WHEN '||record.column_name||'::VARCHAR = '''' THEN NULL ELSE '||record.column_name||' END ) IS NULL THEN 0 ELSE 1 END)) / CAST(COUNT(*) AS NUMERIC)) * 100, 2) AS NOT_NULL_PERCENTAGE,
                       SUM(CASE WHEN (CASE WHEN '||record.column_name||'::VARCHAR = '''' THEN NULL ELSE '||record.column_name||' END ) IS NULL THEN 1 ELSE 0 END) AS NULL_COUNT,
                       ROUND(((SUM(CASE WHEN (CASE WHEN '||record.column_name||'::VARCHAR = '''' THEN NULL ELSE '||record.column_name||' END ) IS NULL THEN 1 ELSE 0 END)) / CAST(COUNT(*) AS NUMERIC)) * 100, 2) AS NULL_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') AS DISTINCT_COUNT,
                       ROUND(COUNT(DISTINCT '||record.column_name||')/CAST(COUNT(*) AS NUMERIC) * 100, 2) AS DISTINCT_COUNT_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') = CAST(COUNT(*) AS NUMERIC) AS IS_UNIQUE,
                       MIN(LEN('||record.column_name||'))::float AS MIN,
                       MAX(LEN('||record.column_name||'))::float AS MAX,
                       NULL AS AVG,
                       NULL AS MODE,
                       CONVERT_TIMEZONE(''UTC'', CURRENT_TIMESTAMP()) AS PROFILED_AT
                 FROM '||record.table_catalog||'.'||record.table_schema||'.'||record.table_name||' ';
    ELSEIF(record.data_type = 'NUMBER') THEN
        sql := 'SELECT '''||record.table_name||''' AS TABLENAME, 
                       '''||record.column_name||''' AS COLUMN_NAME, 
                       '''||record.data_type||''' AS DATA_TYPE, 
                       '''||record.ordinal_position||''' AS ORDINAL_POSITION,
                       COUNT('||record.column_name||') AS ROW_COUNT, 
                       SUM(CASE WHEN '||record.column_name||' IS NULL THEN 1 ELSE 0 END) AS NULL_COUNT,
                       ROUND(((SUM(CASE WHEN '||record.column_name||' IS NULL THEN 1 ELSE 0 END)) / COUNT(*)) * 100, 2) AS NULL_PERCENTAGE,
                       SUM(CASE WHEN '||record.column_name||' IS NULL THEN 0 ELSE 1 END) AS NOT_NULL_COUNT,
                       ROUND(((SUM(CASE WHEN '||record.column_name||' IS NULL THEN 0 ELSE 1 END)) / COUNT(*)) * 100, 2) AS NOT_NULL_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') AS DISTINCT_COUNT,
                       ROUND(COUNT(DISTINCT '||record.column_name||')/COUNT(*) * 100, 2) AS DISTINCT_COUNT_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') = COUNT(*) AS IS_UNIQUE,
                       MIN('||record.column_name||') AS MIN,
                       MAX('||record.column_name||') AS MAX,
                       ROUND(AVG('||record.column_name||'), 2) AS AVG,
                       MODE('||record.column_name||') AS MODE,
                       CONVERT_TIMEZONE(''UTC'', CURRENT_TIMESTAMP()) AS PROFILED_AT
                 FROM '||record.table_catalog||'.'||record.table_schema||'.'||record.table_name||' ';
    ELSEIF(record.data_type = 'DATE') THEN
        sql := 'SELECT '''||record.table_name||''' AS TABLENAME, 
                       '''||record.column_name||''' AS COLUMN_NAME, 
                       '''||record.data_type||''' AS DATA_TYPE, 
                       '''||record.ordinal_position||''' AS ORDINAL_POSITION,
                       COUNT('||record.column_name||') AS ROW_COUNT, 
                       SUM(CASE WHEN '||record.column_name||' IS NULL THEN 1 ELSE 0 END) AS NULL_COUNT,
                       ROUND(((SUM(CASE WHEN '||record.column_name||' IS NULL THEN 1 ELSE 0 END)) / COUNT(*)) * 100, 2) AS NULL_PERCENTAGE,
                       SUM(CASE WHEN '||record.column_name||' IS NULL THEN 0 ELSE 1 END) AS NOT_NULL_COUNT,
                       ROUND(((SUM(CASE WHEN '||record.column_name||' IS NULL THEN 0 ELSE 1 END)) / COUNT(*)) * 100, 2) AS NOT_NULL_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') AS DISTINCT_COUNT,
                       ROUND(COUNT(DISTINCT '||record.column_name||')/COUNT(*) * 100, 2) AS DISTINCT_COUNT_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') = COUNT(*) AS IS_UNIQUE,
                       NULL AS MIN,
                       NULL AS MAX,
                       NULL AS AVG,
                       NULL AS MODE,
                       CONVERT_TIMEZONE(''UTC'', CURRENT_TIMESTAMP()) AS PROFILED_AT
                 FROM '||record.table_catalog||'.'||record.table_schema||'.'||record.table_name||' ';
    ELSEIF(record.data_type = 'BOOLEAN') THEN
        sql := 'SELECT '''||record.table_name||''' AS TABLENAME, 
                       '''||record.column_name||''' AS COLUMN_NAME, 
                       '''||record.data_type||''' AS DATA_TYPE, 
                       '''||record.ordinal_position||''' AS ORDINAL_POSITION,
                       COUNT('||record.column_name||') AS ROW_COUNT, 
                       SUM(CASE WHEN '||record.column_name||' IS NULL THEN 1 ELSE 0 END) AS NULL_COUNT,
                       ROUND(((SUM(CASE WHEN '||record.column_name||' IS NULL THEN 1 ELSE 0 END)) / COUNT(*)) * 100, 2) AS NULL_PERCENTAGE,
                       SUM(CASE WHEN '||record.column_name||' IS NULL THEN 0 ELSE 1 END) AS NOT_NULL_COUNT,
                       ROUND(((SUM(CASE WHEN '||record.column_name||' IS NULL THEN 0 ELSE 1 END)) / COUNT(*)) * 100, 2) AS NOT_NULL_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') AS DISTINCT_COUNT,
                       ROUND(COUNT(DISTINCT '||record.column_name||')/COUNT(*) * 100, 2) AS DISTINCT_COUNT_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') = COUNT(*) AS IS_UNIQUE,
                       NULL AS MIN,
                       NULL AS MAX,
                       NULL AS AVG,
                       NULL AS MODE,
                       CONVERT_TIMEZONE(''UTC'', CURRENT_TIMESTAMP()) AS PROFILED_AT
                 FROM '||record.table_catalog||'.'||record.table_schema||'.'||record.table_name||' ';
    ELSEIF(record.data_type = 'BINARY') THEN
        sql := 'SELECT '''||record.table_name||''' AS TABLENAME, 
                       '''||record.column_name||''' AS COLUMN_NAME, 
                       '''||record.data_type||''' AS DATA_TYPE, 
                       '''||record.ordinal_position||''' AS ORDINAL_POSITION,
                       COUNT('||record.column_name||') AS ROW_COUNT,
                       SUM(CASE WHEN (CASE WHEN '||record.column_name||'::VARCHAR = '''' THEN NULL ELSE '||record.column_name||' END ) IS NULL THEN 0 ELSE 1 END)  AS NOT_NULL_COUNT,
                       ROUND(((SUM(CASE WHEN (CASE WHEN '||record.column_name||'::VARCHAR = '''' THEN NULL ELSE '||record.column_name||' END ) IS NULL THEN 0 ELSE 1 END)) / CAST(COUNT(*) AS NUMERIC)) * 100, 2) AS NOT_NULL_PERCENTAGE,
                       SUM(CASE WHEN (CASE WHEN '||record.column_name||'::VARCHAR = '''' THEN NULL ELSE '||record.column_name||' END ) IS NULL THEN 1 ELSE 0 END) AS NULL_COUNT,
                       ROUND(((SUM(CASE WHEN (CASE WHEN '||record.column_name||'::VARCHAR = '''' THEN NULL ELSE '||record.column_name||' END ) IS NULL THEN 1 ELSE 0 END)) / CAST(COUNT(*) AS NUMERIC)) * 100, 2) AS NULL_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') AS DISTINCT_COUNT,
                       ROUND(COUNT(DISTINCT '||record.column_name||')/CAST(COUNT(*) AS NUMERIC) * 100, 2) AS DISTINCT_COUNT_PERCENTAGE,
                       COUNT(DISTINCT '||record.column_name||') = CAST(COUNT(*) AS NUMERIC) AS IS_UNIQUE,
                       MIN(LEN('||record.column_name||'))::float AS MIN,
                       MAX(LEN('||record.column_name||'))::float AS MAX,
                       NULL AS AVG,
                       NULL AS MODE,
                       CONVERT_TIMEZONE(''UTC'', CURRENT_TIMESTAMP()) AS PROFILED_AT
                 FROM '||record.table_catalog||'.'||record.table_schema||'.'||record.table_name||' ';
    -- ELSE
    --     sql := ' ';
    END IF;
    IF(final_sql<>'') THEN 
        final_sql := final_sql || ' UNION ALL ';
    END IF;
    final_sql := final_sql || sql;
  END FOR;
  res := (EXECUTE IMMEDIATE :final_sql);
  RETURN TABLE(res);
  --RETURN final_sql;
END;
