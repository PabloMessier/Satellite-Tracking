# load_env_and_run_terraform.ps1

# Load environment variables from .env file
Get-Content .env | ForEach-Object {
    $line = $_.Split('=', 2)
    [System.Environment]::SetEnvironmentVariable($line[0], $line[1], [System.EnvironmentVariableTarget]::Process)
}

# Invoke Terraform with all arguments passed to this script
& terraform $args