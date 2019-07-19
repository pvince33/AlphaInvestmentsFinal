-- 
-----------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.databases
	WHERE name = N'AlphaInvestments')
	CREATE DATABASE AlphaInvestments
GO
USE AlphaInvestments
--
-- Alter the path so the script can find the CSV files 
--
DECLARE @data_path NVARCHAR(256);
SELECT @data_path = 'C:\Users\mrroy\OneDrive\Documents\GitHub\AlphaInvestments\';
--
-- Delete existing tables
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Sales_Transactions'
	)
	DROP TABLE Sales_Transactions
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Agent_Transactions'
	)
	DROP TABLE Agent_Transactions

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Card_Inventory'
	)
	DROP TABLE Card_Inventory
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Card_Event_Legality'
	)
	DROP TABLE Card_Event_Legality
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Customer_Survey'
	)
	DROP TABLE Customer_Survey


IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Event_List'
	)
	DROP TABLE Event_List
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Card_list'
       )
	DROP TABLE Card_List;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Set_Release'
		)
	DROP TABLE Set_Release
--
IF EXISTS(
	SELECT *	
	FROM sys.tables
	WHERE name= N'Agent_List'
	)
	DROP TABLE Agent_List
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE name = N'Customer_List'
	)
	DROP TABLE Customer_List
--
-- Create tables
--
CREATE TABLE Customer_List
(	customer_id		int CONSTRAINT pk_customerID PRIMARY KEY,
	first_name		NVARCHAR(30) CONSTRAINT nn_customer_first_name NOT NULL,
	last_name		NVARCHAR(30) CONSTRAINT nn_customer_last_name NOT NULL,
	email			NVARCHAR(50) CONSTRAINT nn_customer_email NOT NULL,
	gender			NVARCHAR(6),
	credit_card_num	NVARCHAR(30),
	state			NVARCHAR(30) CONSTRAINT nn_customer_state NOT NULL,
	city			NVARCHAR(30) CONSTRAINT nn_customer_city NOT NULL,
	address			NVARCHAR(30) CONSTRAINT nn_customer_address NOT NULL,
	postal_code		NVARCHAR(6)  CONSTRAINT nn_customer_postal_code NOT NULL
);

CREATE TABLE Agent_List
(	Agent_ID		INT CONSTRAINT pk_agent_id PRIMARY KEY,
	first_name		NVARCHAR(30) CONSTRAINT nn_agent_first_name NOT NULL,
	last_name		NVARCHAR(30) CONSTRAINT nn_agent_last_name NOT NULL,
	hire_date		DATE CONSTRAINT nn_hire_date NOT NULL
);

CREATE TABLE Set_Release
(	set_abbr		NVARCHAR(6),
	set_name		NVARCHAR(60) CONSTRAINT pk_set_name PRIMARY KEY,
	set_type		NVARCHAR(30),
	released_at		Date CONSTRAINT nn_set_release_date NOT NULL
);
--
CREATE TABLE Card_List 
(	card_name		NVARCHAR(60) CONSTRAINT LegalCardName NOT NULL,		
	mana_cost		NVARCHAR(20),
	cmc				INT,
	type_line		NVARCHAR(90),
	oracle_text		NVARCHAR(MAX),
	colors			NVARCHAR(1),
	color_identity	NVARCHAR(1),
	set_name		NVARCHAR(60) CONSTRAINT fk_card_list_set_name FOREIGN KEY
		REFERENCES Set_Release(set_name),
	collector_number	INT,
	rarity			NVARCHAR(10),
	artist			NVARCHAR(50),
	CONSTRAINT pk_Card_Set_ID PRIMARY KEY (card_name, set_name),
	--set_release_date date CONSTRAINT fk_Set_Release_Date FOREIGN KEY (set_name) REFERENCES Set_Release(released_at)
	);
--
CREATE TABLE Card_Event_Legality
(	card_name		NVARCHAR(60) CONSTRAINT nn_legal_card_name NOT NULL,
	set_name		NVARCHAR(60) CONSTRAINT nn_legal_set_name NOT NULL,
	standard		NVARCHAR(10),
	future			NVARCHAR(10),
	frontier		NVARCHAR(10),
	modern			NVARCHAR(10),
	legacy			NVARCHAR(10),
	pauper			NVARCHAR(10),
	vintage			NVARCHAR(10),
	penny			NVARCHAR(10),
	commander		NVARCHAR(10),
	duel			NVARCHAR(10),
	CONSTRAINT pk_card_set_id_event PRIMARY KEY (card_name, set_name)
);

CREATE TABLE Customer_Survey
(	customer_ID		int CONSTRAINT fk_customerID FOREIGN KEY
			REFERENCES Customer_List(customer_id),
	fav_format		NVARCHAR(10),
	fav_color		NVARCHAR(1),
	decks_owned		int	
);

