# Import base image
FROM --platform=linux/amd64 ubuntu:latest

# Copy Linux version of optseq2 into Docker img root folder
COPY optseq2 /

# Give optseq permissions to read/write/execute
RUN chmod +rwx ./optseq2