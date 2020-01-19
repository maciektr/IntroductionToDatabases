CREATE FUNCTION showClientsName(
    @client_id int
)
    RETURNS varchar(100)
AS
BEGIN
    DECLARE @name VARCHAR(100) = (SELECT name + ' ' + surname FROM Participants WHERE clients_id = @client_id)
    if @name is not null
        BEGIN
            RETURN @name
        END
    SET @name = (SELECT companyName FROM Companies WHERE clients_id = @client_id)
    RETURN @name
END