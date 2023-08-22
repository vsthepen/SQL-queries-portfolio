
/* These were some of the queries written by me to build fact, dimension tables and extract data within an operational database */
/* These tables once derived were saved as views and accessed using the SQL connector in Power Bi for further analysis */
/* Clauses & Functions used: Joins, CTE's,Aggregate Functions,TOP ,CASE WHEN, Create View.*/


/* 1. Joining two tables to extract Contract Name and Contract Type */


SELECT TOP (1000) B.[ContractTypeID]
      ,B.[Name] AS ContractName,
	  A.[Name] AS ContractType
 FROM [clonedb].[dbo].[N_CONTRACT_TYPES] A
 INNER JOIN [clonedb].[dbo].[N_CONTRACTS] B
 ON A.ID=B.ContractTypeID


/* 2. Assigning different types of businesses into market segments for better analysis */


SELECT TOP (1000) A.[ID]
      ,A.[Name] AS ContractType,
	  B.Name AS ContractName,
	  [MarketSegment]=
	  CASE WHEN A.[Name] LIKE '%DIRECT RETAIL%' THEN 'SELF REFFERED'
	       WHEN A.[Name] LIKE '%UNCLASIFIED%' THEN 'SELF REFFERED'
	       WHEN A.[Name] LIKE '%INSURE%' THEN 'INSURANCE'
	       WHEN A.[Name] LIKE '%PRIVATE COMPANIES%' THEN 'CORPORATE'
	       WHEN A.[Name] LIKE '%CORPORATE%' THEN 'CORPORATE'
		   WHEN A.[Name] LIKE '%NGO%' THEN 'CORPORATE'
		   WHEN A.[Name] LIKE '%CLINIC%' THEN 'CLINICS/HOSPITAL'
		   WHEN A.[Name] LIKE '%PHARMA%' THEN 'CLINICS/HOSPITAL'
	  ELSE 'OTHERS'
	  END
 FROM [clonedb].[dbo].[N_CONTRACT_TYPES] A
 INNER JOIN [clonedb].[dbo].[N_CONTRACTS] B
 ON A.ID=B.ContractTypeID
 
 
 
 /* 3. Joining two tables to extract product names and category */
 
 
SELECT TOP (1000) A.[DomainID]
      ,A.[Name] AS ProductName,
	  B.Name AS ProductCategory
FROM [clonedb].[dbo].[N_ITEMS] A
INNER JOIN [clonedb].[dbo].[N_LAB_DOMAINS] B
ON A.DomainID=B.ID



/* 4. Building the fact table by joining multiple tables, then saved the result table as a view */


CREATE VIEW allfacttables AS
SELECT
  A.ID,
  A.ContractID,
  RequestDate,
  ExternalBarCodeID,
  distributionChannelID,
  dispatchUserID,
  A.ReferralOrganisationID,
  B.RegistrationPointId,
  B.ItemID,
  B.AcceptedPrice,
  B.Qty,
  (B.AcceptedPrice*B.Qty) AS TotalValue,
  C.Name AS DistributionChannel,
  D.Name AS ContractName,
  E.Name AS RegPointName,
  F.Name AS ItemName,
  G.FirstName,G.LastName,
  H.Name AS RefferalOrganisationName
  FROM [clonedb].[dbo].[R_RECEPTION_NOTES] A
  JOIN [clonedb].[dbo].[R_RECEPTION_NOTE_DETAILS] B
  ON A.ID=B.ReceptionNoteID
 INNER JOIN [clonedb].[dbo].[N_DISTRIBUTION_CHANNEL] C
  ON A.distributionChannelID=C.ID
 INNER JOIN [clonedb].[dbo].[N_CONTRACTS] AS D
  ON A.ContractID=D.ID
  INNER JOIN [clonedb].[dbo].[N_REGISTRATION_POINTS] E
  ON B.RegistrationPointId=E.ID
  INNER JOIN [clonedb].[dbo].[N_ITEMS] F
  ON B.ItemID=F.ID
  INNER JOIN [clonedb].[dbo].[N_STAFF] G
  ON A.dispatchUserID=G.ID
  INNER JOIN [clonedb].[dbo].[N_REFERRAL_ORGANISATIONS] H
  ON A.ReferralOrganisationID=H.ID

