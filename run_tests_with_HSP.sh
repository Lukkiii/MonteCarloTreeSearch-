#!/bin/bash

# Base command to run the Java program
JAVA_CMD="java -cp classes:lib/pddl4j-4.0.0.jar fr.uga.pddl4j.planners.statespace.HSP"

# Root directory containing the test folders
TEST_DIR="src/test"

# Results directory
RESULTS_DIR="results_HSP"

# List of main directories to process
DOMAINS=("blocks" "depots" "gripper" "logistics")

# Create the results directory if it doesn't exist
mkdir -p "$RESULTS_DIR"

# Iterate over each domain
for domain in "${DOMAINS[@]}"; do
  # Directory for each domain's results
  DOMAIN_RESULTS_DIR="$RESULTS_DIR/$domain"
  mkdir -p "$DOMAIN_RESULTS_DIR"

  # Summary file for each domain
  SUMMARY_FILE="$DOMAIN_RESULTS_DIR/${domain}_summary.txt"
  
  # Initialize summary file
  echo "Problem | Steps | Total Time (seconds)" > "$SUMMARY_FILE"

  # Find all domain.pddl files in subdirectories and sort them
  find "$TEST_DIR/$domain" -type f -name "domain.pddl" | sort | while read -r domain_file; do
    # Get the directory of the domain file
    dir=$(dirname "$domain_file")
    
    # Find all problem files (e.g., p001.pddl, p002.pddl) in the same directory as the domain file, and sort them
    find "$dir" -type f -name "p*.pddl" | sort | while read -r problem_file; do
    
      # Output file to store each individual test result in the domain's results directory
      output_file="$DOMAIN_RESULTS_DIR/$(basename "${problem_file%.pddl}_output.txt")"
      
      # Run the Java command with the current domain and problem file, and save output
      echo "Running: $JAVA_CMD $domain_file $problem_file"
      $JAVA_CMD "$domain_file" "$problem_file" > "$output_file"
      
      # Extract total time and steps from output file
      total_time=$(grep "total time" "$output_file" | awk '{print $1}')
      steps=$(grep -E '^[0-9]+:' "$output_file" | wc -l)

      # Append the result to the domain's summary file
      echo "$(basename "$problem_file") | $steps | $total_time" >> "$SUMMARY_FILE"
    done
  done
done