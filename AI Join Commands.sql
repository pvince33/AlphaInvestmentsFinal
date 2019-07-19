/****** Script for joining DimCard  ******/
SELECT 
	 CL.[card_id],
      CL.[card_name],
      CL.[set_name]	,
	  CL.cmc,
	  ISNULL (CL.mana_cost,'') As casting_cost,
	  CL.type_line,
	  CL.rarity,
	  CL.artist,
      CEL.[standard],
      CEL.[modern]	,
      CEL.[legacy]	,
      CEL.[pauper]	,
      CEL.[vintage]	,
	  SR.released_at,
	  SR.set_type
  FROM [AlphaInvestmentsFinal].[dbo].[Card_Event_Legality] AS CEL
INNER JOIN Card_List AS CL 
ON CEL.card_id = CL.card_id
INNER JOIN Set_Release AS SR
ON CL.set_name = SR.set_name

/*** Script for Joining dimEvents***/
SELECT 
	EL.event_id,
	EL.event_name,
	EL.event_format,
	EL.state,
	EL.city,
	ISNULL (Corp.corp_name, 'Unsponsored') As Sponsor

FROM Event_List AS EL
INNER JOIN Corporation_List AS Corp
ON EL.corp_id=Corp.corp_id

/*** Script for creating dimCustomer***/

SELECT
	Cust.customer_id,
	Cust.first_name,
	Cust.last_name,
	Cust.email,
	Cust.gender,
	Cust.state,
	Cust.city,
	Cust.address,
	Cust.postal_code,
	Survey.decks_owned,
	Survey.fav_color,
	Survey.fav_format

FROM Customer_List AS Cust
INNER JOIN Customer_Survey AS Survey
ON Cust.customer_id = Survey.customer_ID

/** Create Joins for Fact Sales */

SELECT 
	sales.sales_id,
	sales.customer_id,
	sales.card_id,
	sales.agent_id,
	sales.event_id,
	ev.event_date AS date,
	sales.price,
	sales.quantity,
	sales.foil_tag

From Sales_Transactions AS Sales
LEFT JOIN Event_List AS Ev 
ON Sales.event_id = Ev.event_id


/* also agents*/
Select *
From Agent_List
