SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO



CREATE   PROCEDURE RegisterPlayer_sp (
		@vcPUID nvarchar(50),
		@cPlayerId nchar(36) OUTPUT,
		@tProfile ntext = NULL
)

AS

DECLARE @iSUCCESS smallint
DECLARE @iFAILURE smallint
DECLARE @iInsertError int

SET @iSUCCESS = 0
SET @iFAILURE = -1

-- Only register player if not already registered - registration based on PUID
IF (SELECT COUNT(*) FROM tblPlayerRegistration WHERE vcPUID = @vcPUID) = 0 
BEGIN

	BEGIN TRANSACTION

	INSERT INTO tblPlayerRegistration (vcPUID, tPlayerProfile)
	VALUES (@vcPUID, @tProfile)

	SET 	@iInsertError = @@ERROR

	IF (@iInsertError = 0)
		COMMIT TRANSACTION
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
		
		-- Log error message
		PRINT @iInsertError

		RETURN @iFAILURE

	END
	
END

-- Return PlayerId
SET	 @cPlayerId = CAST((SELECT uidPlayerId FROM tblPlayerRegistration WHERE vcPUID = @vcPUID) AS nchar(36))

RETURN @iSUCCESS

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO








CREATE        PROCEDURE BotSignIn_sp (
			@cPlayerID nchar(36),
			@iBotId int,
			@tBotProfile ntext,
			@vcCallbackUrl nvarchar(500),
			@vcProductId nvarchar(50) = ''
)

AS

--
-- Procedure Name:		BotSignIn_sp
-- Author:			Paul Delcogliano
-- Date:				Feb. 8, 2001
-- Purpose:			Register a "bot" in the Prisoner's Dilemma game.
--				This proc will be called from a web service.
-- Parameters:
--	@cPlayerId		NChar; GUID assigned to a player when the
--				player registers
--	@iBotId 		Integer; Assigned by player to each of their bots
--	@tBotProfile 		NText; Bot profile data
--	@vcCallbackUrl 	NVarchar; URL used by Game Master to request player moves
--	@vcProductId 		NVarchar; future use
-- Returns:
--	Nothing
-- Edit History:
--

DECLARE @uidPlayerId uniqueidentifier
DECLARE @iAction tinyint
DECLARE @iMaxBots tinyint
DECLARE @iRegError int
DECLARE @iHistoryError int
DECLARE @iSUCCESS smallint
DECLARE @iFAILURE smallint
DECLARE @iALREADY_REGISTERED tinyint

SET @uidPlayerId = CAST(@cPlayerId AS uniqueidentifier)
SET @iAction = 1  -- sign in
SET @iMaxBots = 100
SET @iSUCCESS = 0
SET @iFAILURE = -1
SET @iALREADY_REGISTERED = 1

-- Each user can have up to iMaxBots registered, if attempting to register more, 
-- return a value indicating that they have reached their limit
IF (SELECT COUNT(*) FROM tblBotRegistration WHERE uidPlayerId = @uidPlayerId AND iBotId = @iBotId) = @iMaxBots
BEGIN
	RETURN @iALREADY_REGISTERED
END
 
BEGIN TRANSACTION

IF (SELECT COUNT(*) FROM tblBotRegistration WHERE uidPlayerId = @uidPlayerId AND iBotId = @iBotId) = 0 
BEGIN

	-- If bot is not registered, insert a new record
	INSERT	 INTO tblBotRegistration (uidPlayerId, iBotId, tBotProfile, vcCallbackUrl, vcProductId)
	VALUES	 (@uidPlayerId, @iBotId, @tBotProfile, @vcCallbackUrl, @vcProductId)

	-- Get error info
	SET 	 @iRegError = @@ERROR
END
ELSE
BEGIN

	-- If bot is already registered in, update bot data
	UPDATE	tblBotRegistration
	SET		dtSignIn = GETDATE(),
			tBotProfile = @tBotProfile,
			vcCallbackUrl = @vcCallbackUrl,
			vcProductId = @vcProductId,
			bActive = 1
	WHERE	uidPlayerId = @uidPlayerId
	AND 		iBotId = @iBotId

	-- Get error info
	SET 	 @iRegError = @@ERROR

