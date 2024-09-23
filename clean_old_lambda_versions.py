import boto3
import sys

# Ensure boto3 is installed: pip install boto3

def remove_old_lambda_versions(function_name, versions_to_keep):
    # Create a Lambda service client with boto3
    lambda_client = boto3.client('lambda')
    
    # List versions of the function
    response = lambda_client.list_versions_by_function(FunctionName=function_name)
    
    # Filter out the $LATEST version and sort versions by number
    versions = [version['Version'] for version in response['Versions'] if version['Version'] != '$LATEST']
    versions = sorted(versions, key=lambda x: int(x))
    
    num_versions = len(versions)
    
    # Check if there's a need to remove any versions
    if num_versions <= versions_to_keep:
        print("Not enough versions to remove")
        return

    # Determine versions to remove
    versions_to_remove = versions[:num_versions - versions_to_keep]
    
    # Remove the specified versions
    for version in versions_to_remove:
        lambda_client.delete_function(FunctionName=function_name, Qualifier=version)
        print(f"Removed version {version} of {function_name}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <function_name> <versions_to_keep>")
        sys.exit(1)
    
    function_name = sys.argv[1]
    versions_to_keep = int(sys.argv[2])
    
    remove_old_lambda_versions(function_name, versions_to_keep)
