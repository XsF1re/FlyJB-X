#import <substrate.h>

typedef void (*mshookmemory_t)(void *target, const void *data, size_t size);
void scan_executable_memory_with_image_index(const uint8_t *target, const uint32_t target_len, void (*callback)(uint8_t *), uint32_t image_index);
void scan_executable_memory(const uint8_t *target, const uint32_t target_len, void (*callback)(uint8_t *));
bool hook_memory(void *target, const void *data, size_t size);
bool hasASLR();
uintptr_t get_slide();
uintptr_t calculateAddress(uintptr_t offset);
bool getType(unsigned int data);
bool writeData(uintptr_t offset, unsigned int data);
