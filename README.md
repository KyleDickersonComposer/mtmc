### Odin-MTMC

The plan is to port MTMC to Odin and raylib so that I have a nice project to work on for learning raylib and Odin in more depth. I still need to decide if I'm just going to write everything in raylib, or if I'm going to use raygui for the textboxes and stuff. Probably better to just learn it from scratch... or atleat from raylib and Odin as the base.

Odin and raylib are a good platform for a project like MTMC because they both have good wasm support. Also, I think we can implement the MTMC's file system using the IndexedDB API in javascript which would allow for us to serve this badboy statically.

I will probably end up using the Crafting Interpreters book as a reference for how to implement a Stack-Based VM. The C-like language inside of MTMC, called Sea, will also involve concepts from Crafting Interpreters. This gives a good opportunity to tackle two cool projects, and prepare for future my big raylib/Odin project.

### Links
- [MTMC Specification](https://github.com/KyleDickersonComposer/mtmc/blob/master/docs/MTMC_SPECIFICATION.md)
- [MTMC Asm](https://github.com/KyleDickersonComposer/mtmc/blob/master/docs/MTMC_ASSEMBLY.md)


### Useful Odin Features
- [Bit Fields for everything](https://odin-lang.org/docs/overview/#bit-fields)
- [Bit Sets for flags](https://odin-lang.org/docs/overview/#bit-sets)
