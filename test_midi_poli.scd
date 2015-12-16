s.reboot
MIDIClient.init
MIDIIn.connectAll;


(
~reverbBus=Bus.audio(s, 1);
~delayBus=Bus.audio(s,1);
~fxGroup=Group.new;
~synGroup=Group.new;
)

s.plotTree




(
SynthDef(\test, {
	arg freq=440, amp=0.7, gate=1, width=0.5;
	var sig;
	sig = LFTri.ar(freq);
	sig = sig*0.3 + SinOsc.ar(freq)*0.7;
	sig = sig * amp;
	sig = Pan2.ar(sig, SinOsc.kr(1));
	sig = sig*EnvGen.kr(Env.adsr,
		gate,Latch.kr(gate,gate),doneAction:2);
	Out.ar(~delayBus, sig);
}).add;
)


(
SynthDef(\reverb, {
	arg in=~reverbBus, out=0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb.ar(sig, 0.7, 0.5, 0.7)!2;
	Out.ar(out, sig);
}).add
)

(
SynthDef(\delay, {
	arg in=~delayBus, out=~reverbBus;
	var sig, sig_del;
	sig = In.ar(in, 2);
	sig_del = CombL.ar(sig, 0.4, 0.4, 5);
	sig = sig+sig_del*0.6;
	Out.ar(out, sig);
}).add
)
Synth.new(\reverb, [\in, ~reverbBus], target:~fxGroup);
Synth.new(\delay, [\in, ~delayBus, \out, 0], target:~fxGroup, addAction:'addToHead');
~fxGroup.freeAll

(
~synthsarray= Array.newClear(128);



MIDIdef.noteOn(\test2, {
	arg vel, note;
	//note.postln;
	var sig;
	sig=Synth.new(\test, [\freq, note.midicps, \amp , vel/200], target:~synGroup);
	~synthsarray[note]=sig;
});

MIDIdef.noteOff(\test3, {
	arg velo, notet;
	//notet.postln;
	~synthsarray[notet].set(\gate, 0.0);
});


MIDIdef.cc(\testcc, {
	arg val;
	val.postln;
	//~synthsarray.do(
	//	~synthsarray[item].set(\pulsewidth, val/127);
	//);
}, 1);
)


