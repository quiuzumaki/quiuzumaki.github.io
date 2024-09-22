#!/bin/bash

# Directory where your PDFs are located
PDF_DIR="assets/pdfs"

# Output file (YAML format for Jekyll)
OUTPUT_FILE="_data/documents.yml"

# Create or overwrite the YAML file
echo "# List of PDF documents" > $OUTPUT_FILE

# Loop through each PDF in the directory
for pdf in "$PDF_DIR"/*.pdf; do
    # Get the base name of the PDF file (without path)
    filename=$(basename "$pdf")

    # Write the filename and title to the YAML file
    echo "- filename: $filename" >> $OUTPUT_FILE
    # Optional: use the filename without the extension as the title
    title=$(basename "$filename" .pdf)
    echo "  title: \"$title\"" >> $OUTPUT_FILE
done

echo "PDF list generated in $OUTPUT_FILE"

