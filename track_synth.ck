//SinOsc inst => Gain gain => Echo echo => NRev rev => dac;
SinOsc inst => Gain gain => Echo echo => NRev rev => dac;
SinOsc lfo => blackhole;
.4::second => echo.max;
.4::second => echo.delay;
.0 => echo.mix;
.1 => gain.gain;
5 => lfo.freq;
.1 => rev.mix;

false => int quit;

/// cool idea for upper half of y-axis, have it arpeggiates the note being played in lower half

spork ~ initialize_socket();
spork ~ listen_keyboard();


[0,2,4,5,7,9,11,12] @=> int major[];
[0,2,3,5,7,8,10,12] @=> int minor[];

["C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb","B"] @=> string keys[];

// parameters
float x_coor;
float y_coor;
false => int note_on;

float freq;
10.0 => float low_freq;
3000.0 => float hi_freq;
hi_freq - low_freq => float range;

true => int continuous;
"continuous" => string voicing;

48 => int root; //default key of C
major @=> int mode[];
4 => int total_octaves;

// MAIN LOOOP ///////////////////////////////
while (true) 
{
  if (quit) {break;}
	calc_vibrato();
	//modal_freq(root, total_octaves, mode) + lfo.last() => inst.freq;
	range_freq() + lfo.last() => inst.freq;
	200::samp => now;
}
////////////////////////////////////////////


// FREQ CALCULATORS ////////////////////////
fun float range_freq()
{
	return (range * (x_coor/100.0)) + low_freq;
}

fun float modal_freq(int root, int num_octaves, int mode[])
{
	num_octaves * 7 + 1 => int num_x_regions;
	find_region(num_x_regions, "x") => int x_region;
	find_region(2, "y") => int y_region;
	return Std.mtof(root + find_MIDI(x_region, mode));
}


fun int find_MIDI(int x, int mode[])
{
	x%7 => int scale_degree;
	(x - scale_degree)/7 => int octave;
	return octave*12 + mode[scale_degree];
}
////////////////////////////////////////////


// LFO CALCULATORS /////////////////////////

fun float calc_vibrato()
{
	//y_coor/2 => lfo.gain;
	y_coor/2 => lfo.gain;
}

fun int find_region(int num_regions, string axis)
{
	100.0/num_regions => float region_size;
	float coor;
	if (axis == "x") {x_coor => coor;}
	else {y_coor => coor;}
	coor%region_size => float delta; 
	coor - delta => float snap;
	(snap/region_size) $ int => int region;
	return region;
}

fun void change_root(int amount) {
	root + amount => root;
}

fun string calc_key(int root) {
	root % 12 => int key;
	return keys[key];
}

fun void initialize_socket()
{
	OscRecv recv;
	6449 => recv.port;
	recv.listen();
	recv.event("/foo/notes, f f") @=> OscEvent @ oe;
	while (true)
	{
		oe => now;
		while (oe.nextMsg())
		{
			oe.getFloat() => x_coor;
			oe.getFloat() => y_coor;
			//<<<x_coor, y_coor>>>;
		}
	}
}

fun void listen_keyboard()
{
	KBHit kb;
	while( true )
	{
	    kb => now;
	    while( kb.more() )
	    {
	        kb.getchar() => int typed;
			if(typed == 27) {
	        	kb.getchar() => int typed2;
	        	if (typed2 == 0) {
	        		true => quit;
	        	} else if (typed2 == 91)
	        	{
	        		kb.getchar() => int typed3;
	        		// 65up 66down 67right 68left
	        		if (typed3 == 65) {change_root(12);}
	        		if (typed3 == 66) {change_root(-12);}
	        		if (typed3 == 67) {change_root(1);}
	        		if (typed3 == 68) {change_root(-1);}
	        		<<<calc_key(root)>>>;
	        	}
	        }
	    }
	}
}
