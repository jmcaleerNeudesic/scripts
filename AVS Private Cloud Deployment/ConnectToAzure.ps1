$deployvariablesvariables = "C:\Users\Josh.Mcaleer\OneDrive - Neudesic\Documents\GitHub\scripts\AVS Private Cloud Deployment"
Invoke-Expression $($deployvariablesvariables.Content)

write-host -ForegroundColor Yellow "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub
write-host -ForegroundColor Green "
Azure Login Successful
"
 