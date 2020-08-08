Engine_Test : CroneEngine {

	var group,sample,map,d2k,mode;

	*new { |context, doneCallback| ^super.new(context, doneCallback) }

	alloc {
		group  = ParGroup.tail(context.xg);
		sample = Sample.celesta(context.server);
		map    = sample.map;
		mode = [0,2,4,5,7,9,11];
		d2k = { |degree, mode|
			var size = mode.size;
			var deg = degree.round;
			12 * deg.div(size) + mode[deg%size];
		};
		SynthDef(\line, { |buf,rate=1,pos=0,amp=1,dur=1,pan=0|
			var sig, env;
			sig = PlayBuf.ar(1, buf, rate*BufRateScale.ir(buf), 1, pos*BufFrames.ir(buf));
			env = Env.linen(0.005,0,dur).kr(2);
			sig = sig * env * amp;
			sig = LinPan2.ar(sig, pan);
			Out.ar(0, sig);
		}).add;
		this.addCommand(\ping, "f", { |m|
			var key;
			([0,12,24]+55).do { |base,i|
				key = d2k.(7.rand, mode);
				Synth.grain(\line, [
					buf:  map[base+key][0],
					rate: map[base+key][1],
					pos:  rrand(0.01,0.07),
					amp:  dbamp(rrand(-9,-2)),
					dur:  3,
					pan:  1.0.rand2,
				], group);
			};
		});
	}
	free { sample.free }
}