(
s.waitForBoot({
    "Configuring unified MIDI laser harp client...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    // A physical waveguide model that changes timbre via filter properties
    SynthDef(\harpString, {
        arg freq = 440, amp = 0.3, pan = 0, openFilter = 1000;
        var env, noise, delay, signal;

        noise = PinkNoise.ar(amp) * EnvGen.kr(Env.perc(0.001, 0.01));
        delay = CombC.ar(noise, 1/20, 1/freq, 3.5);

        // This filter will open up brilliantly when your hand moves closer to the sensor!
        signal = LPF.ar(delay, openFilter.clip(150, 14000));

        env = EnvGen.kr(Env.asr(0.001, 1, 2.0), gate: 1, doneAction: 2);
        Out.ar(0, Pan2.ar(signal * env, pan));
    }).add;

    s.sync;

    ~activeSynths = Array.newClear(128);
    MIDIdef.freeAll;

    // 1. CATCH THE PLUCK (Note On)
    MIDIdef.noteOn(\harpPluck, { |vel, num, chan, src|
        var frequency = num.midicps;
        var panPosition = ((num.clip(60, 67) - 60) / 7) * 2 - 1;

        if(~activeSynths[num].notNil) { ~activeSynths[num].release };

        ~activeSynths[num] = Synth(\harpString, [
            \freq, frequency,
            \amp, vel.linlin(60, 127, 0.1, 0.6),
            \pan, panPosition,
            \openFilter, 1000 // Starts warm
        ]);
        ["Plucked String:", num].postln;
    });

    // 2. CATCH THE CONTINUOUS DISTANCE MODULATION (CC 20 to 27)
    MIDIdef.cc(\harpProximity, { |val, num, chan, src|
        var targetNote, dynamicFilter; // FIXED: Lowercase declarations at the top

        targetNote = num + 40; // Maps CC 20-27 perfectly back to Note 60-67 array slots
        dynamicFilter = val.linlin(0, 127, 400, 12000); // Higher val = brighter timbre

        if(~activeSynths[targetNote].notNil) {
            ~activeSynths[targetNote].set(\openFilter, dynamicFilter);
        };
    });

    // 3. CATCH THE HAND LEAVING THE STRING (Note Off)
    MIDIdef.noteOff(\harpRelease, { |vel, num, chan, src|
        if(~activeSynths[num].notNil) {
            ~activeSynths[num].release;
            ~activeSynths[num] = nil;
        };
    });

    "System Ready! Wave hands over your sensors to perform.".postln;
});
)