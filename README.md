A mod that adds Music Box to the minetest game. Right clicking the box with a 'Book with Text' will play the SMML (Sarabande Musical Markup Language) commands written in the book. This mod is an implementation of [Sarabande](https://beauprograming.blogspot.com/2024/09/pemutar-musik-sarabande.html) in Minetest Lua.

# Features
* Variable tuning system, based on the [Equal Temprament](https://en.wikipedia.org/wiki/Equal_temperament) system.
* Over 16 default voices, can be extended with more voices.
* 1 Audio sample per voice, no need to make each audio file by pitch.
* Fine tuning, trim the pitch by cents.
* Dynamics, change how loud notes should be played.
* Store variables, and do arithmetic operations.

# How to Use
* Craft the Music Box, this requires 2 Steel Ingots, 1 Obsidian Glass, 4 Black Wools, 1 Mese Crystal, and 1 Book.
* Craft a Book, then write the book with SMML musical sequence.
* Right click the music box with the Book you have written.
* Sit back and enjoy the music

# SMML Example
Write this into a Book
```
## Initialize time signature, tempo, and tuning system

time 4
tempo 60
tuning 12tet

## Play some chords

## Am
note a3 2 1
note c4 2 1
note e4 2 1

next 2

## G
note g3 2 1
note b3 2 1
note d4 2 1

next 2

## F
note f3 2 1
note a3 2 1
note c4 2 1

next 2

## E
note e3 2 1
note g#3 2 1
note b3 2 1

next 2

## The end

end
```
Then right click into a Music Box
This will play a sequence of chords

More examples provided inside the mod folder "musics"

# Manual
Read the REFMAN.md file

# Notice
Note that this mod is not fully finished and may contain bugs or can even cause crashes.
