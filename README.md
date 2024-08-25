# Trusted Platform Module (TPM 2.0)

Welcome to the TPM-2.0 repository! This project is designed to help you get started with TPM, offering a hands-on environment to explore its capabilities. Whether you're new to TPM or looking to deepen your understanding, this repo provides the tools and resources you need.

### Disclaimer
Before we dive into TPM, here's a prerequisite glossary. Feel free to refer back to this section anytime you need to clarify terms or concepts related to TPM. Brief Info Only!

<div style="width:100%;height:0;padding-bottom:40%; display: block; text-align: center;">
    <iframe src="https://giphy.com/embed/d30oLgYQg8xMNlGE" width="478" height="266" style="border:0;" class="giphy-embed" allowFullScreen></iframe>
</div>

### Getting Started

To set up your TPM lab environment, follow these steps:

1. **Download and Run the Docker Image**
   ```bash
   docker run --name tpmlab -w ~/lab -it -d --platform=linux/amd64 -e TPM2TOOLS_TCTI=mssim:host=localhost,port=2321 tpmdev/ost2-tpm-course:tc1102
   ```

   > **Note for Windows Users:**  
   > Use `-w "/mnt/host/c/Users/WHEREVER/YOUR/LAB/FOLDER"` to specify a working folder for Docker.

2. **Attach to the Docker Container**
   ```bash
   docker attach tpmlab
   ```

3. **Start the TPM2 Simulator**
   ```bash
   tpm_server > tpm.log &
   tpm2_startup -c
   ```

4. **Verify the Lab Environment**
   Generate eight random bytes from the TPM to ensure your setup is correct:
   ```bash
   tpm2_getrandom 8 > randombytes
   xxd randombytes
   ```

   > **Important:** Do not use the `latest` tag. This setup is for the Beta course only; later, the images will be merged into one.

### Trusted Computing Group Glossary

For a comprehensive glossary of TPM-related terms, refer to the [TCG Glossary](https://trustedcomputinggroup.org/wp-content/uploads/TCG-Glossary-V1.1-Rev-1.0.pdf).

---
