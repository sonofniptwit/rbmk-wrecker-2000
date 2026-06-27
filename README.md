If you aren't using an Internet Card to directly download this to your ingame computer, you'll need to copy over no greater than 255 lines at a time. You should only have to copy it over twice; use the insert key to paste.

I would suggest running this program on the highest-spec non-server computer available in survival. Tier 3.5 RAM, tier 3 CPU, tier 3 GPU. It probably doesn't matter that much what caliber of HDD you have, but this program is
    multithreaded and may eat your processing power on low-spec setups. The tier 3 GPU is needed for maximum color depth to be able to differentiate certain colors on screen. The program uses a lot of similar shades of gray.
    You also need a t1 redstone card to get input from the receiver. If you don't care to get that data remotely, you still need the receiver torch for the program to compile, though it won't have to be connected to the computer
    via redstone analog.

All values read directly from the RBMK's fuel rod(s) need to be 'chewed' by a Redstone-over-Radio Logic Receiver first. The raw reciever won't know what to do with a redstone signal of 2,000 (representing 2,000 degrees celsius),
    so it needs to be mapped to the range 0-15 by a logic reciever somewhere down the line and retransmitted as a raw passthrough signal.

I'm still working on this program - changes may occur and you may need to do new things to make your setup compatible with newer versions of the program. I'll try to avoid this where possible, but sometimes you just have to
    take what you can get.
