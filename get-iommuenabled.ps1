# Script to identify all VMs with IOMMU Enabled
# Steve Galbincea 12-10-2024

# Connect to vCenter Server
Connect-VIServer -Server your_vcenter_server -User your_username -Password your_password

# Define the output CSV file path
$outputFile = "C:\path\to\your\output\iommu_status.csv"

# Array to hold VM information
$vmInfo = @()

# Get all running VMs and check for IOMMU setting
Get-VM | Where-Object { $_.PowerState -eq "PoweredOn" } | ForEach-Object {
    $vm = $_
    $iommuStatus = "Disabled or Not Configured"
    $vmConfigSpec = $vm.ExtensionData.Config
    if ($vmConfigSpec.Hardware.Device | Where-Object { $_.DeviceInfo.Label -eq "IOMMU" }) {
        $iommuStatus = "Enabled"
    }

    # Add VM information to the array
    $vmInfo += [PSCustomObject]@{
        'VM Name' = $vm.Name
        'IOMMU Status' = $iommuStatus
        'Power State' = $vm.PowerState
        'VM Host' = ($vm | Get-VMHost).Name
        'Cluster' = ($vm | Get-Cluster).Name
    }
}

# Export the information to CSV
$vmInfo | Export-CSV -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Output "IOMMU status report has been saved to $outputFile"

# Disconnect from vCenter Server
Disconnect-VIServer -Confirm:$false
