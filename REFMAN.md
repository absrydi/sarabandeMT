# Sarabande Musical Markup Language Reference Manual v0.0.1 for Minetest

[Standalone Version](https://beauprograming.blogspot.com/2024/09/pemutar-musik-sarabande.html)

## Main Commands

Commands that will be interpreted by the program.

### ```time (n)```

Set the time signature's numerator. The time signature's denominator is always 4.

- n: Time signature's numerator (default: 4).

### ```tempo (n)```

Set the music tempo in BPM / MM.

- n: Tempo in BPM / MM (default: 120).

### ```tuning (n)tet```

Set the music tuning with the Equal Temprament system.

- n: Number of notes in 1 octave from 2 - 26 (default: 12).

### ```setvar (name) (value)```

Declare a variable with a value (in number). Can be used if a value is used extensively.

- name: Variable name / callsign.
- value: Variable value in number. can be decimal or round.

### ```remvar (name)```

Remove the called variable.

- name: Variable name / callsign to be removed.

### ```next (beat)```

Go to the next beat.

- beat: How much beat to be skipped.

### ```note (pitch) (duration) (voice)```

Play a note. ^(See "Extra: Note")^

- pitch: Note pitch.
- duration: Note duration in Beat(s).
- voice: Note voice / sound index.

### ```dynamics (volume)```

Set the playing dynamics (volume) ^(See "Preprocessing Commands § Dynamics")^

- volume: How loud the next notes should be played (default: 100 [0 - 100]).

### ```transpose (semitones)```

Set the pitch transposition

- semitones: How much transposition (in semitones) the next notes should be played (default: 0 [-47 - 48]).

### ```finetune (cents)```

Set the fine tuning in cents

- cents: Trim/Fine tune (in cents) the next notes (default: 0 [-1200 - 1200]).

### ```end```

Ends the music with one bar (required in every music file as an EOF identifier).

### ```## (comment)```

Comments. Can be used to write some comments. Does not interpreted and pre-processed by the program.

- comment: Comments.

## Preprocessing Commands

Commands that will be pre-processed before interpreted by the program. To get the idea what is preprocessing, here is an example:

Before preprocessing:

	dynamics piano

After preprocessing:

	dynamics 40

The "Before preprocessing" example is what you write in the music file. Then it will be preprocessed by the Preprocessing Unit. Preprocessed music file then will be interpreted by the main interpreter.

### ```getvar (name)``` or ```gv (name)```

Return the called variable's value.

- name: Variable name / callsign to be returned its value.

### Dynamics

| Preprocessing Commands | Volume |
|------------------------|--------|
| "pianissimo" or "pp"	 | 25     |
| "piano"	or "p"		 | 40     |
| "mezzopiano" or "mp"	 | 50     |
| "mezzoforte" or "mf"	 | 60     |
| "forte" or "f"		 | 75     |
| "fortissimo" or "ff"	 | 100    |

Dynamics preprocessed commands can be used with the main "dynamics" command for changing dynamics.

### Arithmetic Operators ```*```, ```/```, ```+``` and ```-```

Arithmetic operators with the Order of Operation rule. Space is required between number and operators.

## Errors

| Index | Message                           | Description                                      |
|-------|-----------------------------------|--------------------------------------------------|
| 0     | ```Unknown error```               | Unknown reason.                                  |
| 1     | ```Unknown time signature```      |                                                  |
| 2     | ```Unknown tempo```               |                                                  |
| 3     | ```Unknown tuning system```       |                                                  |
| 4     | ```Incorrect beat amount```       | ```next``` command.                              |
| 5     | ```Incorrect note command```      |                                                  |
| 6     | ```Unknown command```             | unregistered command.                            |
| 7     | ```Unknown note name```           | ```note``` command (pitch argument).             |
| 8     | ```Unknown voice index```         | ```note``` command (voice argument).             |
| 9     | ```Incorrect setvar command```    |                                                  |
| 10    | ```Variable already declared```   | ```setvar``` command (name argument).            |
| 11    | ```Incorrect remvar command```    |                                                  |
| 12    | ```Unknown variable```            | ```getvar``` (```gv```) or ```remvar``` command. |
| 13    | ```Incorrect dynamics command```  |                                                  |
| 14    | ```Incorrect transpose command``` |                                                  |
| 15    | ```Incorrect finetune command```  |                                                  |
| 16-18 | _See "voice.txt Errors"_          |                                                  |
| 19    | ```Voice index does not exist```  | ```note``` command (voice index exceed limit).   |

### voice.txt Errors (for Standalone version)

| Index | Message                           | Description                                           |
|-------|-----------------------------------|-------------------------------------------------------|
| 16    | ```Unknown setvoice attribute```  |                                                       |
| 17    | ```Invalid index```               | voice.txt: index given doesn't exist or not a number. |
| 18    | ```Unknown command```             | unregistered command.                                 |

### Other Errors (for Standalone version)


| Message                                                                        | Description                |
|--------------------------------------------------------------------------------|----------------------------|
| ```Failed to open sound file "voice\[soundname].wav" (couldn't open stream)``` | Audio (voice) file missing |

## Warnings (mostly for Standalone version)

| Index | Message                                                 | Description                  |
|-------|---------------------------------------------------------|------------------------------|
| 0     | ```Unknown warning```                                   | Unknown reason.              |
| 1     | _Empty_                                                 |                              |
| 2     | ```File does not exist or empty```                      |                              |
| 3     | ```File name is null. Usage: "sarabande [file].srbd"``` | File name argument is empty. |
| 4     | ```File extension should be ".srbd"```                  | File extension mismatch.     |

## Extra: Note

### 1. Pitch

#### 12 TET Note Names

	C, C#, Db, D, D#, Eb, E, F, F#, Gb, G, G#, Ab, A, A#, Bb, B

#### n TET Note Names

	A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
	BA, BI, BU, BE, BO, CA, CI, CU, CE, CO, DA, DI, DU, DE, DO, FA, FI, FU, FE, FO
	...
	LA, LI, LU, LE, LO, MA, MI, MU, ME, MO

Pitch is the combination of the note name and the octave (ranging from 0 - 9). For example:

	C#4 d5 c8 A4 a#3 CE4 le5

### 2. Duration

Duration is the note playing duration in beat(s). Duration can be decimal or round numbers.

### 3. Voice

#### Default Voice index

| Index | Voice         |
|-------|---------------|
| 1     | piano         |
| 2     | smoothy       |
| 3     | sparkle       |
| 4     | rhodes        |
| 5     | harpsichord   |
| 6     | toypiano      |
| 7     | montre_org    |
| 8     | principal_org |
| 9     | gedackt_org   |
| 10    | sine          |
| 11    | nylon_gtr     |
| 12    | steel_gtr     |
| 13    | bass_gtr      |
| 14    | overdrive_gtr |
| 15    | trumpet       |
| 16    | trombone      |
| 17    | strings       |

Voice is the sound of a note. Voice consist of index that represent the sound file.

### 4. Examples

Some examples:

	note c4 4 9
	note Db4 2 5
	note A5 1.5 2
	note Bb4 3 5

## Extra: Custom Voices

You can add custom voices by adding a voice element ```{audio_file, is_looped, is_ring}``` into the voices table in ```init.lua``` file.

```
voices = {
	--{audio_file, is_looped, is_ring},
	{"piano", false, false},
	{"smoothy", false, false},
	{"sparkle", false, false},
	{"rhodes", false, false},
	{"harpsichord", false, false},
	{"toypiano", false, false},
	{"montre_org", true, false},
	{"principal_org", true, false},
	{"gedackt_org", true, false},
	{"sine", true, false}, -- 10
	{"nylon_gtr", false, false},
	{"steel_gtr", false, false},
	{"bass_gtr", false, false},
	{"overdrive_gtr", false, false},
	{"trumpet", true, false},
	{"trombone", true, false},
	{"strings", true, false}, -- don't forget the comma
	... add here
}
```