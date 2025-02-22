################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (12.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.c 

O_SRCS += \
../CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.o 

OBJS += \
./CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.o 

C_DEPS += \
./CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.d 


# Each subdirectory must supply rules for building sources it contributes
CMakeFiles/3.28.1/CompilerIdC/%.o CMakeFiles/3.28.1/CompilerIdC/%.su CMakeFiles/3.28.1/CompilerIdC/%.cyclo: ../CMakeFiles/3.28.1/CompilerIdC/%.c CMakeFiles/3.28.1/CompilerIdC/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m3 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F103xB -c -I../../Core/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc -I../../Drivers/STM32F1xx_HAL_Driver/Inc/Legacy -I../../Drivers/CMSIS/Device/ST/STM32F1xx/Include -I../../Drivers/CMSIS/Include -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfloat-abi=soft -mthumb -o "$@"

clean: clean-CMakeFiles-2f-3-2e-28-2e-1-2f-CompilerIdC

clean-CMakeFiles-2f-3-2e-28-2e-1-2f-CompilerIdC:
	-$(RM) ./CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.cyclo ./CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.d ./CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.o ./CMakeFiles/3.28.1/CompilerIdC/CMakeCCompilerId.su

.PHONY: clean-CMakeFiles-2f-3-2e-28-2e-1-2f-CompilerIdC

