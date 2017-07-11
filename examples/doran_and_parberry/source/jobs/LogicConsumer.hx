package jobs;
import bazaarbot.agent.BasicAgent;
import bazaarbot.Market;
/**
 * ...
 * @author larsiusprime
 */
class LogicConsumer extends LogicGeneric
{

	public function new(?data:Dynamic)
	{
		super(data);
	}

	override public function perform(agent:BasicAgent, market:Market)
	{
		var sickness = agent.queryInventory("sickness");
		var insurance = agent.queryInventory("insurance");
		var healths = agent.queryInventory("healths");
		var healthm = agent.queryInventory("healthm");
		var healthl = agent.queryInventory("healthl");

		var has_insurance = insurance >= 1;

		//_produce(agent,"money",2);

		if (sickness >= 6)
		{
			if (healthm >= 1)
			{
				_consume(agent, "healthm", 1, 1);
				_consume(agent, "money", 1, 1);
				_consume(agent, "sickness", 1, 0.93);
			}
		}
		else if (sickness >= 3 && has_insurance)
		{
			if (healthl >= 1)
			{
				_consume(agent, "healthl", 1, 1);
				_consume(agent, "sickness", 1, 0.93);
			}
		}
		else if (sickness >= 1 && has_insurance)
		{
			if (healths >= 1)
			{
				_consume(agent, "healths", 1, 1);
				_consume(agent, "sickness", 1, 0.93);
			}
		}
		else
		{
			// Chance to get sick
			_produce(agent, "sickness", 1, 0.1);
			// Chance to get /more sick/
			_produce(agent, "sickness", 2, 0.01);
			// Chance to get /very/ sick
			_produce(agent, "sickness", 8, 0.005);
		}


		/*var wood = agent.queryInventory("wood");
		var tools = agent.queryInventory("tools");

		var has_wood = wood >= 1;
		var has_tools = tools >= 1;

		if (has_wood)
		{
			if (has_tools)
			{
				//produce 4 food, consume 1 wood, break tools with 10% chance
				_produce(agent,"food",4,1);
				_consume(agent,"wood",1,1);
				_consume(agent,"tools",1,0.1);
			}
			else{
				//produce 2 food, consume 1 wood
				_produce(agent,"food",2,1);
				_consume(agent,"wood",1,1);
			}
		}
		else
		{
			//fined $2 for being idle
			_consume(agent,"money",2);
		}*/
	}
}