configuration IISInstall
{
    node "app-RegionA-01"
    {
        WindowsFeature IIS
        {
            Ensure = "Present"
            Name = "Web-Server"
        }
    }
}