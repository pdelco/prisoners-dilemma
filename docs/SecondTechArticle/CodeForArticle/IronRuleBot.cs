    using System;
    using System.Collections;
    using System.Configuration;
    using System.Web;
    using System.Web.Services;

    public class cIronRuleBot : System.Web.Services.WebService
    {
		int COOPERATE = 1;
		int SUCCESS = 0;
		int FAILURE = -1;
		int SERVICE_TIMEOUT = 10000;
		

        public cIronRuleBot()
        {
        }


    	private class cReg : System.Web.Services.Protocols.SoapClientProtocol {

		string REGISTRATION_URL = "http://dellpiii866/pdRegistration/registration.asmx";  // This should be changed to real registration url		
	
        public cReg() {
            this.Url = REGISTRATION_URL;
        }
        
        [System.Web.Services.Protocols.SoapMethodAttribute("http://tempuri.org/SignIn")]
        public int SignIn( string sPIN,  int iBotId,  string sBotName,  string sCallbackUrl,  string sProductId) {
            object[] results = this.Invoke("SignIn", new object[] {sPIN,
                        iBotId,
                        sBotName,
                        sCallbackUrl,
                        sProductId});
            return (int)(results[0]);
        }
        public System.IAsyncResult BeginSignIn(string sPIN, int iBotId, string sBotName, string sCallbackUrl, string sProductId, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("SignIn", new object[] {sPIN,
                        iBotId,
                        sBotName,
                        sCallbackUrl,
                        sProductId}, callback, asyncState);
        }
        public int EndSignIn(System.IAsyncResult asyncResult) {
            object[] results = this.EndInvoke(asyncResult);
            return (int)(results[0]);
        }
        [System.Web.Services.Protocols.SoapMethodAttribute("http://tempuri.org/SignOut")]
        public int SignOut( string sPIN,  int iBotId) {
            object[] results = this.Invoke("SignOut", new object[] {sPIN,
                        iBotId});
            return (int)(results[0]);
        }
        public System.IAsyncResult BeginSignOut(string sPIN, int iBotId, System.AsyncCallback callback, object asyncState) {
            return this.BeginInvoke("SignOut", new object[] {sPIN,
                        iBotId}, callback, asyncState);
        	
		}

	        public int EndSignOut(System.IAsyncResult asyncResult) {
        	    object[] results = this.EndInvoke(asyncResult);
	            return (int)(results[0]);
        	}
        
    	}

        public int SignIn(String sPin, int iBotID, String sBotName, String sCallbackURL, String sProductId)
	{
		int iResult;

		cReg oRegService = new cReg();
		oRegService.Timeout = SERVICE_TIMEOUT;
		iResult = oRegService.SignIn(sPin, iBotID, sBotName, sCallbackURL, sProductId);
		oRegService = null;
		return iResult;
  
	}
    
	public int SignOut(String sPin, int iBotID)
	{
		int iResult;

		cReg oRegService = new cReg();
		oRegService.Timeout = SERVICE_TIMEOUT;
		iResult = oRegService.SignOut(sPin, iBotID);
		oRegService = null;
		return iResult;
   
	}
        
	[WebMethod]
	public int GetMove(String sOpponentPlayerID, int iOpponentBotId)
	{
		//This bot always Cooperates
		return COOPERATE;
	}
    
	[WebMethod]
	public int SaveScore(String sOpponentPlayerId, int iOpponentBotId, int iOpponentMove, int iMyMove, int iOpponentPoints, int iMyPoints)
	{

		string sHistoryFile;
		string sHistoryFolder = "C:/";
		System.IO.StreamWriter oHistory;

		try 
		{
			
			sHistoryFile = sHistoryFolder + sOpponentPlayerId + ".txt";
   
			if (System.IO.File.FileExists(sHistoryFile))
			{
				oHistory = System.IO.File.AppendText(sHistoryFile);	
			}
			else
			{
				oHistory = System.IO.File.CreateText(sHistoryFile);
			}
   
			oHistory.Write(iOpponentBotId.ToString() + ",");
			oHistory.Write(iOpponentMove.ToString() + ",");
			oHistory.Write(iMyMove.ToString() + ",");
			oHistory.Write(iOpponentPoints.ToString() + ",");
			oHistory.Write(iMyPoints.ToString() + ",");
			oHistory.WriteLine(System.DateTime.Now.ToString());
   
			oHistory.Flush();
			oHistory.Close();
   
			oHistory = null;
			return SUCCESS;
		}

		catch(Exception e)
		{
			return FAILURE;
		}
	
	}
       
    }
