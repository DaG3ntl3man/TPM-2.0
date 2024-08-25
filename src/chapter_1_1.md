# ESAPI talking to TPM

The **ESYS context** **(`_CONTEXT *ctx`)** in TPM2 (Trusted Platform Module) is essentially a structure that holds the data required to communicate with the TPM. This context allows you to perform various operations, such as managing keys, handling sessions, and interacting with the TPM's objects.

1. **Context Structure (`_CONTEXT *ctx`)**:
   - It stores **metadata** related to the TPM session. This includes:
     - **Transient keys**: Short-lived keys stored in the TPM's memory.
     - **Persistent objects**: Long-term data stored in the TPM (e.g., encryption keys, certificates).
     - **NV (Non-Volatile) indexes**: Data stored in TPM that persists across reboots.
     - **Sessions**: A means to track interactions with the TPM, such as encrypted communication or auditing.

2. **Initialization**:
   - The context is initialized using the `Esys_Initialize()` function. This connects your application to the TPM.
   - Example:
     ```c
     ESYS_CONTEXT *ctx;
     TSS2_TCTI_CONTEXT *tcti;
     Esys_Initialize(&ctx, tcti, NULL);
     ```
     In this case, `ctx` is the handle for the ESYS context. `tcti` represents the TCTI (Transmission Interface), which defines how your system interacts with the TPM hardware or simulator.

3. **TCTI Context**:
   - If `tcti` is **NULL**, the TCTI loader will automatically attempt to detect the most common TPM interfaces, which is useful in generic setups.
   - Example:
     ```c
     Esys_Initialize(&ctx, NULL, NULL);
     ```
     This will initialize the TPM communication interface without explicitly specifying the TCTI context. The system tries standard interfaces (e.g., device drivers, socket connections).

4. **Return Codes**:
   - Every **ESAPI** (Enhanced System API) call returns a status code that must be checked to ensure success. The code `TSS2_RC_SUCCESS` indicates that the function executed correctly.
   - Always verify the return code after an API call:
     ```c
     TSS2_RC rc = Esys_Initialize(&ctx, NULL, NULL);
     if (rc != TSS2_RC_SUCCESS) {
         // Handle error
     }
     ```

5. **TPM2 Simulator**:
   - When working with a TPM2 simulator (e.g., for development or testing), the TPM must be initialized with a **startup command** to become operational.
   - The command `Esys_Startup(ctx, TPM2_SU_CLEAR)` starts the TPM and ensures it is ready to process commands.
   - Example:
     ```c
     rc = Esys_Startup(ctx, TPM2_SU_CLEAR);
     if (rc != TSS2_RC_SUCCESS) {
         // Handle startup failure
     }
     ```

### Real-World Example:
Consider an application that initializes a TPM context, loads a key, and interacts with the TPM to encrypt data. It might look like this:
1. **Initialize the TPM context**:
   ```c
   ESYS_CONTEXT *ctx;
   TSS2_RC rc = Esys_Initialize(&ctx, NULL, NULL);
   if (rc != TSS2_RC_SUCCESS) {
       // Initialization failed
   }
   ```

2. **Start the TPM (if using a simulator)**:
   ```c
   rc = Esys_Startup(ctx, TPM2_SU_CLEAR);
   if (rc != TSS2_RC_SUCCESS) {
       // TPM startup failed
   }
   ```

3. **Use the context to perform operations (e.g., load a key, sign data)**:
   ```c
   // Perform other operations using ctx (like loading transient keys, handling sessions, etc.)
   ```
>- **ESYS context** is central to managing TPM operations, providing a secure way to interact with keys, sessions, and persistent objects.
>- Correct initialization and checking return codes are critical to ensuring smooth communication with the TPM.
>- When using a TPM simulator, always ensure that the TPM is started correctly using the `Esys_Startup` function.


### Defining our own **TCTI parameters** when using a TPM simulator, as well as requesting random bytes from the TPM using **`Esys_GetRandom`**. 

1. **Defining Custom TCTI Parameters**:
   - When interacting with a TPM simulator, it is necessary to define your own **TCTI** (Transmission Interface) parameters to specify how your application connects to the simulator.
   - In this case, the `TSS2_TCTI_CONTEXT *tcti` is used to represent the communication context for the TPM.
   
   Example of defining TCTI parameters:
   ```c
   TSS2_TCTI_CONTEXT *tcti;
   Tss2_TctiLdr_Initialize("mssim:host=127.0.0.1,port=2321", &tcti);
   ```
   - **"mssim:host=127.0.0.1, port=2321"**: Specifies that we are using a TPM simulator running on `localhost` (127.0.0.1) with communication on port 2321.
   - **tcti**: This structure is populated with the TCTI context and is necessary to connect the application with the TPM simulator.

