# Disable Certificate Validation

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()

# Get Credentials

$cred = Get-Credential

$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.Password))
$userpass  = $cred.UserName + ":" + $password

# Create header with authentication

$bytes= [System.Text.Encoding]::UTF8.GetBytes($userpass)
$encodedlogin=[Convert]::ToBase64String($bytes)
$authheader = "Basic " + $encodedlogin
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization",$authheader)

# Create JSON body with static route info

$Route1 = @{
  "network" = "45.1.1.0/24"
  "next_hops" = @(
    @{
      "ip_address" = "41.1.1.1"
      "admin_distance" = 1
    }
  )
} | Convertto-Json

$Route2 = @{
  "network"= "45.24.1.0/24"
  "next_hops"= @(
    @{
      "ip_address"= "41.1.1.1"
      "admin_distance"= 1
    }
    @{
      "ip_address"= "42.1.1.1"
      "admin_distance"= 2
    }
    @{
      "ip_address"= "43.1.2.3"
      "admin_distance"= 3
    }
  )
} | ConvertTo-Json

$Route3 = @{
  "network" = "25.1.1.0/24"
  "next_hops" = @(
    @{
      "ip_address" = "45.1.1.1"
      "admin_distance" = 1
    }
  )
} | Convertto-Json

# Create URIs

$uri1 = "https://10.2.0.3/policy/api/v1/infra/tier-1s/TNT57-T1/static-routes/Test-API-Route1"
$uri2 = "https://10.2.0.3/policy/api/v1/infra/tier-1s/TNT57-T1/static-routes/Test-API-Route2"
$uri3 = "https://10.2.0.3/policy/api/v1/infra/tier-1s/TNT57-T1/static-routes/Test-API-Route3"

#Run Commands to create static routes

Invoke-RestMethod -Uri $uri1 -Headers $headers -Method Patch -ContentType "Application/JSON" -Body $Route1
Invoke-RestMethod -Uri $uri2 -Headers $headers -Method Patch -ContentType "Application/JSON" -Body $Route2
Invoke-RestMethod -Uri $uri3 -Headers $headers -Method Patch -ContentType "Application/JSON" -Body $Route3

