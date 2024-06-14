# riskyprocessor

My attempt at a basic RISC-V core (RISCV32I)

### Progress:

- [x] 5 stage pipeline
- [x] Load instructions
- [ ] Little endian loading
- [ ] Arithmetic instructions
- [x] Data forwarding
- [ ] Jump instructions
- [ ] Branch instructions

Random thoughts:

Implementing the skeleton of the 5 stage pipeline was quite fun. I had to (and still have to) decide which data gets
to be passed to the next stage. Implementing the memory was just a matter of figuring out the right verilog syntax to 
read files. Implementing the load memory operations was really not bad. Arithmetic was quite easy. The hardest part
so far has been creating a forwarding unit to deal with data hazards. Actually, it wasn't too bad, just a matter of
knowing from where to pull data from to the front of the pipeline. I think the actual hard part will be implementing
branch instructions. 

At every stage after execute, we need to know the sel_rd value that was passed on to check whether data forwarding is
necessary. So, that value is passed on as well.

For store operations, we pass the contents read from the rs2 register to the mem_access stage so that the data can
be written to memory. Doing a store right after an arithmetic operation... Should I add a forwarding unit to the mem_access stage?

Note to self before logging off: I am working on transferring the data slicing part out of the writeback stage to the mem_access stage. Need to test if it works, I finished before i leave