CREATE TABLE [dbo].[tblScoringRules] (
	[vcPlayer1Move] [nvarchar] (9) NOT NULL ,
	[vcPlayer2Move] [nvarchar] (9) NOT NULL ,
	[iPlayer1Points] [int] NOT NULL ,
	[iPlayer2Points] [int] NOT NULL 
) 
GO

CREATE TABLE [dbo].[tblActions] (
	[iActionId] [int] IDENTITY (1, 1) NOT NULL ,
	[vcAction] [varchar] (8) NOT NULL 
) 
GO

CREATE TABLE [dbo].[tblBotRegistration] (
	[iRegistrationId] [int] IDENTITY (1, 1) NOT NULL ,
	[uidPlayerId] [uniqueidentifier] NOT NULL ,
	[iBotId] [int] NOT NULL ,
	[tBotProfile] [ntext] NULL ,
	[vcCallbackUrl] [nvarchar] (500) NOT NULL ,
	[iPointTotal] [int] NOT NULL ,
	[vcProductId] [nvarchar] (50) NULL ,
	[bActive] [bit] NOT NULL ,
	[dtSignIn] [datetime] NOT NULL ,
	[dtCreated] [datetime] NOT NULL 
)
GO

CREATE TABLE [dbo].[tblBotRegistrationHistory] (
	[iRegistrationId] [int] NOT NULL ,
	[uidPlayerId] [uniqueidentifier] NOT NULL ,
	[iBotId] [int] NOT NULL ,
	[tBotProfile] [ntext] NULL ,
	[vcCallbackUrl] [nvarchar] (500) NOT NULL ,
	[iPointTotal] [int] NOT NULL ,
	[vcProductId] [nvarchar] (50) NULL ,
	[bActive] [bit] NOT NULL ,
	[dtSignIn_Out] [datetime] NOT NULL ,
	[iAction] [int] NOT NULL ,
	[dtCreated] [datetime] NOT NULL 
)
GO

CREATE TABLE [dbo].[tblMatchup] (
	[iMatchupId] [int] IDENTITY (1, 1) NOT NULL ,
	[uidPlayer1Id] [uniqueidentifier] NOT NULL ,
	[iPlayer1BotId] [int] NOT NULL ,
	[vcPlayer1Move] [varchar] (50) NOT NULL ,
	[iPlayer1Award] [int] NOT NULL ,
	[uidPlayer2Id] [uniqueidentifier] NOT NULL ,
	[iPlayer2BotId] [int] NOT NULL ,
	[vcPlayer2Move] [varchar] (50) NOT NULL ,
	[iPlayer2Award] [int] NOT NULL ,
	[dtGameDateTime] [datetime] NOT NULL 
)
GO

CREATE TABLE [dbo].[tblPlayerRegistration] (
	[iPlayerRegistrationId] [int] IDENTITY (1, 1) NOT NULL ,
	[vcPUID] [nvarchar] (50) NOT NULL ,
	[uidPlayerId]  uniqueidentifier ROWGUIDCOL  NOT NULL ,
	[tPlayerProfile] [ntext] NULL ,
	[dtRegistration] [datetime] NOT NULL 
)
GO

ALTER TABLE [dbo].[tblBotRegistration] WITH NOCHECK ADD 
	CONSTRAINT [PK_tblBotRegistration] PRIMARY KEY  CLUSTERED 
	(
		[iRegistrationId]
	)  
GO

ALTER TABLE [dbo].[tblMatchup] WITH NOCHECK ADD 
	CONSTRAINT [PK_tblMatchup] PRIMARY KEY  CLUSTERED 
	(
		[iMatchupId]
	)  
GO

ALTER TABLE [dbo].[tblBotRegistration] WITH NOCHECK ADD 
	CONSTRAINT [DF__tblBotReg__Point__628FA481] DEFAULT (0) FOR [iPointTotal],
	CONSTRAINT [DF__tblBotReg__Activ__6383C8BA] DEFAULT (1) FOR [bActive],
	CONSTRAINT [DF__tblBotReg__SignI__6477ECF3] DEFAULT (getdate()) FOR [dtSignIn],
	CONSTRAINT [DF_tblBotRegistration_dtCreated] DEFAULT (getdate()) FOR [dtCreated]
GO

ALTER TABLE [dbo].[tblBotRegistrationHistory] WITH NOCHECK ADD 
	CONSTRAINT [DF__tblBotReg__dtCre__75A278F5] DEFAULT (getdate()) FOR [dtCreated]
GO

ALTER TABLE [dbo].[tblMatchup] WITH NOCHECK ADD 
	CONSTRAINT [DF_tblMatchup_dtGameDate] DEFAULT (getdate()) FOR [dtGameDateTime]
GO

ALTER TABLE [dbo].[tblPlayerRegistration] WITH NOCHECK ADD 
	CONSTRAINT [DF_tblPlayerRegistration_PlayerId] DEFAULT (newid()) FOR [uidPlayerId],
	CONSTRAINT [DF_tblPlayerRegistration_Registration] DEFAULT (getdate()) FOR [dtRegistration]
GO

