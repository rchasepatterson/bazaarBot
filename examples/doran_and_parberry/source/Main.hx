package;

import bazaarbot.Economy;
import bazaarbot.Market;
import bazaarbot.utils.Quick;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.display.SimpleButton;
import flash.display.Sprite;
import openfl.Assets;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;
import sys.io.File;
import sys.io.FileSystem;
import sys.io.FileOutput;


class Main extends Sprite
{
	private var economy:DoranAndParberryEconomy;
	private var market:Market;

	private var display:MarketDisplay;
	private var txt_benchmark:TextField;
	private var txt_rounds:TextField;
	private var txt_agent:TextField;
	private var txt_csv:TextField;
	private var txt_csv_save:TextField;

	private var agentType:String = "consumer";

	public function new()
	{
		super();

		// Economy setup
		setupEconomy();

		// Display related setup
		makeButtons();

		// Show the display
		updateDisplay();
	}

	private function makeButtons():Void
	{
		makeButton(10, 10, "Advance", onAdvance);
		makeButton(120, 10, "Benchmark", onBenchmark);

		makeButton(10, 50, "Reset", onReset);

		// agent select
		makeButton(120, 50, "<<", prevAgent, 50, 30);
		makeButton(120 + 10 + 50, 50, ">>", nextAgent, 50, 30);

		// agent quantity adjust
		makeButton(800 - 10 - 50    , 50, "+100", onPlusHundred, 50, 30);
		makeButton(800 - 10*2 - 50*2, 50, "+10", onPlusTen, 50, 30);
		makeButton(800 - 10*3 - 50*3, 50, "+1", onPlusOne, 50, 30);
		makeButton(800 - 10*4 - 50*4, 50, "0", onMurder, 50, 30);
		makeButton(800 - 10*5 - 50*5, 50, "-1", onMinusOne, 50, 30);
		makeButton(800 - 10*6 - 50*6, 50, "-10", onMinusTen, 50, 30);
		makeButton(800 - 10*7 - 50*7, 50, "-100", onMinusHundred, 50, 30);

		display = new MarketDisplay(799, 600 - 51);
		display.x = 0;
		display.y = 100;
		addChild(display);

		txt_benchmark = new TextField();
		txt_benchmark.x = 230;
		txt_benchmark.y = 10;
		txt_benchmark.width = 800 - 230;
		txt_benchmark.height = 20;
		addChild(txt_benchmark);

		txt_rounds = new TextField();
		txt_rounds.x = 800 - 70;
		txt_rounds.y = 2;
		txt_rounds.width = 70;
		txt_rounds.height = 20;
		addChild(txt_rounds);

		txt_agent = new TextField();
		txt_agent.x = 120 + 10*2 + 50*2;
		txt_agent.y = 55;
		txt_agent.width = 90;
		txt_agent.height = 20;
		addChild(txt_agent);

		txt_csv = new TextField();
		txt_csv.x = 0;
		txt_csv.y = 300;
		txt_csv.width = 800;
		txt_csv.height = 500;
		addChild(txt_csv);
		setupCsv();

		makeButton(10, 300 - 40, "Save .csv", onSaveCsv);

		txt_csv_save = new TextField();
		txt_csv_save.x = 120;
		txt_csv_save.y = 300 - 40 + 5;
		txt_csv_save.width = 500;
		txt_csv_save.height = 20;
		addChild(txt_csv_save);
	}

	private function onBenchmark(m:MouseEvent):Void
	{
		var time = Lib.getTimer();
		var benchmark:Int = 10;
		var roundNum = market.roundNum();
		txt_csv.text += market.simulate(benchmark);
		updateDisplay();
		time = Lib.getTimer() - time;
		var avg:Float = (cast(time, Float) / cast(benchmark, Float)) / 1000;
		var tstr:String = Quick.numStr(time / 1000, 2);
		var platform:String="NONE";
		#if flash
			platform = "flash";
		#elseif cpp
			platform = "cpp";
		#elseif neko
			platform = "neko";
		#elseif js
			platform = "js";
		#end
		
		txt_benchmark.text = ("Platform=" + platform + " Round #=" + roundNum + " Rounds=" + benchmark + ", Commodities=" + market.numTypesOfGood() + ", Agents=" + market.numAgents() + ", TIME total=" + tstr + " avg=" + Quick.numStr(avg,2));
		updateRoundNum();
	}

	private function onAdvance(m:MouseEvent):Void
	{
		txt_csv.text += market.simulate(1);
		updateDisplay();
	}

	private function onReset(m:MouseEvent):Void
	{
		setupEconomy();
		setupCsv();
		updateDisplay();
	}