2. **Using TCTI with ESYS Context**:
   - After defining and initializing the TCTI context, it is used as the second argument in the **ESYS context** initialization.
   - This step is critical as it connects your ESYS API calls with the specific TPM communication interface.
   
   Example:
   ```c
   ESYS_CONTEXT *ctx;
   Tss2_TctiLdr_Initialize("mssim:host=127.0.0.1,port=2321", &tcti); // TCTI initialized
   Esys_Initialize(&ctx, tcti, NULL); // ESYS context initialized using the TCTI context
   ```

3. **Requesting Random Bytes from the TPM**:
   - Once the TPM simulator is set up and the connection via TCTI is established, we can request random bytes from the TPM using the **Esys_GetRandom** function.
   - The function requests a specified number of random bytes and stores them in the provided buffer.

   Example:
   ```c
   UINT8 *random_bytes;
   TSS2_RC rc = Esys_GetRandom(ctx, ESYS_TR_NONE, ESYS_TR_NONE, ESYS_TR_NONE, RANDOM_BYTES_COUNT, &random_bytes);
   if (rc != TSS2_RC_SUCCESS) {
       // Handle error in fetching random bytes
   }
   ```
   - **Esys_GetRandom()**: This function requests random bytes from the TPM.
   - **`ctx`**: The ESYS context, which is required for the operation.
   - **`ESYS_TR_NONE`** (three times): These are placeholders for TPM sessions. In this case, no TPM sessions are used.
   - **`RANDOM_BYTES_COUNT`**: The number of random bytes being requested.
   - **`&random_bytes`**: A pointer to store the random bytes fetched from the TPM.

4. **TPM Sessions as Placeholders**:
   - The arguments in green (`ESYS_TR_NONE`) are placeholders for TPM sessions. These sessions are often used for secure, encrypted, or authenticated communication. However, in this example, no TPM session is used, so we pass `ESYS_TR_NONE` for each placeholder.

5. **ESAPI Functions Documentation**:
   - For detailed documentation and to explore more ESAPI (Enhanced System API) functions, you can refer to the official documentation:
     - **Random bytes request**: [Esys_GetRandom](https://tpm2-tss.readthedocs.io/en/2.4.5/group__esys__getrandom.html)
     - **General ESAPI functions**: [ESAPI Documentation](https://tpm2-tss.readthedocs.io/en/2.4.5/group__esys__tpm.html)

### Real-World Example:
1. **Initialize TCTI context for TPM Simulator**:
   ```c
   TSS2_TCTI_CONTEXT *tcti;
   Tss2_TctiLdr_Initialize("mssim:host=127.0.0.1,port=2321", &tcti);  // Connect to simulator
   ```

2. **Initialize ESYS context using TCTI**:
   ```c
   ESYS_CONTEXT *ctx;
   TSS2_RC rc = Esys_Initialize(&ctx, tcti, NULL); // Use TCTI in ESYS initialization
   if (rc != TSS2_RC_SUCCESS) {
       // Handle initialization failure
   }
   ```

3. **Request random bytes from the TPM**:
   ```c
   UINT8 *random_bytes;
   rc = Esys_GetRandom(ctx, ESYS_TR_NONE, ESYS_TR_NONE, ESYS_TR_NONE, 16, &random_bytes); // Request 16 random bytes
   if (rc != TSS2_RC_SUCCESS) {
       // Handle error in fetching random bytes
   } else {
       // Use the random bytes
   }
   ```

>- **TCTI** context setup is required when using a TPM simulator, as it defines how your application interacts with the TPM.
>- **Esys_GetRandom** allows for fetching random bytes from the TPM, which can be useful for cryptographic operations.
>- It's important to manage sessions, initialize the TPM properly, and ensure you handle return codes to verify success in each operation.

>> **Note on TCTI Support in TPM2-TSS:**
> - **TCTI supports communication with TPM over various interfaces**, including USB and I2C. This provides flexibility in connecting to different types of TPM devices, even in environments without TPM drivers or operating systems.<br><br>
> - **`tcti-i2c-ftdi`**:<br>
     -  Used for communicating with **I2C-based TPMs**.<br>
     -  Applicable in cases where there is no TPM driver present or in systems with no operating system.<br>
     -  For more details, see `tcti-i2c-ftdi.md`.
    <br><br>
> - **`tcti-spi-itt2go`**:<br>
     -  Specifically used for communication with the **LetsTrust-TPM2Go**, a USB stick housing an SPI-based TPM.<br>
     -  The SPI-based TPM is connected to the host via **libusb**.<br>
     -  For more details, see `tcti-spi-itt2go.md`.


