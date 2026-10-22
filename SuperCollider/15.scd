(
s.waitForBoot({
    "Summoning the 24-EDO Persian Setar Matrix...".postln;

    MIDIClient.init;
    MIDIIn.connectAll;

    SynthDef(\rainEngine, {
        arg prox0=0, prox1=0, prox2=0, prox3=0, prox4=0, prox5=0, prox6=0, prox7=0;
        var s0, s1, s2, s3, s4, s5, s6, s7;
        var note0, note1, note2, note3;
        var freq0, freq1, freq2, freq3;
        var trig0, trig1, trig2, trig3;
        var voice0, voice1, voice2, voice3;
        var combinedAcoustics, bowlResonance, simeMoshtagh, leftHandNaleh, spatialStereo;
        var baseC;

        // --- 0. HIGH-ACCURACY INPUT SMOOTHING ---
        s0 = Lag3.kr(Ramp.kr(prox0, 0.05), 0.15);
        s1 = Lag3.kr(Ramp.kr(prox1, 0.05), 0.15);
        s2 = Lag3.kr(Ramp.kr(prox2, 0.05), 0.15);
        s3 = Lag3.kr(Ramp.kr(prox3, 0.05), 0.15);
        s4 = Lag3.kr(Ramp.kr(prox4, 0.05), 0.18);
        s5 = Lag3.kr(Ramp.kr(prox5, 0.05), 0.18);
        s6 = Lag3.kr(Ramp.kr(prox6, 0.05), 0.18);
        s7 = Lag3.kr(Ramp.kr(prox7, 0.05), 0.18);

        // Base Tuning: Low C (130.81 Hz) matching the typical drone range of a Setar
        baseC = 130.81;

        // Left-Hand Expressive Pitch Pull (Naleh) driven by Sensor 6
        leftHandNaleh = SinOsc.kr(LFNoise2.kr(2).range(4, 7)).range(0.99, 1.01) * linlin(s6, 0, 127, 1.0, 1.02);

        // --- 1. DYNAMIC 24-EDO STEP QUANTIZATION (Sensors 0-3) ---
        // Maps proximity values directly to 24 discrete quartertone steps per octave
        note0 = linlin(s0, 0, 127, -12, 12).round;  // Low Bass string / Drone string
        note1 = linlin(s1, 0, 127, 0, 24).round;   // Mid-Range frets
        note2 = linlin(s2, 0, 127, 12, 36).round;  // High-Register frets
        note3 = linlin(s3, 0, 127, 24, 48).round;  // Ultra-High shimmering notes

        // 24-EDO Tuning Equation: Freq = Base * 2^(Step / 24)
        freq0 = baseC * (2 ** (note0 / 24)) * leftHandNaleh;
        freq1 = baseC * (2 ** (note1 / 24)) * leftHandNaleh;
        freq2 = baseC * (2 ** (note2 / 24)) * leftHandNaleh;
        freq3 = baseC * (2 ** (note3 / 24)) * leftHandNaleh;

        // INTERACTIVE STRUMMING TRIGGER MECHANISM:
        // Automatically plucks when moving notes, or creates a steady finger strum (Riz)
        // that gains speed and expression the closer your hand gets to the instrument sensor.
        trig0 = T2A.ar(Changed.kr(note0)) + Dust.ar(linlin(s0, 15, 127, 0, 18));
        trig1 = T2A.ar(Changed.kr(note1)) + Dust.ar(linlin(s1, 15, 127, 0, 22));
        trig2 = T2A.ar(Changed.kr(note2)) + Dust.ar(linlin(s2, 15, 127, 0, 26));
        trig3 = T2A.ar(Changed.kr(note3)) + Dust.ar(linlin(s3, 15, 127, 0, 30));

        // --- 2. ADVANCED SETAR PHYSICAL MODEL STAGE ---
        // Uses Karplus-Strong string modeling with a distortion coefficient to emulate silk-fret buzz.

        // String 0: Low Drone / Bass Course (Bam)
        voice0 = Pluck.ar(
            PinkNoise.ar(0.3) + (Impulse.ar(freq0) * 0.1),
            trig0,
            0.1, freq0.reciprocal, 2.5, 0.4
        ) * 14.0 ! 2;

        // String 1: Yellow Harmonic String Course (Sim-e Zard)
        voice1 = Pluck.ar(
            PinkNoise.ar(0.4).distort, // Distort adds that classic string-to-fret buzz
            trig1,
            0.05, freq1.reciprocal, 2.0, 0.35
        ) * 16.0 ! 2;

        // String 2: Principal White String Course (Sim-e Sefid)
        voice2 = Pluck.ar(
            WhiteNoise.ar(0.4) * LFNoise1.ar(1000).range(0.8, 1.2),
            trig2,
            0.03, freq2.reciprocal, 1.8, 0.3
        ) * 22.0 ! 2;

        // String 3: High Melodic Telepathy Tine
        voice3 = Pluck.ar(
            PinkNoise.ar(0.5),
            trig3,
            0.02, freq3.reciprocal, 1.2, 0.25
        ) * 26.0 ! 2;

        // Combine string engines
        combinedAcoustics = voice0 + voice1 + voice2 + voice3;

        // --- 3. MULBERRY WOOD RESONANCE & DRONE SPACE (Sensors 4-7) ---

        // Sensor 4: Mulberry Bowl Reflection (Simulates the acoustic hollow wood body)
        bowlResonance = Resonz.ar(combinedAcoustics, linlin(s4, 0, 127, 220, 3200), 0.12) * 0.7;
        combinedAcoustics = combinedAcoustics + (bowlResonance * linlin(s4, 0, 127, 0.0, 1.0));

        // Sensor 5: Sim-e Moshtagh Sympathetic Shadow Ring (Generates the ethereal background drone ring)
        simeMoshtagh = combinedAcoustics;
        3.do({ |i|
            simeMoshtagh = AllpassL.ar(
                simeMoshtagh,
                0.04,
                [baseC.reciprocal, (baseC * 1.5).reciprocal] * (1 + (i * 0.002)),
                linlin(s5, 0, 127, 0.2, 4.0)
            );
        });
        combinedAcoustics = combinedAcoustics + (simeMoshtagh * linlin(s5, 0, 127, 0.0, 0.75));

        // Sensor 7: Atmospheric Stereo Panner (Simulates the natural room perspective of the instrument)
        spatialStereo = SinOsc.kr(linlin(s7, 0, 127, 0.05, 0.6)).range(-0.85, 0.85);

        // Global finish layout
        combinedAcoustics = DelayC.ar(combinedAcoustics, 0.2, LFNoise1.kr(0.05).range(0.01, 0.03)) + (combinedAcoustics * 0.6);

        // Limiter output keeping everything extremely dense, heavy, and balanced perfectly
        Out.ar(0, Limiter.ar(Balance2.ar(combinedAcoustics[0], combinedAcoustics[1], spatialStereo, 2.8), 0.98));
    }).add;

    s.sync;

    ~cloudNode = Synth(\rainEngine);

    MIDIdef.freeAll;

    MIDIdef.cc(\atmosphereIn, { |val, num, chan, src|
        var paramSymbol, gatedValue;

        gatedValue = if(val <= 6, { 0 }, { val });
        paramSymbol = ("prox" ++ (num - 20)).asSymbol;
        ~cloudNode.set(paramSymbol, gatedValue);
    }, ccNum: (20..27));

    "The 24-EDO Persian Setar Engine is active. Wave your hands over 0-3 to evoke the Riz string plucks!".postln;
});
)