END

-- Insert record into history table
IF @iRegError = 0
BEGIN

	INSERT 	INTO tblBotRegistrationHistory (iRegistrationId, uidPlayerId, iBotId, tBotProfile, vcCallbackUrl,
			iPointTotal, vcProductId, bActive, dtSignIn_Out, iAction)
	SELECT	iRegistrationId, uidPlayerId, iBotId, tBotProfile, vcCallbackUrl,
			iPointTotal, vcProductId, bActive, dtSignIn, @iAction
	FROM		tblBotRegistration
	WHERE	uidPlayerId = @uidPlayerId
	AND 		iBotId = @iBotId

	SET @iHistoryError = @@ERROR
END

IF (@iRegError = 0 AND @iHistoryError = 0)
BEGIN
	-- All statements were success, commit changes
	COMMIT TRANSACTION
	RETURN @iSUCCESS
END
ELSE
BEGIN
	-- One or more statements failed, rollback changes
	ROLLBACK TRANSACTION

	IF (@iRegError <> 0)
	BEGIN
		-- Error during registration, log error
		PRINT @iRegError

	END
	
	IF (@iHistoryError <> 0)
	BEGIN
		-- Error during history insert, log error
		PRINT @iHistoryError

	END

	RETURN @iFAILURE

END






GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO





CREATE      PROCEDURE BotSignOut_sp (
			@cPlayerID nchar(36),
			@iBotId int
)

AS

--
-- Procedure Name:		BotSignOut_sp
-- Author:			Paul Delcogliano
-- Date:				Feb. 8, 2001
-- Purpose:			Un-register a "bot" in the Prisoner's Dilemma game.
--				This proc will be called from a web service.
-- Parameters:
--	@cPlayerId		NChar; GUID assigned to a player when the
--				player registers
--	@iBotId 		Integer; Assigned by player to each of their bots
-- Returns:
--	
-- Edit History:
--

DECLARE @uidPlayerId uniqueidentifier
DECLARE @iAction tinyint
DECLARE @iSUCCESS smallint
DECLARE @iFAILURE smallint
DECLARE @iUpdateError int
DECLARE @iInsertError int

SET @uidPlayerId = CAST(@cPlayerId AS uniqueidentifier)
SET @iAction = 2   -- sign out
SET @iSUCCESS = 0
SET @iFAILURE = -1

IF (SELECT COUNT(*) FROM tblBotRegistration WHERE uidPlayerId = @uidPlayerId AND iBotId = @iBotId AND bActive = 1) > 0 
BEGIN

	BEGIN TRANSACTION

	-- If bot is already logged in, update sign-in time
	UPDATE	tblBotRegistration
	SET		bActive = 0
	WHERE	uidPlayerId = @uidPlayerId
	AND 		iBotId = @iBotId

	SET @iUpdateError = @@ERROR

	-- Insert record into history table
	INSERT 	INTO tblBotRegistrationHistory (iRegistrationId, uidPlayerId, iBotId, tBotProfile, vcCallbackUrl,
			iPointTotal, vcProductId, bActive, dtSignIn_Out, iAction)
	SELECT	iRegistrationId, uidPlayerId, iBotId, tBotProfile, vcCallbackUrl,
			iPointTotal, vcProductId, bActive, dtSignIn, @iAction
	FROM		tblBotRegistration
	WHERE	uidPlayerId = @uidPlayerId
	AND 		iBotId = @iBotId

	SET @iInsertError = @@ERROR

	IF (@iUpdateError = 0 AND @iInsertError = 0)
	BEGIN
		COMMIT TRANSACTION
		RETURN @iSUCCESS
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION

		-- Log error message
		IF (@iUpdateError <> 0)
		BEGIN
			-- Error updating registration
			Print @iUpdateError
		END

		IF (@iInsertError <> 0)
		BEGIN
			-- Error inserting history
			Print @iInsertError
		END

		RETURN @iFAILURE
	END

END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO





