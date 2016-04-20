//Boot server or reboot
s.reboot


//initialize midi and conect to all incoming sources
(
MIDIClient.init;
MIDIIn.connectAll;
// create a MIDI out connection:
m = MIDIOut(0, MIDIClient.destinations.at(0).uid);
// and connect SC's first port to your device's port with for example QJackCtl, or use:
m.connect(1);
)


(
~synthsarray= Array.newClear(128);
~activeNotes = Array.new(128);
// ~activeNotes = ~activeNotes.insert(0,60);
// ~activeNotes = ~activeNotes.insert(1,62);


MIDIdef.noteOn(\test2, {
	arg vel, note;
	// note.postln;
	var sig;
	~synthsarray[note]=sig;
	~activeNotes = ~activeNotes.add(note);
	// note.postln;
	~activeNotes.postln;
});

MIDIdef.noteOff(\test3, {
	arg velo, note;
	//notet.postln;
	~synthsarray[note].set(\gate, 0.0);
	~activeNotes.do({
		arg item, i;
		if(item == note){
			~activeNotes.removeAt(i);
		}
	});
	~activeNotes.postln;
});


MIDIdef.cc(\testcc, {
	arg val;
	val.postln;
	//~synthsarray.do(
	//	~synthsarray[item].set(\pulsewidth, val/127);
	//);
}, 1);
)

// using a pattern to send a MIDI event:
(
p = Pbind(
    \type, \midi,
        // this line is optional b/c noteOn is the default
        // just making it explicit here
    \midicmd, \noteOn,
    \midiout, m,    // must provide the MIDI target here
    \chan, 0,
        // degree is converted to midinote, not just frequency
	 \midinote, Pseq(~activeNotes, inf),
    //\dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
	\dur, 1/~activeNotes.size(),
    //\legato, sin(Ptime(inf) * 0.5).linexp(-1, 1, 1/3, 3),
    \amp, Pexprand(0.5, 1.0, inf)
);
)
~player = p.play;

~activeNotes.postln;
~player.stop;

~activeNotes = ~activeNotes.insert(2,65);

// free any hung notes if necessary:
m.allNotesOff(16);