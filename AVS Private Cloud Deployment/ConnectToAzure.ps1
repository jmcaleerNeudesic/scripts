$sub = "3988f2d0-8066-42fa-84f2-5d72f80901da"

write-host -ForegroundColor Blue "
Connecting to your Azure Subscription $sub ... there should be a web browser pop-up ... go there to login"
Connect-AzAccount -Subscription $sub 
write-host -ForegroundColor Green "
Azure Login Successful
"
