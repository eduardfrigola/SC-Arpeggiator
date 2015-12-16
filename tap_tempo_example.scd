////////////
// Tap Tempo - Josh

(
w = Window.new("Tempo", Rect(100, 600, 400, 400)).front;
n = nil;

u = {
        n.isNil.if({n = Main.elapsedTime}, {
                t = Main.elapsedTime;
                r = 60 / (t - n);
                n = t;
                a.string_("Tempo is : "++r.round(0.01)++" BPM")
                })

        };
b = Button.new(w, Rect(10, 10, 380, 180))
        .states_([
                ["Press me, or the space bar", Color.black, Color.grey]
                ])
        .action_({u.value})
        ;

a = StaticText.new(w, Rect(10, 200, 380, 180))
        .string_("No tempo")
        .font_(Font("Monaco", 20));

w.view.keyDownAction_({arg view, char;
        (char == $ ).if({u.value})
        })
)


//////////////
//	TAP TEMPO - by Fredrik
//
//	takes the average of the last n taps.
//	changeTempoClock.default to your own clock.

(
var n= 4;	//number of taps to collect
var timeout= 3;	//timeout until restart in seconds
var times= 0.dup(n), counter, lastTime= 0;
var win= Window.new("redTap", Rect(100, 200, 180, 80), false);
var but= Button.new(win, win.view.bounds).states_([["bpm= 120.00", Color.black, Color.clear]])
        .action_{
                var newTempo, nowTime= SystemClock.seconds;
                if(nowTime-timeout>lastTime, {
                        "timedout".postln;
                        counter= 0;
                });
                if(counter<(n-1), {
                        times= times.put(counter, SystemClock.seconds);
                        counter= counter+1;
                }, {
                        times= times.put(counter, SystemClock.seconds);
                        newTempo= 60 / (times.differentiate.drop(1).mean);
                        ("setting new tempo"+newTempo).postln;
                        TempoClock.default.tempo= newTempo/60;
                        but.states= [["bpm="+(newTempo).round(0.01), Color.black, Color.clear]];
                        times= times.rotate(-1);
                });
                lastTime= nowTime;
        };
win.view.background= Color.red;
win.front;
CmdPeriod.doOnce({if(win.isClosed.not, {win.close})});

TempoClock.default.tempo= 2;
Pbind(\legato, 0.2).play;
) 