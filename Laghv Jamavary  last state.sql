WITH t
AS (SELECT o.Username,
           a.TimeStamp AS startdate,
           b.TimeStamp AS enddate,
           CAST(b.TimeStamp AS DATE) AS PBIDate,
           a.WorkflowInstance,
           a.WorkflowFromState AS Fromid,
           a.WorkflowFromStateDescription AS fromstate,
           b.WorkflowToStateDescription AS tostate,
           b.WorkflowToState AS Toid,
           o.TelecommunicationCenterId,
           w.TypeId,
           o.OrderId,
           a.OperatorId,
           roles.Rolename,
           city.CityId,
           pro.ProvinceId,
           o.CurrentServiceId AS ServiceId,
           roles.Username AS Resellername
    FROM dbo.WorkflowHistories AS a
        INNER JOIN dbo.WorkflowHistories AS b
            ON a.WorkflowInstance = b.WorkflowInstance
        INNER JOIN dbo.Workflows w
            ON w.InstanceId = b.WorkflowInstance
        INNER JOIN dbo.WorkflowOrders wo
            ON wo.InstanceId = w.InstanceId
        INNER JOIN dbo.Orders o
            ON o.OrderId = wo.OrderId
        INNER JOIN dbo.Services ser
            ON ser.ServiceId = o.CurrentServiceId
        INNER JOIN dbo.TelecommunicationCenters Tc
            ON Tc.Id = o.TelecommunicationCenterId
        INNER JOIN dbo.Cities city
            ON city.CityId = Tc.CityId
        INNER JOIN dbo.Provinces pro
            ON pro.ProvinceId = city.ProvinceId
        INNER JOIN dbo.Contacts c
            ON c.ContactId = o.ContactId
        INNER JOIN dbo.aspnet_Users u
            ON u.UserId = c.AccountManagerId
        LEFT JOIN LiveDbs.dbo.ForooshRolesForGozaresheForoosh roles
            ON roles.Username = u.UserName
    WHERE (
              a.WorkflowFromState = 310
              AND b.WorkflowToState = -300
          )
          OR
          (
              a.WorkflowFromState = 320
              AND b.WorkflowToState = -300
          )
          OR (
                 a.WorkflowFromState = 330
                 AND b.WorkflowToState = -300
             )
             AND w.TypeId = 'A3416996-783D-4ACC-9F1A-0D2E1A1E1417'),
     cte2
AS (SELECT FORMAT(t.startdate, 'yyyy/MM/dd HH:mm', 'fa-IR') AS shoro,
           FORMAT(t.enddate, 'yyyy/MM/dd HH:mm', 'fa-IR') AS payan,
           t.PBIDate,
           t.WorkflowInstance,
           t.Fromid,
           t.fromstate,
           t.tostate,
           t.Toid,
           t.TypeId,
           t.OrderId,
           t.Username,
           t.TelecommunicationCenterId,
           t.CityId,
           t.ProvinceId,
           t.Rolename,
           DATEDIFF(DAY, t.startdate, t.enddate) AS jammodat,
           ROW_NUMBER() OVER (PARTITION BY t.WorkflowInstance
                              ORDER BY DATEDIFF(DAY, t.startdate, t.enddate) DESC
                             ) AS radif,
           t.OperatorId,
           t.ServiceId,
           t.Resellername
    FROM t),
     cte3
AS (SELECT cte2.Username,
           cte2.OrderId,
           cte2.fromstate,
           cte2.tostate,
           wfs.WorkflowToStateDescription,
           ROW_NUMBER() OVER (PARTITION BY cte2.Username ORDER BY wfs.TimeStamp DESC) AS radif2
    FROM cte2
        INNER JOIN dbo.WorkflowHistories wfs
            ON wfs.WorkflowInstance = cte2.WorkflowInstance
    WHERE cte2.radif = 1)
SELECT *
FROM cte3
WHERE cte3.radif2 = 1;

