# coReV32: A Pipelined RISC-V Processor

**coReV32** is a pipelined RISC-V processor implemented in VHDL. This design includes:

- **Complete RV32I ISA Support**: Fully supports the RV32I instruction set architecture, enabling a wide range of applications.
- **Privileged Machine Mode**: Includes support for privileged machine mode to manage system-level operations and resources.
- **Support for Interrupts**: Efficiently handles both internal and external interrupts.
- **External Interrupt Handling with PLIC**: Utilizes the Platform-Level Interrupt Controller (PLIC) to facilitate the management of external interrupts.
- **Hazard Detection**: Implements mechanisms to identify and resolve data and control hazards during instruction execution.
- **Exception Handling**: Provides a robust framework for managing exceptions that may arise during operation.
  
This project aims to deliver a pipelined processor with interrupt handling and privileged machine mode, designed for embedded applications. Future developments will focus on incorporating additional extensions and privileged modes to enhance its capabilities.

