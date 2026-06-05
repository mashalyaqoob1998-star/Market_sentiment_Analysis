--query to identify and remove duplicates from the customer journey data

With Duplicaterecords AS (
 SELECT
      JourneyID,
      CustomerID,
      ProductID,
      VisitDate,
      Stage,
      Action,
      Duration,
      ROW_NUMBER() OVER (
      PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action 
      ORDER BY JourneyID

    ) AS row_num

FROM
     dbo.customer_journey
 )
 SELECT *
FROM DuplicateRecords
ORDER BY JourneyID
SELECT 
    JourneyID,  
    CustomerID,  
    ProductID,  
    VisitDate,  
    Stage,  
    Action, 
    COALESCE(Duration, avg_duration) AS Duration  -- Replaces missing durations with the average duration for the corresponding date
FROM 
    ( SELECT 
            JourneyID, 
            CustomerID, 
            ProductID,  
            VisitDate, 
            UPPER(Stage) AS Stage,
            Action, 
            Duration, 
            AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,  
            ROW_NUMBER() OVER (
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action 
                ORDER BY JourneyID 
            ) AS row_num  
        FROM 
            dbo.customer_journey  
    ) AS subquery  
WHERE 
    row_num = 1; 