CREATE      PROCEDURE PlayGame_sp (
			@cPlayer1Id nchar(36),
			@iPlayer1BotId int,
			@vcPlayer1Move nvarchar(9),
			@iPlayer1Points int OUTPUT,
			@cPlayer2Id nchar(36),
			@iPlayer2BotId int,
			@vcPlayer2Move nvarchar(9),
			@iPlayer2Points int OUTPUT
)

AS

--
-- Procedure Name:		PlayGame_sp
-- Author:			Paul Delcogliano
-- Date:				Feb. 9, 2001
-- Purpose:			Take 2 matched bots and play a game between them
-- Parameters:
--	@cPlayer1Id		NChar; Player 1's player id
--	@iBot1Id 		Integer; Player 1's bot id
--	@vcPlayer1Move		NVarchar; Player 1's move
--	@iPlayer1Points		Integer; Player 1's points scored based on move
--	@cPlayer2Id		NChar; Player 2's player id
--	@iBot2Id 		Integer; Player 2's bot id
--	@vcPlayer2Move		NVarchar; Player 2's move
--	@iPlayer2Points		Integer; Player 2's points scored based on move
-- Returns:
--	
-- Edit History:
--

DECLARE @uidPlayer1Id uniqueidentifier
DECLARE @uidPlayer2Id uniqueidentifier
DECLARE @iSUCCESS smallint
DECLARE @iFAILURE smallint
DECLARE @iUpdatePlayer1Error int
DECLARE @iUpdatePlayer2Error int
DECLARE @iInsertError int

SET @uidPlayer1Id = CAST(@cPlayer1Id AS uniqueidentifier)
SET @uidPlayer2Id = CAST(@cPlayer2Id AS uniqueidentifier)
SET @iSUCCESS = 0
SET @iFAILURE = -1

-- Get the points for this game based on each player's move
SELECT	 @iPlayer1Points = r.iPlayer1Points, @iPlayer2Points = r.iPlayer2Points
FROM	 tblScoringRules r
WHERE	 r.vcPlayer1Move = @vcPlayer1Move
AND	 r.vcPlayer2Move = @vcPlayer2Move

BEGIN TRANSACTION

-- Insert the moves and points into the match-up table
INSERT INTO tblMatchUp(uidPlayer1Id, iPlayer1BotId, vcPlayer1Move,
	 iPlayer1Award, uidPlayer2Id, iPlayer2BotId, vcPlayer2Move,
	 iPlayer2Award)
VALUES	 (@uidPlayer1Id, @iPlayer1BotId, @vcPlayer1Move,
	 @iPlayer1Points, @uidPlayer2Id, @iPlayer2BotId, 
	 @vcPlayer2Move, @iPlayer2Points)

SET	 @iInsertError = @@ERROR

-- Update each players total points based on the game just played
-- Player 1
UPDATE	 tblBotRegistration
SET	 iPointTotal = iPointTotal + @iPlayer1Points
FROM	 tblBotRegistration
WHERE	 uidPlayerId = @uidPlayer1Id
AND	 iBotId = @iPlayer1BotId

SET	 @iUpdatePlayer1Error = @@ERROR

-- Player 2
UPDATE	 tblBotRegistration
SET	 iPointTotal = iPointTotal + @iPlayer2Points
FROM	 tblBotRegistration
WHERE	 uidPlayerId = @uidPlayer2Id
AND	 iBotId = @iPlayer2BotId

SET	 @iUpdatePlayer2Error = @@ERROR

IF (@iInsertError = 0 AND @iUpdatePlayer1Error = 0 AND @iUpdatePlayer2Error = 0)
BEGIN
	COMMIT TRANSACTION
	RETURN @iSUCCESS
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
	
	-- Log errors
	IF (@iInsertError <> 0)
	BEGIN
		-- Error occurred during insert
		PRINT @iInsertError
	END
	
	IF (@iUpdatePlayer1Error <> 0)
	BEGIN
		-- Error occurred during player 1 update
		PRINT @iUpdatePlayer1Error

	END

	IF (@iUpdatePlayer2Error <> 0)
	BEGIN
		-- Error occurred during player 2 update
		PRINT @iUpdatePlayer2Error	
	END

	RETURN @iFAILURE
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

