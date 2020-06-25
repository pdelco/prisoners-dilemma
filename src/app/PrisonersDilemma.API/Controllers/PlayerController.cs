using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using PrisonersDilemma.Model;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace PrisonersDilemma.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PlayerController : ControllerBase
    {
        private static List<Player> _testPlayers = new List<Player>() 
        { 
            new Player { Email = "pdelco@abc.com", Profile = "profile 1" }, 
            new Player { Email = "pdelco@test.com", Profile = "profile 2" } 
        };

    //      Public Function FilterPlayers(ByRef dtPlayers As DataTable,
    //ByVal iPlayer1RegId As Integer, ByVal iPlayer2RegId As Integer) As DataRow()

    //      Dim rwLocal As DataRow
    //      Const iPROCESSED As Integer = 1

    //      oErrHandler.AddProc("FilterPlayers")

    //      ' Update player 1 processed flag
    //      rwLocal = dtPlayers.Rows.Find(iPlayer1RegId)

    //      If Not rwLocal Is Nothing Then
    //          rwLocal("Processed") = iPROCESSED
    //      End If

    //      ' Update player 2 processed flag
    //      rwLocal = dtPlayers.Rows.Find(iPlayer2RegId)

    //      If Not rwLocal Is Nothing Then
    //          rwLocal("Processed") = iPROCESSED
    //      End If

    //      ' Return players whose processed column contains a null value
    //      Return dtPlayers.Select("Processed is Null")

    //  End Function

    //  Public Overloads Function GetPlayers() As DataTable

    //      Dim cmLocal As Sql.SQLDataSetCommand
    //      Dim dsLocal As DataSet
    //      Dim dtLocal As DataTable
    //      Dim aPrimaryKeyCol(1) As DataColumn


    //      oErrHandler.AddProc("GetPlayers")

    //      dsLocal = New DataSet()
    //      cmLocal = New Sql.SQLDataSetCommand("GetBotsForRound_sp", GetConnectionString())
    //      cmLocal.FillDataSet(dsLocal, "Players")
    //      dtLocal = dsLocal.Tables("Players")
    //      aPrimaryKeyCol(0) = dtLocal.Columns("iRegistrationId")
    //      dtLocal.PrimaryKey = aPrimaryKeyCol
    //      dtLocal.Columns.Add("Processed")

    //      Return dtLocal

    //  End Function

    //  Public Overloads Function GetPlayers(ByVal iRoundNumber As Integer,
    //    ByVal dRoundStart As Date) As DataTable

    //      Dim dscLocal As Sql.SQLDataSetCommand
    //      Dim cmLocal As Sql.SQLCommand
    //      Dim dsLocal As DataSet
    //      Dim dtLocal As DataTable
    //      Dim aPrimaryKeyCol(1) As DataColumn

    //      oErrHandler.AddProc("GetPlayers(iRoundNumber, dRoundStart)")

    //      cmLocal = New Sql.SQLCommand("GetBotsForRound_sp", GetConnectionString())
    //      cmLocal.CommandType = CommandType.StoredProcedure

    //      With cmLocal.Parameters

    //          .Add(New Sql.SQLParameter("@bRecovery", Sql.SQLDataType.Bit, 1))
    //          .Add(New Sql.SQLParameter("@iRoundNumber", Sql.SQLDataType.Int))
    //          .Add(New Sql.SQLParameter("@dtRoundStart", Sql.SQLDataType.DateTime))

    //          .Item("@bRecovery").Value = True
    //          .Item("@iRoundNumber").Value = iRoundNumber
    //          .Item("@dtRoundStart").Value = dRoundStart

    //      End With

    //      dsLocal = New DataSet()
    //      dscLocal = New Sql.SQLDataSetCommand(cmLocal)

    //      dscLocal.FillDataSet(dsLocal, "Players")

    //      dtLocal = dsLocal.Tables("Players")
    //      aPrimaryKeyCol(0) = dtLocal.Columns("iRegistrationId")
    //      dtLocal.PrimaryKey = aPrimaryKeyCol
    //      dtLocal.Columns.Add("Processed")

    //      Return dtLocal

    //  End Function

        // GET: api/<PlayerController>
        [HttpGet]
        [MapToApiVersion("1.0")]
        public async Task<IActionResult> Get()
        {
            if (!_testPlayers.Any())
            {
                return NotFound();
            }
            return Ok(_testPlayers);
        }

        [HttpGet]
        [MapToApiVersion("1.1")]
        public async Task<IActionResult> Get11()
        {
            if (!_testPlayers.Any())
            {
                return NotFound();
            }

            _testPlayers[0].AzureFunctionBots = new List<AzureFunctionBot>() { new AzureFunctionBot { PlayerId = _testPlayers[0].PlayerId, Created = DateTime.Now } };
            return Ok(_testPlayers);
        }

        // GET api/<PlayerController>/5
        [HttpGet("{id}", Name = "Get")]
        public async Task<IActionResult> Get(Guid id)
        {
            Player p = FindPlayerById(id);
            
            if (p == null)
            {
                return NotFound(id);
            }
            return Ok(p);
        }

        // POST api/<PlayerController>
        [HttpPost]
        public async Task<IActionResult> Post([FromBody] Player newPlayer)
        {
            Guid newId = Guid.NewGuid(); //_testPlayers.Max(p => p.PlayerId) + 1;
            Player p = new Player() { Email = newPlayer.Email, Profile = newPlayer.Profile };
            _testPlayers.Add(p);

            return CreatedAtRoute("Get", new { id = p.PlayerId }, p);
        }

        // PUT api/<PlayerController>/5
        [HttpPut("{id}")]
        public async Task<IActionResult> Put(Guid id, [FromBody] Player player)
        {
            Player p = FindPlayerById(id);

            if (p == null)
            {
                return NotFound(id);
            }

            try
            {
                p.Profile = player.Profile;
                p.Email = player.Email;
//                await _context.SaveChangesAsync();
            }
            catch //(DbUpdateConcurrencyException)
            {
                throw;
            }
            return NoContent();
        }

        // DELETE api/<PlayerController>/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(Guid id)
        {
            Player p = FindPlayerById(id);
            if (p == null)
            {
                return NotFound(id);
            }

            _testPlayers.Remove(p);
            return NoContent();
        }

        private Player FindPlayerById(Guid id)
        {
            return _testPlayers.SingleOrDefault(p => p.PlayerId == id);
        }
    }
}
