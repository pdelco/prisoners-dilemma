using System;

namespace PrisonersDilemma.Data
{

}




//    Public Function FilterPlayers(ByRef dtPlayers As DataTable,
//      ByVal iPlayer1RegId As Integer, ByVal iPlayer2RegId As Integer) As DataRow()

//        Dim rwLocal As DataRow
//        Const iPROCESSED As Integer = 1

//        oErrHandler.AddProc("FilterPlayers")

//        ' Update player 1 processed flag
//        rwLocal = dtPlayers.Rows.Find(iPlayer1RegId)

//        If Not rwLocal Is Nothing Then
//            rwLocal("Processed") = iPROCESSED
//        End If

//        ' Update player 2 processed flag
//        rwLocal = dtPlayers.Rows.Find(iPlayer2RegId)

//        If Not rwLocal Is Nothing Then
//            rwLocal("Processed") = iPROCESSED
//        End If

//        ' Return players whose processed column contains a null value
//        Return dtPlayers.Select("Processed is Null")

//    End Function

//    Public Overloads Function GetPlayers() As DataTable

//        Dim cmLocal As Sql.SQLDataSetCommand
//        Dim dsLocal As DataSet
//        Dim dtLocal As DataTable
//        Dim aPrimaryKeyCol(1) As DataColumn


//        oErrHandler.AddProc("GetPlayers")

//        dsLocal = New DataSet()
//        cmLocal = New Sql.SQLDataSetCommand("GetBotsForRound_sp", GetConnectionString())
//        cmLocal.FillDataSet(dsLocal, "Players")
//        dtLocal = dsLocal.Tables("Players")
//        aPrimaryKeyCol(0) = dtLocal.Columns("iRegistrationId")
//        dtLocal.PrimaryKey = aPrimaryKeyCol
//        dtLocal.Columns.Add("Processed")

//        Return dtLocal

//    End Function

//    Public Overloads Function GetPlayers(ByVal iRoundNumber As Integer,
//      ByVal dRoundStart As Date) As DataTable

//        Dim dscLocal As Sql.SQLDataSetCommand
//        Dim cmLocal As Sql.SQLCommand
//        Dim dsLocal As DataSet
//        Dim dtLocal As DataTable
//        Dim aPrimaryKeyCol(1) As DataColumn

//        oErrHandler.AddProc("GetPlayers(iRoundNumber, dRoundStart)")

//        cmLocal = New Sql.SQLCommand("GetBotsForRound_sp", GetConnectionString())
//        cmLocal.CommandType = CommandType.StoredProcedure

//        With cmLocal.Parameters

//            .Add(New Sql.SQLParameter("@bRecovery", Sql.SQLDataType.Bit, 1))
//            .Add(New Sql.SQLParameter("@iRoundNumber", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@dtRoundStart", Sql.SQLDataType.DateTime))

//            .Item("@bRecovery").Value = True
//            .Item("@iRoundNumber").Value = iRoundNumber
//            .Item("@dtRoundStart").Value = dRoundStart

//        End With

//        dsLocal = New DataSet()
//        dscLocal = New Sql.SQLDataSetCommand(cmLocal)

//        dscLocal.FillDataSet(dsLocal, "Players")

//        dtLocal = dsLocal.Tables("Players")
//        aPrimaryKeyCol(0) = dtLocal.Columns("iRegistrationId")
//        dtLocal.PrimaryKey = aPrimaryKeyCol
//        dtLocal.Columns.Add("Processed")

//        Return dtLocal

//    End Function

//    Public Function SaveScore(ByVal iGameRound As Integer, ByVal sPlayer1Url As String, _
//      ByVal sPlayer1Id As String, ByVal iPlayer1BotId As Integer, ByVal iPlayer1Move As Integer, _
//      ByRef iPlayer1Points As Integer, ByVal sPlayer2Url As String, ByVal sPlayer2Id As String, _
//      ByVal iPlayer2BotId As Integer, ByVal iPlayer2Move As Integer, ByRef iPlayer2Points As Integer) As Integer


//        Dim cmLocal As SQL.SQLCommand

//        cmLocal = New SQL.SQLCommand("PlayGame_sp", GetConnectionString())
//        cmLocal.CommandType = CommandType.StoredProcedure

//        With cmLocal.Parameters

