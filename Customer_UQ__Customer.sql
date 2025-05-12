USE [ElevateRetail]
GO

-- This script ensures that the Email field in the Customer table is unique across all rows and indexed for faster queries, without altering the table’s clustered index.

SET ANSI_PADDING ON
GO

/****** Object:  Index [UQ__Customer__A9D10534ACE38A88]    Script Date: 4/21/2025 11:19:10 AM ******/
ALTER TABLE [dbo].[Customer] ADD UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

