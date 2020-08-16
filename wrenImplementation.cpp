#include <iostream>
#include <fstream>
#include <cstring>
#include <stdlib.h>
#include <time.h>
#include <windows.h>
#include "src/include/wren.hpp"
#include "wrenImplementation.h"

namespace wrenImplementation {

    std::ofstream file;


    void wrenWrite(WrenVM* p_vm, const char* p_text) { //prints to console
        std::cout << p_text;
    }

    void wrenFlushOutput(WrenVM* p_vm) {
        std::cout << wrenGetSlotString(p_vm, 1);
        std::cout << std::flush;
    }

    void wrenError(WrenVM* p_vm, WrenErrorType p_type, const char* p_module, int p_line, const char* p_message) { //prints error diagnostics

        std::cout << "Type: " << p_type << std::endl;
        //std::cout << "Module: " << p_module << std::endl;
        std::cout << "Line: " << p_line << std::endl;
        std::cout << "Message: " << p_message << std::endl;
    }
    //way to return something, then free it?
    //nope :(
    char* readFile(const char* p_fileName) { //returns contents of file
        std::ifstream in(p_fileName);
        std::string contents((std::istreambuf_iterator<char>(in)), 
            std::istreambuf_iterator<char>());
        char* f_string = new char[contents.length()];
        strcpy(f_string, contents.c_str());
        return f_string;
    }

    char* loadModule(WrenVM* p_vm, const char* p_moduleName) { //returns contents of file using module name

        const char* wrenExt = ".wren";
        char* fileName = new char[strlen(p_moduleName) + strlen(wrenExt)];
        strcpy(fileName, p_moduleName);
        strcat(fileName, wrenExt);

        return readFile(fileName);
    }
    
    void wrenOpenFile(WrenVM* p_vm) { //opens file from wren
        const char* fileName = wrenGetSlotString(p_vm, 1);
        file.open(fileName);
    }

    void wrenOpenFileAppend(WrenVM* p_vm) { //opens file with append mode
        const char* fileName = wrenGetSlotString(p_vm, 1);
        file.open(fileName, std::ios::app);
    }

    void wrenInsertTextFile(WrenVM* p_vm) { //inserts text into file
        file << wrenGetSlotString(p_vm, 1);
    }

    void wrenCloseFile(WrenVM* p_vm) { //closes file from wren
        file.close();
    }

    void wrenWriteFileDep(WrenVM* p_vm) {
        std::ofstream file;
        file.open(wrenGetSlotString(p_vm, 1));
        file << wrenGetSlotString(p_vm, 2);
        file.close();
    }

    void wrenNoMethod (WrenVM* p_vm) {
        std::cout << "Could not bind function" << std::endl;
    }

    void wrenRand (WrenVM* p_vm)  { //return positive integer between 0 and positive parameter
        unsigned int max = (int)wrenGetSlotDouble(p_vm, 1); //better not return a negative number
        wrenSetSlotDouble(p_vm, 0, rand() % max); //if max is 10, return value 0-9
    }

    void wrenSound (WrenVM* p_vm) {
        Beep((int)wrenGetSlotDouble(p_vm, 1), (int)wrenGetSlotDouble(p_vm, 2));
    }

    WrenForeignMethodFn bindForeignMethod(WrenVM* p_vm, const char* p_module, const char* p_className, bool p_isStatic, const char* p_signature) { //binds foreign functions in wren to outside functions
        if (strcmp(p_signature, "open(_)") == 0) {
            return wrenOpenFile;
        }
        if (strcmp(p_signature, "openAppend(_)") == 0) {
            return wrenOpenFileAppend;
        }
        if (strcmp(p_signature, "write(_)") == 0) {
            return wrenInsertTextFile;
        }
        if (strcmp(p_signature, "close()") == 0) {
            return wrenCloseFile;
        }
        if (strcmp(p_signature, "writeDep(_,_)") == 0) {
            return wrenWriteFileDep;
        }
        if (strcmp(p_signature, "random(_)") == 0) {
            return wrenRand;
        }
        if (strcmp(p_signature, "flushOutput(_)") == 0) {
            return wrenFlushOutput;
        }
        if (strcmp(p_signature, "makeSound(_,_)") == 0) {
            return wrenSound;
        }
        return wrenNoMethod;
    }
        

    void initWrenConfig(WrenConfiguration& p_config) {
        //std::srand(time(NULL)); tbh it'll probably work here but wren wants to be gay 
        p_config.writeFn = wrenWrite;
        p_config.errorFn = wrenError;
        p_config.loadModuleFn = loadModule;
        p_config.bindForeignMethodFn = bindForeignMethod;
    }

}