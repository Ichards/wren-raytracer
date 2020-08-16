#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <time.h>
#include "src/include/wren.hpp"
#include "wrenImplementation.h"

int main()
{

    std::srand(time(NULL)); //initialize seed

    WrenConfiguration config;
    wrenInitConfiguration(&config);
    wrenImplementation::initWrenConfig(config);
    


    WrenVM* vm = wrenNewVM(&config);



    WrenInterpretResult result = wrenInterpret(
    vm,
    "render",
    wrenImplementation::readFile("render.wren")); 

    wrenFreeVM(vm);

    
}
