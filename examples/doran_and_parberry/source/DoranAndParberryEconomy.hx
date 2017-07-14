package;
import bazaarbot.Agent;
import bazaarbot.agent.BasicAgent;
import bazaarbot.agent.Logic;
import bazaarbot.agent.LogicScript;
import bazaarbot.Economy;
import bazaarbot.Market;
import bazaarbot.MarketData;
import haxe.Json;
import jobs.LogicInsurer;
import jobs.LogicConsumer;
import jobs.LogicMegahospital;
import jobs.LogicPrivatehospital;
import jobs.LogicClinic;
import openfl.Assets;

/**
 * ...
 * @author larsiusprime
 */
class DoranAndParberryEconomy extends Economy
{

	public function new()
	{
		super();
		var market = new Market("default");
		market.init(MarketData.fromJSON(Json.parse(Assets.getText("assets/settings.json")), getAgent));
		addMarket(market);
	}

	override function onBankruptcy(m:Market, a:BasicAgent):Void
	{
		// Replace agents with another exactly like them
		var newAgent = getAgent(m.getAgentClass(a.className));
		m.replaceAgent(a, newAgent);
		//replaceAgent(m, a);
	}

	private function replaceAgent(market:Market, agent:BasicAgent):Void
	{
		var bestClass:String = market.getMostProfitableAgentClass();

		//Special case to deal with very high demand-to-supply ratios
		//This will make them favor entering an underserved market over
		//Just picking the most profitable class
		var bestGood:String = market.getHottestGood();

		if (bestGood != "")
		{
			var bestGoodClass:String = getAgentClassThatMakesMost(bestGood);
			if (bestGoodClass != "")
			{
				bestClass = bestGoodClass;
			}
		}

		var newAgent = getAgent(market.getAgentClass(bestClass));
		market.replaceAgent(agent, newAgent);
	}


	/**
	 * Get the average amount of a given good that a given agent class has
	 * @param	className
	 * @param	good
	 * @return
	 */
	/*
	public function getAgentClassAverageInventory(className:String, good:String):Float
	{
		var list = _agents.filter(function(a:BasicAgent):Bool { return a.className == className; } );
		var amount:Float = 0;
		for (agent in list)
		{
			amount += agent.queryInventory(good);
		}
		amount /= list.length;
		return amount;
	}
	*/

	/**
	 * Find the agent class that produces the most of a given good
	 * @param	good
	 * @return
	 */
	public function getAgentClassThatMakesMost(good:String):String
	{
		return if (good == "sickness" ) {"consumer";        }
		  else if (good == "healths"  ) {"clinic";          }
		  else if (good == "healthl"  ) {"megahospital";    }
		  else if (good == "healthm"  ) {"privatehospital"; }
		  else if (good == "insurance") {"insurer";         }
		  else "";
	}

	public function getAgent(data:AgentData):BasicAgent
	{
		data.logic = getLogic(data.logicName);
		return new Agent(0, data);
	}

	public function getLogic(str:String):Logic
	{
		switch(str)
		{
			case "insurer": return new LogicInsurer(null);
			case "consumer": return new LogicConsumer(null);
			case "megahospital": return new LogicMegahospital(null);
			case "privatehospital": return new LogicPrivatehospital(null);
			case "clinic": return new LogicClinic(null);
		}
		return null;
	}
}
