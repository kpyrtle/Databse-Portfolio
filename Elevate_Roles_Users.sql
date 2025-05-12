-- Drop database users if they exist
USE [master];
GO

-- Remove /**/ below when you want to run this block of code below. Same goes for Server Logins.

/* IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AnalyticsUser')
    DROP USER [AnalyticsUser];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'DevTeamUser')
    DROP USER [DevTeamUser];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'SecurityAuditor')
    DROP USER [SecurityAuditor];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'WebAppUser')
    DROP USER [WebAppUser];
GO
*/


/*
-- Drop server logins if they exist
USE [master];
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'AnalyticsUser')
    DROP LOGIN [AnalyticsUser];
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'DevTeamUser')
    DROP LOGIN [DevTeamUser];
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'SecurityUser')
    DROP LOGIN [SecurityUser];
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'WebAppUser')
    DROP LOGIN [WebAppUser];
GO
*/

-- Create new logins (create your own passwords for each user within the quotations after the =)
CREATE LOGIN AnalyticsUser WITH PASSWORD = '';
CREATE LOGIN DevTeamUser WITH PASSWORD = '';
CREATE LOGIN SecurityUser WITH PASSWORD = '';
CREATE LOGIN WebAppUser WITH PASSWORD = '';
GO

-- Switch to ElevateRetail and create users mapped to those logins
USE [ElevateRetail];
GO

CREATE USER AnalyticsUser FOR LOGIN AnalyticsUser;
CREATE USER DevTeamUser FOR LOGIN DevTeamUser;
CREATE USER SecurityUser FOR LOGIN SecurityUser;
CREATE USER WebAppUser FOR LOGIN WebAppUser;

-- Assign roles
-- AnalyticsUser: reader only
EXEC sp_addrolemember 'db_datareader', 'AnalyticsUser';

-- DevTeamUser: reader + writer
EXEC sp_addrolemember 'db_datareader', 'DevTeamUser';
EXEC sp_addrolemember 'db_datawriter', 'DevTeamUser';

-- SecurityUser: reader + writer + securityadmin
EXEC sp_addrolemember 'db_datareader', 'SecurityUser';
EXEC sp_addrolemember 'db_datawriter', 'SecurityUser';
EXEC sp_addrolemember 'db_securityadmin', 'SecurityUser';

-- WebAppUser: reader + writer
EXEC sp_addrolemember 'db_datareader', 'WebAppUser';
EXEC sp_addrolemember 'db_datawriter', 'WebAppUser';