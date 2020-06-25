using System;

namespace PrisonersDilemma.Model
{
    public class AzureFunctionBot
    {
        public Guid PlayerId { get; set; }

        public Guid AzureFunctionBotId { get; set; }

        public Guid RegistrationId { get; private set; }

        public string Profile { get; set; }

        public string CallbackURL { get; set; }

        public int PointTotal { get; private set; }

        public bool Active { get; set; }

        public DateTime Created { get; set; }
	}
}