CREATE TABLE Event_List
(	event_id		int CONSTRAINT event_id_key PRIMARY KEY,
	event_name		NVARCHAR(30),
	event_date		date,
	event_format	NVARCHAR(30),
	attendance		int,
	state			NVARCHAR(30),
	city			NVARCHAR(30)
);
--
CREATE TABLE Card_Inventory
(	card_id			INT CONSTRAINT pk_card_inventory_id PRIMARY KEY,
	card_name		NVARCHAR(60) CONSTRAINT nn_inventory_card_name NOT NULL,
	set_name		NVARCHAR(60) CONSTRAINT nn_inventory_set_name NOT NULL,
	foil_tag		NVARCHAR(10),
	quantity		INT,
	CONSTRAINT fk_inventory_card_set_name FOREIGN KEY (card_name, set_name) 
		REFERENCES Card_List(card_name, set_name),
	CONSTRAINT fk_inventory_set_release FOREIGN KEY (set_name)
		REFERENCES Set_Release(set_name),
	CONSTRAINT fk_inventory_card_event_legality FOREIGN KEY (card_name, set_name)
		REFERENCES Card_Event_Legality (card_name, set_name)
);
--
CREATE TABLE Agent_Transactions
(	transaction_id	INT CONSTRAINT pk_agent_transaction_id PRIMARY KEY,
	agent_id		INT CONSTRAINT fk_agent_id FOREIGN KEY
		REFERENCES Agent_List(Agent_ID),
	event_id		INT CONSTRAINT fk_agent_event_id FOREIGN KEY
		REFERENCES Event_List(event_id),
	card_id			INT CONSTRAINT fk_agent_card_id FOREIGN KEY
		REFERENCES Card_Inventory(card_id),
	price			MONEY CONSTRAINT nn_agent_price NOT NULL,
	qty				INT CONSTRAINT nn_agent_qty NOT NULL
);

--
CREATE TABLE Sales_Transactions
(	sales_id		int CONSTRAINT pk_sell_id PRIMARY KEY,
	customer_id		int CONSTRAINT fk_customer_sell_ID FOREIGN KEY
		REFERENCES Customer_List(customer_id), 
	card_id			int CONSTRAINT fk_card_sell_ID FOREIGN KEY
		REFERENCES Card_Inventory(card_id),
	price			money CONSTRAINT nn_sell_price NOT NULL,
	sell_quantity	int CONSTRAINT nn_sell_qty NOT NULL,
	sell_date		date CONSTRAINT nn_sell_date NOT NULL,
	promotion_tag	NVARCHAR(15)
);
--
-- Load table data
--
--untested
EXECUTE (N'BULK INSERT Customer_List FROM ''' + @data_path + N'Customer List.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');

--compiles
EXECUTE (N'BULK INSERT Agent_List FROM ''' + @data_path + N'Agent List.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');


--Compiles
EXECUTE (N'BULK INSERT Set_Release FROM ''' + @data_path + N'Set Release Dates.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');
--Compiles
EXECUTE (N'BULK INSERT Event_List FROM ''' + @data_path + N'Event List.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');

--Compiles
EXECUTE (N'BULK INSERT Card_List FROM ''' + @data_path + N'Cards Only Simplified list.txt''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= ''\t'',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');
--
--Compiles
EXECUTE (N'BULK INSERT Card_Event_Legality FROM ''' + @data_path + N'Card Format Legality.txt''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= ''\t'',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	TABLOCK
	);
');

EXECUTE (N'BULK INSERT Customer_Survey FROM ''' + @data_path + N'Customer Query.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Card_Inventory FROM ''' + @data_path + N'Cards In Stock 1.1.2018.txt''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= ''\t'',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');
--
EXECUTE (N'BULK INSERT Agent_Transactions FROM ''' + @data_path + N'Agent Transaction List.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');

--
EXECUTE (N'BULK INSERT Sales_Transactions FROM ''' + @data_path + N'Sales Transactions.csv''
WITH (
	CHECK_CONSTRAINTS,
	CODEPAGE=''ACP'',
	DATAFILETYPE = ''char'',
	FIELDTERMINATOR= '','',
	ROWTERMINATOR = ''\n'',
	FIRSTROW = 2,
	KEEPIDENTITY,
	KEEPNULLS,
	TABLOCK
	);
');
--
-- Verify Row Count in Tables.
GO
SET NOCOUNT ON
SELECT 'Set_Release' AS "Table",	COUNT(*) AS "Rows"		  FROM Set_Release  UNION
SELECT 'Agent_List',					COUNT(*) FROM Agent_List					UNION
SELECT 'Card_list',					COUNT(*) FROM Card_List					    UNION
SELECT 'Set_Release',				COUNT(*) FROM Set_Release					UNION
SELECT 'Card Legality',				COUNT(*) FROM Card_Event_Legality			UNION
SELECT 'Event_List',				COUNT(*) FROM Event_List					UNION
SELECT 'Customer_Survey',			COUNT(*) FROM Customer_Survey				UNION
SELECT 'Card Inventory',			COUNT(*) FROM Card_Inventory				UNION
SELECT 'Agent Transactions',		COUNT(*) FROM Agent_Transactions			UNION
SELECT 'Sell_Transactions',			COUNT(*) FROM Sales_Transactions				
ORDER BY 1;
SET NOCOUNT OFF
GO
-- END OF SCRIPT