//            ' Add parameters
//            .Add(New Sql.SQLParameter("RETURN_VALUE", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@iGameRound", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@vcPlayer1Url", Sql.SQLDataType.NVarChar, 500))
//            .Add(New Sql.SQLParameter("@cPlayer1Id", Sql.SQLDataType.NChar, 36))
//            .Add(New Sql.SQLParameter("@iPlayer1BotId", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@iPlayer1Move", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@iPlayer1Points", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@vcPlayer2Url", Sql.SQLDataType.NVarChar, 500))
//            .Add(New Sql.SQLParameter("@cPlayer2Id", Sql.SQLDataType.NChar, 36))
//            .Add(New Sql.SQLParameter("@iPlayer2BotId", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@iPlayer2Move", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@iPlayer2Points", Sql.SQLDataType.Int))

//            ' Set parameter values
//            .Item("RETURN_VALUE").Direction = ParameterDirection.ReturnValue
//            .Item("@iPlayer1Points").Direction = ParameterDirection.Output
//            .Item("@iPlayer2Points").Direction = ParameterDirection.Output
//            .Item("@iGameRound").Value = iGameRound
//            .Item("@vcPlayer1Url").Value = sPlayer1Url
//            .Item("@cPlayer1Id").Value = sPlayer1Id
//            .Item("@iPlayer1BotId").Value = iPlayer1BotId
//            .Item("@iPlayer1Move").Value = iPlayer1Move
//            .Item("@vcPlayer2Url").Value = sPlayer2Url
//            .Item("@cPlayer2Id").Value = sPlayer2Id
//            .Item("@iPlayer2BotId").Value = iPlayer2BotId
//            .Item("@iPlayer2Move").Value = iPlayer2Move

//        End With

//        ' Execute the stored proc
//        cmLocal.ActiveConnection.Open()
//        cmLocal.Execute()
//        iPlayer1Points = CInt(cmLocal.Parameters("@iPlayer1Points").Value)
//        iPlayer2Points = CInt(cmLocal.Parameters("@iPlayer2Points").Value)
//        SaveScore = CInt(cmLocal.Parameters("RETURN_VALUE").Value)

//    End Function

//    Public Function GetTournamentRound() As Integer

//        Dim cmLocal As Sql.SQLCommand

//        oErrHandler.AddProc("GetTournamentRound")

//        cmLocal = New Sql.SQLCommand("GetTournamentRound_sp", GetConnectionString())
//        cmLocal.CommandType = CommandType.StoredProcedure

//        With cmLocal.Parameters

//            ' Add parameters
//            .Add(New Sql.SQLParameter("@iGameRound", Sql.SQLDataType.Int))

//            ' Set parameter values
//            .Item("@iGameRound").Direction = ParameterDirection.Output

//        End With

//        ' Execute the stored proc
//        cmLocal.ActiveConnection.Open()
//        cmLocal.Execute()

//        Return CInt(cmLocal.Parameters("@iGameRound").Value)

//    End Function

//    Public Function RecoverRound(ByRef iTournamentRound As Integer,
//      ByRef dRoundStart As Date) As Boolean

//        Dim cmLocal As Sql.SQLCommand
//        Const iRECOVER As Byte = 1

//        oErrHandler.AddProc("RecoverRound")

//        cmLocal = New Sql.SQLCommand("NeedRecovery_sp", GetConnectionString())
//        cmLocal.CommandType = CommandType.StoredProcedure

//        With cmLocal.Parameters

//            ' Add parameters
//            .Add(New Sql.SQLParameter("RETURN_VALUE", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@iRoundNumber", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@dtRoundStart", Sql.SQLDataType.DateTime))

//            ' Set parameter values
//            .Item("RETURN_VALUE").Direction = ParameterDirection.ReturnValue
//            .Item("@iRoundNumber").Direction = ParameterDirection.Output
//            .Item("@dtRoundStart").Direction = ParameterDirection.Output

//        End With

//        ' Execute the stored proc
//        cmLocal.ActiveConnection.Open()
//        cmLocal.Execute()

//        iTournamentRound = CInt(cmLocal.Parameters("@iRoundNumber").Value)
//        dRoundStart = CDate(cmLocal.Parameters("@dtRoundStart").Value)

//        Return(iRECOVER.Equals(CByte(cmLocal.Parameters("RETURN_VALUE").Value)))

//    End Function

//    Public Sub CompleteRound()

