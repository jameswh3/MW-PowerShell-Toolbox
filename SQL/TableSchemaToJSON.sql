-- This SQL query retrieves the schema of all tables in the 'dbo' schema
-- and formats the output as JSON, including table names and their columns.
-- I use this to generate a JSON representation of the database schema that can be used in agent instructions.

SELECT 
    table_name,
    (
        SELECT 
            column_name,
            data_type,
            is_nullable,
            '' as column_comment
        FROM 
            information_schema.columns c2
        WHERE 
            c2.table_schema = 'dbo'
            AND c2.table_name = c1.table_name
        FOR JSON PATH
    ) as columns
FROM 
    (SELECT DISTINCT table_name 
     FROM information_schema.columns 
     WHERE table_schema = 'dbo') c1
ORDER BY 
    table_name
FOR JSON PATH;