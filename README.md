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
be written to memory. Doing a store right after an arithmetic operation... Should I add a forwarding unit to the mem_access stage? Yes. But first, there is another problem. Since store operations need the contents of the rs2 register even after the execute stage, it should be passed along the pipeline. This value being passed on should be muxed in case of a hazard. But wait, it already IS muxed! 

Nope, that was a red herring. The real problem is that there is no bypass from execute to the next execute. When one instruction has rd as rs2 and a consecutive instruction needs rs2 in execute, the previous result of execute should be routed back. Hold on, but we already detect hazards between mem and execute. Shoot, bypasses for memory loads and other instructions should take a different path. 

Scenario:
LW x31, 4(x0)
AND x30, x31, x0

Here, AND must access the value of x31 from the memory read. 

Scenario: 
ADD x29, x31, x30
AND x28, x29, x10

Here, AND must access the alu result value of the ADD instruction. 

So, the hazard detector should detect whether the previous instruction was a load or something else. Or is there another way? Could we switch the bypass data based on the instruction being executed? I think that's an easier way. 