//        Dim cmLocal As Sql.SQLCommand
//        oErrHandler.AddProc("CompleteRound")

//        cmLocal = New Sql.SQLCommand("RoundComplete_sp", GetConnectionString())
//        cmLocal.CommandType = CommandType.StoredProcedure

//        ' Execute the stored proc
//        cmLocal.ActiveConnection.Open()
//        cmLocal.Execute()

//    End Sub

//    Public Sub CompleteGame()

//        Dim cmLocal As Sql.SQLCommand

//        cmLocal = New Sql.SQLCommand("GameComplete_sp", GetConnectionString())
//        cmLocal.CommandType = CommandType.StoredProcedure

//        ' Execute the stored proc
//        cmLocal.ActiveConnection.Open()
//        cmLocal.Execute()

//    End Sub

//    Public Function CompleteGameTransaction(ByVal sPlayerId As String,
//      ByVal iBotId As Integer) As Integer

//        Dim cmLocal As Sql.SQLCommand

//        cmLocal = New Sql.SQLCommand("UpdateGameTransaction_sp", GetConnectionString())
//        cmLocal.CommandType = CommandType.StoredProcedure

//        With cmLocal.Parameters

//            .Add(New Sql.SQLParameter("RETURN_VALUE", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@cPlayerId", Sql.SQLDataType.NChar, 36))
//            .Add(New Sql.SQLParameter("@iPlayerBotId", Sql.SQLDataType.Int))

//            .Item("RETURN_VALUE").Direction = ParameterDirection.ReturnValue
//            .Item("@cPlayerId").Value = sPlayerId
//            .Item("@iPlayerBotId").Value = iBotId

//        End With

//        ' Execute the stored proc
//        cmLocal.ActiveConnection.Open()
//        cmLocal.Execute()

//        Return CInt(cmLocal.Parameters("RETURN_VALUE").Value)

//    End Function

//    Public Function StartRound(ByVal bRecoveryRound As Boolean) As Integer

//        Dim cmLocal As Sql.SQLCommand

//        oErrHandler.AddProc("StartRound")

//        If Not bRecoveryRound Then

//            cmLocal = New Sql.SQLCommand("AddRoundTransaction_sp", GetConnectionString())
//            cmLocal.CommandType = CommandType.StoredProcedure

//            ' Execute the stored proc
//            cmLocal.ActiveConnection.Open()
//            cmLocal.Execute()
//            cmLocal.ActiveConnection.Close()

//        End If

//    End Function

//    Public Function GetPlayersForNotification() As Data.DataTable

//        Dim cmLocal As Sql.SQLDataSetCommand
//        Dim dtLocal As DataTable
//        Dim dsLocal As DataSet

//        oErrHandler.AddProc("GetPlayersForNotification")

//        dsLocal = New DataSet()
//        cmLocal = New Sql.SQLDataSetCommand("GetBotsForNotification_sp", GetConnectionString())
//        cmLocal.FillDataSet(dsLocal, "Players")
//        dtLocal = dsLocal.Tables("Players")

//        Return dtLocal

//    End Function

//    Public Function SignedOut(ByVal sPlayerId As String, ByVal iBotId As Integer) As Boolean

//        Dim cmLocal As Sql.SQLCommand
//        Dim iSignedOut As Integer

//        oErrHandler.AddProc("SignedOut")

//        cmLocal = New Sql.SQLCommand("PlayerSignedOut_sp", GetConnectionString())
//        cmLocal.CommandType = CommandType.StoredProcedure

//        With cmLocal.Parameters

//            .Add(New Sql.SQLParameter("@cPlayerId", Sql.SQLDataType.NChar, 36))
//            .Add(New Sql.SQLParameter("@iBotId", Sql.SQLDataType.Int))
//            .Add(New Sql.SQLParameter("@iSignedOut", Sql.SQLDataType.Int))

//            .Item("@cPlayerId").Value = sPlayerId
//            .Item("@iBotId").Value = iBotId
//            .Item("@iSignedOut").Direction = ParameterDirection.Output

//        End With

//        cmLocal.ActiveConnection.Open()
//        cmLocal.Execute()
//        iSignedOut = CInt(cmLocal.Parameters("@iSignedOut").Value)
//        cmLocal.ActiveConnection.Close()

//        SignedOut = (iSignedOut <> 0)

//    End Function

//End Class

