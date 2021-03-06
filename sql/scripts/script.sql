if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MessageLogger_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MessageLogger_sp]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Opponent_History_Save_SP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Opponent_History_Save_SP]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Opponent_History_Select_SP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Opponent_History_Select_SP]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RegisterPlayer_sp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RegisterPlayer_sp]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblOpponentHistory]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblOpponentHistory]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tblPlayerGUID_temp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tblPlayerGUID_temp]
GO

CREATE TABLE [dbo].[tblOpponentHistory] (
	[iOpponentHistoryID] [int] IDENTITY (1, 1) NOT NULL ,
	[sOpponentPlayerID] [varchar] (36) NULL ,
	[iOpponentBotID] [int] NULL ,
	[iOpponentMoveID] [int] NULL ,
	[iMyMoveID] [int] NULL ,
	[iOpponentPoints] [int] NULL ,
	[iMyPoints] [int] NULL ,
	[dtGame] [datetime] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[tblPlayerGUID_temp] (
	[Player_GUID] [nvarchar] (50) NULL 
) ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE MessageLogger_sp (
		@vcCallingProcedure varchar(50),
		@fStepNumber float,
		@dtActionStart datetime,
		@iErrorNumber int,
		@vcMessage varchar(2000)
)

AS

-- 
-- Procedure Name:		MessageLogger_sp
-- Author:			Paul Delcogliano 
-- Date:				Sept. 20, 1999
-- Purpose:			Logs messages from stored procedures and
--				returns status codes to the calling 
--				procedure
-- Parameters:
--	sCallingProcedure	Character; Name of the calling procedure
--	iStepNumber		Integer; Step number from the calling procedure
--				used to identify a point of failure
--	dActionStart		DateTime; Begining time of the procedure call
--	iErrorNumber		Integer; Error code supplied for the calling
--				procedure
--	sMessage		Character; Message to log in a log table
--	sAdditionalMessage	Character; Any additional text message(s)
-- Returns:
--				Integer; If 0, calling procedure should continue.
--				If <> 0, calling procedure should stop processing and
--				report errors to user
-- Edit History:
--	Paul Delcogliano 10/12/1999
--				Added SQL to delete oldest (greater than 30 days old) 
--				from the message log table (tbl_MessageLog)
--


DECLARE  @vcLoginName varchar(50)
DECLARE  @iActionLength int
DECLARE  @iOldMessageCount int

-- Create lookup table tbl_MessageLog if it does not exist 
-- in the current database.
/*IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.tblMessageLog') AND sysstat & 0xf = 3)
BEGIN   
	CREATE TABLE tblMessageLog (
        	iMessageID int IDENTITY (1, 1) NOT NULL ,
	        vcProcedureName varchar(30) NOT NULL ,	        iActionLength int NOT NULL ,
		fStepNumber float NOT NULL ,
	        vcLoginName varchar (50) NOT NULL ,
         	dtStartTime datetime NOT NULL ,
		dtEndTime datetime NOT NULL ,
		iErrorCode int NOT NULL ,
		vcMessage varchar(2000) NOT NULL 
		CONSTRAINT PK_tblMessageLog_MessageID PRIMARY KEY (iMessageID) 
		)

	GRANT  SELECT, INSERT  ON tblMessageLog  TO public
END */


-- Obtain UserName and calculate number of whole minutes between
-- incoming parameter @ActionStart and current time.
SELECT  @vcLoginName = SUSER_NAME() 
SELECT  @iActionLength = ABS(DATEDIFF(mi, @dtActionStart, GETDATE()))


-- Remove records from the message log table 
-- that are more that 30 days old
/*
SELECT	 @iOldMessageCount = (SELECT COUNT(*) FROM tblMessageLog WHERE DATEDIFF(dd, dtEndTime, GETDATE()) > 30)

IF @iOldMessageCount > 0
BEGIN
	DELETE	 tblMessageLog
	WHERE	 DATEDIFF(dd, dtEndTime, GETDATE()) > 30


	-- Insert one record into tlkp_ActionLog with action info.
	INSERT INTO tblMessageLog (vcProcedureName, iActionLength, fStepNumber, vcLoginName, 
	 	 dtStartTime, dtEndTime, iErrorCode, vcMessage)
	VALUES ('MessageLogger_sp', 0, 1, @vcLoginName, GETDATE(),  
   		 GETDATE(), 0, 'Messages more than 30 days old have been deleted')

END
*/

-- Insert one record into tlkp_ActionLog with action info.
INSERT INTO tblMessageLog (vcProcedureName, iActionLength, fStepNumber, vcLoginName, 
	 dtStartTime, dtEndTime, iErrorCode, vcMessage)
VALUES (@vcCallingProcedure, @iActionLength, @fStepNumber, @vcLoginName, 
	 @dtActionStart, GETDATE(), @iErrorNumber, @vcMessage)

RETURN @iErrorNumber


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE Procedure Opponent_History_Save_SP

@sOpponentPlayerID	varchar(36),
@iOpponentBotID		int,
@iOpponentMoveID	int,
@iMyMoveID		int,
@iOpponentPoints	int,
@iMyPoints		int

As


DECLARE @iSUCCESS smallint
DECLARE @iFAILURE smallint


-- Initialize

SET @iSUCCESS = 0
SET @iFAILURE = -1


Insert tblOpponentHistory (sOpponentPlayerID, iOpponentBotID, iOpponentMoveID, iMyMoveID, 
 iOpponentPoints, iMyPoints)
Values(@sOpponentPlayerID, @iOpponentBotID, @iOpponentMoveID, @iMyMoveID, 
 @iOpponentPoints, @iMyPoints)

		-- Check for errors, if none, commit, if not rollback
		IF (@@ERROR = 0)
 			RETURN @iSUCCESS
		ELSE
			RETURN @iFAILURE

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE Procedure Opponent_History_Select_SP -- 'ABCDEFGHIJKLMNOPQRSTOVWXYZABCDEFGHIJ', 2

@sOpponentPlayerID	varchar(36),
@iOpponentBotID		int

As

Select Top 1 iOpponentMoveID
From tblOpponentHistory
Where sOpponentPlayerID = @sOpponentPlayerID
 And iOpponentBotID = @iOpponentBotID
Order By iOpponentHistoryID Desc


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

CREATE  PROCEDURE RegisterPlayer_sp (
		@vcPUID nvarchar(50),
		@cPlayerId nchar(36) OUTPUT,
	   	@cPIN nchar(36) OUTPUT,
		@tProfile ntext = NULL
)

AS

DECLARE @iSUCCESS smallint
DECLARE @iFAILURE smallint
DECLARE @iInsertError int
DECLARE @vcSPName varchar(50)
DECLARE @dtActionStart datetime
DECLARE @vcMessage varchar(2000)

SET @iSUCCESS = 0
SET @iFAILURE = -1
SET @vcSPName = 'RegisterPlayer_sp'

-- Step 1.0: Only register player if not already registered - registration based on PUID
IF (SELECT COUNT(*) FROM tblPlayerRegistration WHERE vcPUID = @vcPUID) = 0 
BEGIN

	SET @dtActionStart = GETDATE()

	BEGIN TRANSACTION

	INSERT INTO tblPlayerRegistration (vcPUID, tPlayerProfile)
	VALUES (@vcPUID, @tProfile)

	SET 	@iInsertError = @@ERROR

	IF (@iInsertError = 0)
		COMMIT TRANSACTION
	ELSE
	BEGIN

		ROLLBACK TRANSACTION
		
		-- Error during registration, log error
		SET @vcMessage = 'An error occurred trying to insert a record into the player registration table for user: ' + @vcPUID
		EXEC MessageLogger_sp @vcSPNAME, 1.0, @dtActionStart, @iInsertError, @vcMessage
	
		RETURN @iFAILURE

	END
	
END

-- Return PlayerId and PIN
SELECT	 @cPlayerId = CAST(uidPlayerId AS nchar(36)), @cPIN = CAST(uidPIN AS nchar(36))
FROM	 	 tblPlayerRegistration 
WHERE 	 vcPUID = @vcPUID


RETURN @iSUCCESS


GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

