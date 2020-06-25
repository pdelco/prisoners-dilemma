using System;
using System.Collections.Generic;

namespace PrisonersDilemma.Model
{
    public class Player
    {
        public Player()
        {
            PlayerId = Guid.NewGuid();
            Registered = DateTime.Now;
        }

        public Guid PlayerId { get; private set; }

        public string Profile { get; set; }

        public string Email { get; set; }

        public DateTime Registered { get; private set; }

        public List<AzureFunctionBot> AzureFunctionBots { get; set; }
    }
}
