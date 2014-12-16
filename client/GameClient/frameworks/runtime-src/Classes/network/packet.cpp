#include "packet.h"
#include "MemoryPool.h"

MemoryPool packetMemoryPool(sizeof(PacketBuffer), 10*MemSize::SIZE1M);