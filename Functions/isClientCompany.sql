CREATE FUNCTION isClientCompany(
    @client_id int
)
    RETURNS bit
AS
BEGIN
    DECLARE @res bit = ISNULL((SELECT 1 FROM Companies WHERE clients_id=@client_id),0)
    RETURN @res
END