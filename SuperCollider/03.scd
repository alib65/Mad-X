(
s.waitForBoot({
    "Summoning the Generative Rain Cloud Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    // The Fixed Cloud Engine
    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var triggerRate, materialResonance, cloudLft, cloudRgt, droplets, spatialWind, targetFreq;

        // Sensors 0 & 1 control the absolute density of the rain drops
        triggerRate = Lag.kr(2 + (prox0 * 0.8) + (prox1 * 1.5), 0.2);
        droplets = Dust.ar(triggerRate ! 2); // Generates random micro-impulses

        // Sensors 2, 3, & 4 morph the structural material being hit
        // FIXED: Calculated at control rate, then handled properly as audio rate input
        targetFreq = Lag.kr(120 + (prox2 * 15) + (prox3 * 45) + (prox4 * 100), 0.05);

        materialResonance = Resonz.ar(
            droplets,
            freq: targetFreq.asAudioRateInput, // Safely cast to audio rate
            bwr: Lag.kr(linlin(prox5, 0, 127, 0.05, 0.001), 0.1) // Tightens string "ring" time
        ) * 450;

        // Sensors 5, 6, & 7 act as a dynamic stereo wind simulator
        spatialWind = SinOsc.kr(1 + (prox6 * 0.1)).range(
            linlin(prox5, 0, 127, -0.8, -0.2),
            linlin(prox7, 0, 127, 0.2, 0.8)
        );

        // Run the droplets through an acoustic space processing layer
        materialResonance = DelayC.ar(materialResonance, 0.2, LFNoise1.kr(0.5).range(0.01, 0.1));

        // Final stereo mix with safety output ceiling
        Out.ar(0, Limiter.ar(Balance2.ar(materialResonance[0], materialResonance[1], spatialWind, 0.8), 0.9));
    }).add;

    s.sync;

    // Instantly evoke the running rain cloud
    ~cloudNode = Synth(\rainEngine);

    MIDIdef.freeAll;

    // Route the incoming physical matrix values straight into the cloud's parameters
    MIDIdef.cc(\atmosphereIn, { |val, num, chan, src|
        var paramSymbol;
        paramSymbol = ("prox" ++ (num - 20)).asSymbol;
        ~cloudNode.set(paramSymbol, val);
    }, ccNum: (20..27));

    "Cloud Matrix active. Hover your hands to shift the storm density.".postln;
});
)