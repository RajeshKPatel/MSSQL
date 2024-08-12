USE [ReportServer];  -- You may change the database name. 
GO 
 
SELECT USR.UserName AS SubscriptionOwner 
      ,SUB.ModifiedDate 
      ,SUB.[Description] 
      ,SUB.EventType 
      ,SUB.DeliveryExtension 
      ,SUB.LastStatus 
      ,SUB.LastRunTime 
      ,SCH.NextRunTime 
      ,SCH.Name AS ScheduleName       
      ,CAT.[Path] AS ReportPath 
      ,CAT.[Description] AS ReportDescription 
FROM dbo.Subscriptions AS SUB 
     INNER JOIN dbo.Users AS USR 
         ON SUB.OwnerID = USR.UserID 
     INNER JOIN dbo.[Catalog] AS CAT 
         ON SUB.Report_OID = CAT.ItemID 
     INNER JOIN dbo.ReportSchedule AS RS 
         ON SUB.Report_OID = RS.ReportID 
            AND SUB.SubscriptionID = RS.SubscriptionID 
     INNER JOIN dbo.Schedule AS SCH 
         ON RS.ScheduleID = SCH.ScheduleID 
ORDER BY SUB.[Description];

SELECT 
  y.SubscriberList, 
  y.ReportPath 
FROM (   
  SELECT  
    PseudoTable.TheseNodes.value('(./Value)[1]', 'varchar(MAX)') AS SubscriberList, 
    x.ReportPath 
     
    FROM (    
      SELECT  
        sub.Description AS Recipients, 
        CAST(sub.ExtensionSettings AS xml) AS Subscribers, 
        cat.[Path] AS ReportPath 
      FROM 
        dbo.Subscriptions sub 
        JOIN dbo.[Catalog] AS cat ON 
          sub.Report_OID = cat.ItemID 
    ) x 
      CROSS APPLY Subscribers.nodes('/ParameterValues/ParameterValue') AS PseudoTable(TheseNodes) 
  WHERE 
    PseudoTable.TheseNodes.value('(./Name)[1]', 'varchar(100)') = 'TO' 
  ) y 
WHERE 
  y.SubscriberList IS NOT NULL 
ORDER BY 
  SubscriberList, 
  ReportPath