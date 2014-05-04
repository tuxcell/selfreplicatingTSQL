SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

CREATE PROCEDURE AntiReplicator 
--Joseph Gama©
AS
declare @current_proc varchar(255),@current_text varchar(8000),@cmd varchar(8000), @a int
DECLARE _Cursor CURSOR FOR 
SELECT o.name,c.text FROM sysobjects o INNER JOIN syscomments c ON c.id = o.id 
WHERE o.type='p' and o.category=0 and encrypted=0  --and o.name<>'Replicator'
OPEN _Cursor
FETCH NEXT FROM _Cursor INTO @current_proc, @current_text
WHILE @@FETCH_STATUS=0
BEGIN 
--is it infected?
IF CHARINDEX('ReplicatorDone:',@current_text)>0 
	BEGIN
	--get code
	SET @cmd =  replace(@current_text, 'CREATE PROCEDURE ' + @current_proc, 'ALTER PROCEDURE ' + @current_proc )
	--remove Replicator call
	SET @cmd =  replace(@cmd,'GOTO Replicator'+char(13)+'ReplicatorDone:'+char(13),'')
	--remove Replicator code
	set @a=CHARINDEX('Replicator:',@cmd)-10
	SET @cmd = left(@cmd,@a)
	exec(@cmd)
	END
FETCH NEXT FROM _Cursor INTO @current_proc, @current_text
END
CLOSE _Cursor
DEALLOCATE _Cursor
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

