CREATE PROC usp_DirectSales
    @start DATETIME,
    @End DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SET @start = N'2018-11-27 15:57:03.800'; -- تاریخ اولین فاکتور ایجاد شده در سال 97
    SET @End = GETDATE();

    SELECT inv.FinalizeDate,
           FORMAT(inv.FinalizeDate, 'yyyy/MM/dd HH:mm', 'fa-IR') FinalizeDatePersian,
           inv.Id,
           inv.Title,
           cont.ContactId,
           --CONCAT(person.FirstName,' ',person.LastName) AS FullName,
           company.CompanyName,
           ord.Username,
           ord.RanjePhoneNumber,
           ord.TelecommunicationCenterId,
           ord.WiFiSiteId,
           ii.ServiceId,
           ii.ProductId,
           ii.Title,
           ii.Price,
           inv.TotalDiscount,
           inv.DiscountCardId,
           ii.Discount,
           inv.PayableAmount,
           itype.[Description],
           u.UserName AS SalesAccountID,
           roles.Rolename AS SalesAccountType,
           ist.[Description] AS 'ServiceStatus',
           CONVERT(DATE, inv.FinalizeDate) AS DateOfFinalaization
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
            ON ser.ServiceId = ord.ServiceId
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
    WHERE (
              inv.InvoiceStatus = 20
              OR inv.InvoiceStatus = 30
          )
          --AND roles.Rolename = N'dir-group'
          AND CONVERT(DATE, inv.FinalizeDate)
          BETWEEN @start AND @End
          AND inv.Id NOT IN ( 13913080590, 13913200515, 13913357402, 13913416032 )
    ORDER BY FinalizeDatePersian;
END;

GO
;