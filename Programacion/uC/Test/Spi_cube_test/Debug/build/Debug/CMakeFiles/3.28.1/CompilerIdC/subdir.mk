################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (12.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../build/Debug/CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.c 

O_SRCS += \
../build/Debug/CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.o 

OBJS += \
./build/Debug/CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.o 

C_DEPS += \
./build/Debug/CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.d 


# Each subdirectory must supply rules for building sources it contributes
build/Debug/CMakeFiles/3.28.1/CompilerIdC/%.o build/Debug/CMakeFiles/3.28.1/CompilerIdC/%.su build/Debug/CMakeFiles/3.28.1/CompilerIdC/%.cyclo: ../build/Debug/CMakeFiles/3.28.1/CompilerIdC/%.c build/Debug/CMakeFiles/3.28.1/CompilerIdC/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-build-2f-Debug-2f-CMakeFiles-2f-3-2e-28-2e-1-2f-CompilerIdC

clean-build-2f-Debug-2f-CMakeFiles-2f-3-2e-28-2e-1-2f-CompilerIdC:
	-$(RM) ./build/Debug/CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.cyclo ./build/Debug/CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.d ./build/Debug/CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.o ./build/Debug/CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.su

.PHONY: clean-build-2f-Debug-2f-CMakeFiles-2f-3-2e-28-2e-1-2f-CompilerIdC

