import threading
import subprocess
import time
import os
import sys
import re

# Function to execute a command and log its output to a file
def execute_and_log(command, log_file):
    print("Starting to execute the logging command...")
    with open(log_file, 'w') as file:
        try:
            process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, text=True, bufsize=1)
            print("Logging command executed. Processing output...")

            for line in iter(process.stdout.readline, ''):
                file.write(line)
                file.flush()

            _, errors = process.communicate()
            if errors:
                print(f"Errors: {errors}")

        except Exception as e:
            print(f"An error occurred: {e}")

# Function to start the LuLu app
def start_lulu_app():
    print("Starting LuLu app...")
    # Replace 'lulu_app_command' with the actual command to start LuLu
    subprocess.run(["/Applications/LuLu.app/Contents/MacOS/LuLu -headless &"], shell=True)

# Function to run a custom command (e.g., curl)
def run_command(command):
    print(f"Running command: {' '.join(command)}")
    subprocess.run(command)


# Function to search for the verdict string in the log file
def search_log_for_verdict(log_file, rule_id, expected_verdict, command):
    if rule_id == "PASSIVE_MODE":
        # Regex to match the passive mode log with the specified command
        search_pattern = re.compile(rf"client in passive mode, so allowing .+/{command}")
        print(f"Searching for 'client in passive mode, so allowing' with command '{command}' in the log file...")
    elif expected_verdict == "BLOCK":
        search_pattern = re.compile(rf"RULE_ID={rule_id} setting verdict to: {expected_verdict}")
        print(f"Searching for 'RULE_ID={rule_id} setting verdict to: {expected_verdict}' in the log file...")
    elif expected_verdict == "ALLOW":
        search_pattern = re.compile(rf"RULE_ID={rule_id} rule says: {expected_verdict}")
        print(f"Searching for 'RULE_ID={rule_id} rule says: {expected_verdict}' in the log file...")
    else:
        print(f"Unexpected verdict '{expected_verdict}', only 'ALLOW' or 'BLOCK' are accepted.")
        sys.exit(1)

    # Searching the log file for the pattern
    with open(log_file, 'r') as file:
        log_contents = file.read()
        if search_pattern.search(log_contents):
            print(f"--------1/1 TEST PASSED---------")
        else:
            print(f"--------1/1 TEST FAILED---------")

# Main function
def main():
    if len(sys.argv) < 5:
        print("Usage: python test.py <app> <url> <rule_id> <expected_verdict>")
        sys.exit(1)

    # Command-line arguments
    command = sys.argv[1]
    url = sys.argv[2]
    rule_id = sys.argv[3]
    expected_verdict = sys.argv[4]
    
    # Build the command to run (e.g., curl google.com)
    run_command_list = [command, url]

    log_file = "lulu_logs.txt"
    
    # The command that generates logs with unbuffered output
    log_command = 'log stream --level debug --predicate="subsystem == \'com.nufuturo.lulu\'"'
    print(f"Log command: {log_command}")

    # Start the log listener in a separate thread
    log_thread = threading.Thread(target=execute_and_log, args=(log_command, log_file))
    log_thread.daemon = True  # Ensure thread exits when the main program exits
    log_thread.start()

    # Add a significant delay before starting the LuLu app
    print("Waiting for 5 seconds before starting the LuLu app...")
    time.sleep(5)  # Adjust delay as needed

    # Start the LuLu app
    start_lulu_app()

    print("Waiting for 60 seconds before trying to reach the URL...")
    time.sleep(60)  # Adjust delay as needed

    # Run the command after starting the app
    run_command(run_command_list)

    # Wait another 5 seconds before searching the log file
    print("Waiting for 5 seconds before searching the log file...")
    time.sleep(5)

    # Search the log file for the verdict string
    search_log_for_verdict(log_file, rule_id, expected_verdict, command)

if __name__ == "__main__":
    main()  