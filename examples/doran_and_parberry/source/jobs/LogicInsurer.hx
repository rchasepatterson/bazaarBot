package jobs;
import bazaarbot.Market;
import bazaarbot.agent.BasicAgent;
import bazaarbot.agent.Logic;

/**
 * ...
 * @author larsiusprime
 */
class LogicInsurer extends LogicGeneric
{

	public function new(?data)
	{
		super(data);
	}

	override public function perform(agent:BasicAgent, market:Market)
	{
		var insurance = agent.queryInventory("insurance");

		if (insurance >= 10)
		{
			// slow insurance production rates as quotas meet
			if (agent.inventoryFull)
			{
				makeRoomFor(market, agent,"sickness",2);
			}
		}
		else
		{
			_produce(agent, "insurance", 2);

			/*if (!has_food && agent.inventoryFull)
			{
				makeRoomFor(market, agent,"food",2);
			}*/
		}

		/*var food = agent.queryInventory("food");
		var metal = agent.queryInventory("metal");

		var has_food = food >= 1;
		var has_metal = metal >= 1;

		if (has_food && has_metal)
		{
			//convert all metal into tools
			_produce(agent,"tools",metal);
			_consume(agent,"metal",metal);
		}
		else
		{
			//fined $2 for being idle
			_consume(agent,"money",2);
			if (!has_food && agent.inventoryFull)
			{
				makeRoomFor(market, agent,"food",2);
			}
		}*/
	}

}
