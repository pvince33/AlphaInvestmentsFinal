-- Build for AlphaInvestments written by Patrick Vincent
-- Written for INFO 4240
-- Originally Written: July 13 | Updated:

IF NOT EXISTS( SELECT * FROM sys.databases
	WHERE NAME = N'AlphaInvestmentsDM')
	CREATE DATABASE AlphaInvestmentsDM

GO
--
USE AlphaInvestmentsDM
GO
-- 
-- Drop Tables
--

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'FactSales'
	)
	DROP TABLE FactSales;

--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimEvent'
	)
	DROP TABLE DimEvent;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimCustomer'
	)
	DROP TABLE DimCustomer;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimCard'
	)
	DROP TABLE DimCards;
--
IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimAgent'
	)
	DROP TABLE DimAgent;
	

IF EXISTS(
	SELECT *
	FROM sys.tables
	WHERE NAME = N'DimDate'
	)
	DROP TABLE DimDate;

--
-- Create Tables
--
CREATE TABLE DimDate 
	(Date_SK			INT CONSTRAINT pk_date_sk PRIMARY KEY, 
	Date				DATE,
	FullDate			NCHAR(10),-- Date in MM-dd-yyyy format
	DayOfMonth			INT, -- Field will hold day number of Month
	DayName				NVARCHAR(9), -- Contains name of the day, Sunday, Monday 
	DayOfWeek			INT,-- First Day Sunday=1 and Saturday=7
	DayOfWeekInMonth	INT, -- 1st Monday or 2nd Monday in Month
	DayOfWeekInYear		INT,
	DayOfQuarter		INT,
	DayOfYear			INT,
	WeekOfMonth			INT,-- Week Number of Month 
	WeekOfQuarter		INT, -- Week Number of the Quarter
	WeekOfYear			INT,-- Week Number of the Year
	Month				INT, -- Number of the Month 1 to 12{}
	MonthName			NVARCHAR(9),-- January, February etc
	MonthOfQuarter		INT,-- Month Number belongs to Quarter
	Quarter				NCHAR(2),
	QuarterName			NVARCHAR(9),-- First,Second..
	Year				INT,-- Year value of Date stored in Row
	YearName			CHAR(7), -- CY 2017,CY 2018
	MonthYear			CHAR(10), -- Jan-2018,Feb-2018
	MMYYYY				INT,
	FirstDayOfMonth		DATE,
	LastDayOfMonth		DATE,
	FirstDayOfQuarter	DATE,
	LastDayOfQuarter	DATE,
	FirstDayOfYear		DATE,
	LastDayOfYear		DATE,
	IsHoliday			BIT,-- Flag 1=National Holiday, 0-No National Holiday
	IsWeekday			BIT,-- 0=Week End ,1=Week Day
	Holiday				NVARCHAR(50),--Name of Holiday in US
	Season				NVARCHAR(10)--Name of Season
	);

CREATE TABLE DimCard
(	CardID_SK			INT IDENTITY (1,1) NOT NULL CONSTRAINT pk_card_dim PRIMARY KEY,
	CardID_AK			INT NOT NULL,
	Card_Name			NVARCHAR(60) NOT NULL,
	Set_Name			NVARCHAR(30) NOT NULL,
	CMC					INT NOT NULL,
	Casting_Cost		NVARCHAR(20) NOT NULL,
	Type				NVARCHAR(50) NOT NULL,
	Rarity				NVARCHAR(10)NOT NULL,
	Artist				NVARCHAR(60) NOT NULL,
	SetReleaseDate		DATE NOT NULL,
	Standard_Legal		NVARCHAR(10) NOT NULL,
	Modern_Legal		NVARCHAR(10) NOT NULL,
	Legacy_Legal		NVARCHAR(10) NOT NULL,
	Pauper_Legal		NVARCHAR(10) NOT NULL
);

CREATE TABLE DimAgent
(	AgentID_SK			INT IDENTITY (1,1) NOT NULL CONSTRAINT pk_agent PRIMARY KEY,
	AgentID_AK			INT NOT NULL,
	Full_Name			NVARCHAR(60) NOT NULL,
	Hire_Date			DATE NOT NULL
);

CREATE TABLE DimCustomer
(	CustomerID_SK		INT IDENTITY (1,1) NOT NULL CONSTRAINT pk_customer PRIMARY KEY,
	CustomerID_AK		INT NOT NULL,
	City				NVARCHAR(30) NOT NULL,
	State				NVARCHAR(30) NOT NULL,
	Gender				NVARCHAR(6) NOT NULL,
	Full_Name			NVARCHAR(60) NOT NULL,
	Favorite_Deck		NVARCHAR(30) NOT NULL,
	Decks_Owned			NVARCHAR(30) NOT NULL,
	Favorite_Format		NVARCHAR(30) NOT NULL
);

CREATE TABLE DimEvent
(	EventID_SK			INT IDENTITY (1,1) NOT NULL CONSTRAINT pk_event PRIMARY KEY,
	AgentID_AK			INT NOT NULL,
	EventDate			DATE NOT NULL,
	EventName			NVARCHAR(30) NOT NULL,
	City				NVARCHAR(30) NOT NULL,
	State				NVARCHAR(30) NOT NULL,
	Host				NVARCHAR(30) NOT NULL,
);
CREATE TABLE FactSales
(	Sell_Date_SK	INT NOT NULL,
	Customer_SK		INT NOT NULL,
	CardID_SK		INT NOT NULL,
	Event_SK		INT NOT NULL,
	Agent_SK		INT NOT NULL,
	Card_SK			INT NOT NULL,
	Price			MONEY,
	Quantity		INT,
	Foil			NVARCHAR(10),
	CONSTRAINT pk_fact_sales PRIMARY KEY (Sell_Date_SK, CardID_SK, Event_SK, Card_SK),
	CONSTRAINT fk_sale_dim_date FOREIGN KEY (Sell_Date_SK) REFERENCES DimDate(Date_SK), 
	CONSTRAINT fk_dim_card FOREIGN KEY (CardID_SK) REFERENCES DimCard(CardID_SK),
	CONSTRAINT fk_dim_event FOREIGN KEY (Event_SK) REFERENCES DimEvent(EventID_SK),
	CONSTRAINT fk_dim_customer FOREIGN KEY (Customer_SK) REFERENCES DimCustomer(CustomerID_SK)
);