	private function onPlusHundred(m:MouseEvent):Void
	{
		for(i in 0 ... 100)
		{
			onPlusOne(m);
		}
	}

	private function onPlusTen(m:MouseEvent):Void
	{
		for(i in 0 ... 10)
		{
			onPlusOne(m);
		}
	}

	private function onPlusOne(m:MouseEvent):Void
	{
		var newAgent = economy.getAgent(market.getAgentClass(agentType));
		market.addAgent(newAgent);
		updateDisplay();
	}

	private function onMurder(m:MouseEvent):Void
	{
		market.removeAgent(agentType, 25565);
		updateDisplay();
	}

	private function onMinusOne(m:MouseEvent):Void
	{
		market.removeAgent(agentType);
		updateDisplay();
	}

	private function onMinusTen(m:MouseEvent):Void
	{
		market.removeAgent(agentType, 10);
		updateDisplay();
	}

	private function onMinusHundred(m:MouseEvent):Void
	{
		market.removeAgent(agentType, 100);
		updateDisplay();
	}

	private function onSaveCsv(m:MouseEvent):Void
	{
		#if cpp
			var fileName:String = "econ_output.csv";
			var fout = File.write(fileName, false);
			fout.writeString(txt_csv.text);
			fout.close();

			txt_csv_save.text = "File saved to " + FileSystem.absolutePath(fileName);
		#else
			txt_csv_save.text = "Saving to .csv not supported on this platform, use ctrl+a ctrl+c below";
		#end
	}

	private function nextAgent(m:MouseEvent):Void
	{
		var agentTypes = market.getAgentClassNames();

		agentType = agentTypes[((agentTypes.indexOf(agentType) + 1) % agentTypes.length)];
		updateDisplay();
	}

	private function prevAgent(m:MouseEvent):Void
	{
		var agentTypes = market.getAgentClassNames();

		agentType = agentTypes[((agentTypes.indexOf(agentType) + agentTypes.length + 1) % agentTypes.length)];
		updateDisplay();
	}

	private function setupEconomy():Void
	{
		economy = new DoranAndParberryEconomy();
		market = economy.getMarket("default");
	}

	private function setupCsv():Void
	{
		txt_csv.text = "Round#";

		// Goods
		var goodTypes = market.getGoods();

		for(type in goodTypes)
		{
			if(type != "sickness")
			{
				txt_csv.text += "," + type;
			}
		}

		// Agents
		var agentTypes = market.getAgentClassNames();

		for(type in agentTypes)
		{
			if(type != "consumer")
			{
				txt_csv.text += "," + type;
			}
		}

		txt_csv.text += "\n";
	}

	private function updateDisplay():Void
	{
		display.update(market.get_marketReport(1));
		txt_agent.text = agentType;
		updateRoundNum();
	}

	private function updateRoundNum():Void
	{
		var roundNum = market.roundNum();
		txt_rounds.text = "Round#=" + roundNum;
	}

	private function makeButton(X:Float, Y:Float, str:String, func:Dynamic, W:Float = 100, H:Float = 30):SimpleButton
	{
		var up:Sprite = new Sprite();
		var over:Sprite = new Sprite();
		var down:Sprite = new Sprite();
		var hit:Sprite = new Sprite();
		up.graphics.beginFill(0xaaaaaa);
		up.graphics.drawRoundRect(0, 0, W, H, 5, 5);
		up.graphics.endFill();

		over.graphics.beginFill(0xdddddd);
		over.graphics.drawRoundRect(0, 0, W, H, 5, 5);
		over.graphics.endFill();

		down.graphics.beginFill(0x777777);
		down.graphics.drawRoundRect(0, 0, W, H, 5, 5);
		down.graphics.endFill();

		hit.graphics.beginFill(0x000000);
		hit.graphics.drawRoundRect(0, 0, W, H, 5, 5);
		hit.graphics.endFill();

		var text1:TextField = new TextField();
		var text2:TextField = new TextField();
		var text3:TextField = new TextField();

		up.addChild(text1);
		over.addChild(text2);
		down.addChild(text3);

		text1.autoSize = TextFieldAutoSize.LEFT;
		text1.text = text2.text = text3.text = str;
		text1.x = text2.x = text3.x = (up.width - text1.textWidth)/2;
		text1.y = text2.y = text3.y = (up.height - text1.height) / 2;

		var s:SimpleButton = new SimpleButton(up, over, down, hit);
		s.addEventListener(MouseEvent.CLICK, func, false, 0, true);

		s.x = X;
		s.y = Y;

		addChild(s);
		return s;
	}
}
