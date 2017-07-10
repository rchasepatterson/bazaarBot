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


class Main extends Sprite
{
	private var economy:Economy;
	private var market:Market;

	private var display:MarketDisplay;
	private var txt_benchmark:TextField;
	private var txt_rounds:TextField;

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
		makeButton(10, 50, "Reset", onReset);
		makeButton(120, 10, "Benchmark", onBenchmark);

		display = new MarketDisplay(799, 600 - 51);
		display.x = 0;
		display.y = 100;
		addChild(display);

		txt_benchmark = new TextField();
		txt_benchmark.x = 230;
		txt_benchmark.y = 10;
		txt_benchmark.width = 800 - 230;
		addChild(txt_benchmark);

		txt_rounds = new TextField();
		txt_rounds.x = 800 - 70;
		txt_rounds.y = 2;
		txt_rounds.width = 70;
		addChild(txt_rounds);
	}

	private function onBenchmark(m:MouseEvent):Void
	{
		var time = Lib.getTimer();
		var benchmark:Int = 10;
		var roundNum = market.roundNum();
		market.simulate(benchmark);
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
		market.simulate(1);
		updateDisplay();
	}

	private function onReset(m:MouseEvent):Void
	{
		setupEconomy();
		updateDisplay();
	}

	private function setupEconomy():Void
	{
		economy = new DoranAndParberryEconomy();
		market = economy.getMarket("default");
	}

	private function updateDisplay():Void
	{
		display.update(market.get_marketReport(1));
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
