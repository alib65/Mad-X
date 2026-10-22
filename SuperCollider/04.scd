(
s.waitForBoot({
    "Summoning the Silent-Idle Rain Cloud Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var triggerRate, materialResonance, droplets, spatialWind, targetFreq, masterGating;

        // FIXED: Pure math-based gating. If the sum is greater than 0, this evaluates directly to 1, otherwise 0.
        masterGating = Lag.kr((prox0 + prox1 + prox2 + prox3) > 0, 0.1);

        // Sensors 0 & 1 control the density of rain drops
        triggerRate = Lag.kr(linlin(prox0, 0, 127, 0, 45) + linlin(prox1, 0, 127, 0, 65), 0.2);

        // Multiply by masterGating so the stream wakes up instantly when data climbs past the gate
        droplets = Dust.ar(triggerRate ! 2) * masterGating;

        // Material resonance tracking
        targetFreq = Lag.kr(120 + (prox2 * 15) + (prox3 * 45) + (prox4 * 100), 0.05);

        materialResonance = Resonz.ar(
            droplets,
            freq: targetFreq.asAudioRateInput,
            bwr: Lag.kr(linlin(prox5, 0, 127, 0.05, 0.001), 0.1)
        ) * 450;

        // Stereo wind simulator
        spatialWind = SinOsc.kr(1 + (prox6 * 0.1)).range(
            linlin(prox5, 0, 127, -0.8, -0.2),
            linlin(prox7, 0, 127, 0.2, 0.8)
        );

        materialResonance = DelayC.ar(materialResonance, 0.2, LFNoise1.kr(0.5).range(0.01, 0.1));

        Out.ar(0, Limiter.ar(Balance2.ar(materialResonance[0], materialResonance[1], spatialWind, 0.8), 0.9));
    }).add;

    s.sync;

    ~cloudNode = Synth(\rainEngine);

    MIDIdef.freeAll;

    MIDIdef.cc(\atmosphereIn, { |val, num, chan, src|
        var paramSymbol, gatedValue;

        // HARDWARE NOISE GATE: Filters out the low-level idling noise floor from the infrared sensors
        gatedValue = if(val <= 10, { 0 }, { val });

        paramSymbol = ("prox" ++ (num - 20)).asSymbol;
        ~cloudNode.set(paramSymbol, gatedValue);
    }, ccNum: (20..27));

    "Cloud Matrix active. It will remain dead silent until you deliberately place your hands over the sensors!".postln;
});
)