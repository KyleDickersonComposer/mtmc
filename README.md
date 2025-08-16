### An implementation of the Montana state Mini Computer (MTMC) in Odin and raylib with Added Music and Sound Features

The plan is to embed this into my music teaching website so that my music students can develop some technical skills while doing music stuff. A 16-bit mini-computer is a good way to learn about music technology because music notation is discrete, and music theoretical concepts often look similar to concepts from discrete math and computer science. The MTMC in its current iteration, at the time of writing this, lacks audio and music functionality which are natural features for the 16-bit games projects that naturally flow from the MTMC's design.

### Planned Music Features
- Music notation system
- Music encoding system
- Some kind of API that makes music easy to work with
- I want the computer to understand some music theory concepts. (How crazy we talkin'?)
- Some kind of music generation program (would be cool to tie the music generation into Conway's Game of life somehow)

### Music Encoding
#### First Byte
- 3 bits for pitch (zero for rests)
- 2 bits for accidental
- 3 bits for octave

#### Second Byte
- 5 bits for duration
- 2 bits for tie_kind
- 1 bit for dot

#### Third Byte
- 2 bits for envelope shape (cresc. | decresc. | doit | fall | n.b. first two are volume and the second two are pitch)
- 1 bit vibrato flag bit
- 1 bit legato flag bit
- 1 bit marcato flag bit
- 1 bit for dynamics (loud/soft)
- 1 bit for staccato (short/full)
- 1 bit for if the accidental bit isn’t set to zero, we treat the accidental as a double (# → x, b → bb)

### Planned Audio Features
- 4 voice 16-bit synthesizer
- Sampler (needs to have a noise thing?)
- Will probably need to figure out some audio FX so that it doesn't sound like crap because digital... (filters, eq, modulation, and distortion)
- Probably want some kind of way to configure that timbre of each voice (probably need some way to configure it as a function of time? or, atleast have switches or something?)

### Links
- [MTMC Site](https://mtmc.cs.montana.edu/)
- [MTMC Github](https://github.com/msu/mtmc)

### Useful Odin Features
- [Bit Fields for everything](https://odin-lang.org/docs/overview/#bit-fields)
- [Bit Sets for flags](https://odin-lang.org/docs/overview/#bit-sets)
- [Conditional Compilation for supporting native and wasm](https://odin-lang.org/docs/overview/#conditional-compilation)
