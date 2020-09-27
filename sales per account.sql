WITH t
AS (SELECT p.PaymentTypeId,
           ii.Price,
           roles.Rolename AS SalesAccountType
    FROM Fanava_CRM.dbo.Invoices AS inv
        INNER JOIN Fanava_CRM.dbo.InvoiceItems AS ii
            ON ii.InvoiceId = inv.Id
        INNER JOIN Fanava_CRM.dbo.Contacts AS cont
            ON cont.ContactId = inv.ContactId
        --LEFT JOIN  Fanava_CRM.dbo.PersonalContacts AS person
        -- ON person.ContactId = cont.ContactId
        LEFT JOIN Fanava_CRM.dbo.CompanyContacts AS company
            ON company.ContactId = cont.ContactId
        LEFT JOIN Fanava_CRM.dbo.Orders AS ord
            ON ord.OrderId = ii.OrderId
        LEFT JOIN Fanava_CRM.dbo.Services AS ser
            ON ser.ServiceId = ii.ServiceId
        LEFT JOIN Fanava_CRM.dbo.aspnet_Users AS u
            ON u.UserId = cont.AccountManagerId
        INNER JOIN Fanava_CRM.dbo.InvoiceTypes AS itype
            ON itype.Id = inv.InvoiceTypeId
        LEFT JOIN Fanava_CRM.dbo.Products AS pr
            ON pr.ProductId = ii.ProductId
        LEFT JOIN LiveDbs.dbo.ForooshRolesForGozaresheForoosh AS roles
            ON roles.Username = u.UserName
        LEFT JOIN Fanava_CRM.dbo.InvoiceStates AS ist
            ON ist.Id = inv.InvoiceStatus
        LEFT JOIN dbo.Payments AS p
            ON p.InvoiceId = inv.Id
               AND p.PaymentStatus = 2
        LEFT JOIN dbo.PaymentStates ps
            ON ps.Id = p.PaymentStatus
        LEFT JOIN dbo.PaymentTypes pt
            ON pt.Id = p.PaymentTypeId
    WHERE (inv.InvoiceStatus = 20
          -- OR inv.InvoiceStatus = 30
          )
          
          AND CONVERT(DATE, inv.FinalizeDate)
          BETWEEN '2020-07-08' AND '2020-07-10'
)
SELECT FORMAT(SUM(   CASE
                         WHEN t.SalesAccountType = 'dir-group' THEN
                             t.Price
                         ELSE
                             0
                     END
                 ),
              '#,#'
             ) AS 'direct-sales',
       FORMAT(SUM(   CASE
                         WHEN t.SalesAccountType = 'reg-group' THEN
                             t.Price
                         ELSE
                             0
                     END
                 ),
              '#,#'
             ) AS 'reg-sales',
FORMAT(SUM(   CASE
                         WHEN t.SalesAccountType = 'org-group'  AND t.PaymentTypeId NOT LIKE 6 THEN
                             t.Price
                         ELSE
                             0
                     END
                 ),
              '#,#'
             ) AS 'org-sales'
FROM t;


 