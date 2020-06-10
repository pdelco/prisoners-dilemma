<%@ WebService Language="vb" class="Prisoner"%>


Imports System.Web.Services
Imports System.Data
Imports System.Xml.Serialization
Imports System.Web.Services.Protocols


Public Class Prisoner
    Inherits WebService
    
    Private Const COMPETE As Integer = 0
    Private Const COOPERATE As Integer = 1
    Private Const iSUCCESS As Integer = 0
    Private Const iFAILURE As Integer = -1
    Private Const sBOT_NAME As String = "My Prisoner"
    Private Const iSERVICE_TIMEOUT As Integer = 10000  ' Ten seconds
    Private Const sREGISTRATION_SERVICE_URL = "http://dellpiii866/registration/registration.asmx"  ' This value should be replaced with actual reg service url address
    Private Const sDB_CONNECTION_STRING = "Your Database Connection String"

    Private Class  cReg
        Inherits System.Web.Services.Protocols.SoapClientProtocol
        
        Public Sub New()
            MyBase.New
            Me.Url = sREGISTRATION_SERVICE_URL 
        End Sub
        
        Public Function <System.Web.Services.Protocols.SoapMethodAttribute("http://tempuri.org/SignIn")> SignIn(ByVal  sPIN As String, ByVal  iBotId As Integer, ByVal  sBotProfile As String, ByVal  sCallbackUrl As String, ByVal  sProductId As String) As Integer
            Dim results() As Object = Me.Invoke("SignIn", New Object() {sPIN, iBotId, sBotProfile, sCallbackUrl, sProductId})
            Return CType(results(0),Integer)
        End Function
        Public Function BeginSignIn(ByVal sPIN As String, ByVal iBotId As Integer, ByVal sBotProfile As String, ByVal sCallbackUrl As String, ByVal sProductId As String, ByVal callback As System.AsyncCallback, ByVal asyncState As Object) As System.IAsyncResult
            Return Me.BeginInvoke("SignIn", New Object() {sPIN, iBotId, sBotProfile, sCallbackUrl, sProductId}, callback, asyncState)
        End Function
        Public Function EndSignIn(ByVal asyncResult As System.IAsyncResult) As Integer
            Dim results() As Object = Me.EndInvoke(asyncResult)
            Return CType(results(0),Integer)
        End Function
        Public Function <System.Web.Services.Protocols.SoapMethodAttribute("http://tempuri.org/SignOut")> SignOut(ByVal  sPIN As String, ByVal  iBotId As Integer) As Integer
            Dim results() As Object = Me.Invoke("SignOut", New Object() {sPIN, iBotId})
            Return CType(results(0),Integer)
        End Function
        Public Function BeginSignOut(ByVal sPIN As String, ByVal iBotId As Integer, ByVal callback As System.AsyncCallback, ByVal asyncState As Object) As System.IAsyncResult
            Return Me.BeginInvoke("SignOut", New Object() {sPIN, iBotId}, callback, asyncState)
        End Function
        Public Function EndSignOut(ByVal asyncResult As System.IAsyncResult) As Integer
            Dim results() As Object = Me.EndInvoke(asyncResult)
            Return CType(results(0),Integer)
        End Function
        
    End Class


    
    '*******************************************************************
    ' Web Method that is called from VB interface, and makes a call to
    ' Registry Web Service SignIn Method.  This function returns a success / failure
    ' code, and then passes the code back to the VB application.
    '*******************************************************************
    Public Function <WebMethod()> GameSignIn(ByVal sPIN As String, _
     ByVal iBotID As Integer, ByVal sBotName As String, ByVal sCallbackURL As String, _
     ByVal sProductID As String) As Integer
        
        ' Declares and instantiates an occurance of the Registry web service
        Dim oWebService As cReg
        
        oWebService = New cReg()
        oWebService.Timeout = iSERVICE_TIMEOUT
        Return oWebService.SignIn(sPIN, iBotID, sBotName, sCallbackURL, sProductID)
        
    End Function
    
    
    '*******************************************************************
    ' Web Method that is called from the Game Master. This function accepts
    ' the Opponent's ID and their Bot's ID, and returns an integer.
    '           
    '                       COMPETE   = 0
    '                       COOPERATE = 1
    '
    '*******************************************************************
    Public Function <WebMethod()> GetMove(ByVal sOpponentPlayerID As String, _
     ByVal iOpponentBotID As Integer) As Integer
        
        Try
            
            GetMove = COMPETE
            
        Catch
            ' If a failure occurs send back any move to avoid a timeout penalty
            GetMove = COOPERATE
           
        End Try
        
    End Function
    
    
    '*******************************************************************
    ' Web Method that is called from Game Master, making the results
    ' of the match available to the two participants. This allows
    ' the bot to maintain a history of moves against their opponents.
    '*******************************************************************
    Public Sub <WebMethod()> SaveScore( _
      ByVal sOpponentPlayerID As String, ByVal iOpponentBotID As Integer, _
      ByVal iOpponentMoveID As Integer, ByVal iMyMoveID As Integer, _
      ByVal iOpponentPoints As Integer, ByVal iMyPoints As Integer)
        

        Dim cm As System.Data.SQL.SQLCommand
        
        cm = New System.Data.SQL.SQLCommand("Opponent_History_Save_SP", _
          sDB_CONNECTION_STRING)

        cm.CommandType = System.Data.CommandType.StoredProcedure
        
        With cm.Parameters
            
            ' Add parameters
            .Add(New System.Data.SQL.SQLParameter("@sOpponentPlayerID", _
              System.Data.SQL.SQLDataType.VarChar, 36))
            .Add(New System.Data.SQL.SQLParameter("@iOpponentBotID", _
              System.Data.SQL.SQLDataType.Int))
            .Add(New System.Data.SQL.SQLParameter("@iOpponentMoveID", _
              System.Data.SQL.SQLDataType.Int))
            .Add(New System.Data.SQL.SQLParameter("@iMyMoveID", _
              System.Data.SQL.SQLDataType.Int))
            .Add(New System.Data.SQL.SQLParameter("@iOpponentPoints", _
              System.Data.SQL.SQLDataType.Int))
            .Add(New System.Data.SQL.SQLParameter("@iMyPoints", _
              System.Data.SQL.SQLDataType.Int))
            
            ' Set parameter values
            .Item("@sOpponentPlayerID").Value = sOpponentPlayerID
            .Item("@iOpponentBotID").Value = iOpponentBotID
            .Item("@iOpponentMoveID").Value = iOpponentMoveID
            .Item("@iMyMoveID").Value = iMyMoveID
            .Item("@iOpponentPoints").Value = iOpponentPoints
            .Item("@iMyPoints").Value = iMyPoints
            
        End With
        
        ' Execute the stored proc
        cm.ActiveConnection.Open()
        cm.Execute()
        cm.ActiveConnection.Close()
        cm = Nothing

    End Sub
    
    
    '*******************************************************************
    ' Web Method that is called from VB interface, and makes a call to
    ' Registry web service SignOut Method.  This function returns success / failure
    ' code, and then passes the code back to the VB application.
    '*******************************************************************
    Public Function <WebMethod()> GameSignOut(ByVal sPIN As String, _
     ByVal iBotID As Integer) As Integer
        
        ' Declares and instantiates an occurence of the Game Master
        Dim oWebService As cReg
        
        oWebService = New cReg()
        oWebService.Timeout = iSERVICE_TIMEOUT
        
        Return oWebService.SignOut(sPIN, iBotID)
        
    End Function
    
End Class

