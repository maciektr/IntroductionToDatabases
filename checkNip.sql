CREATE FUNCTION IsValidNip
(
  @nip nvarchar(15)
)
RETURNS bit
AS
BEGIN
    IF ISNUMERIC(@nip) = 0 BEGIN
        RETURN 0
        END

    IF @nip='0000000000' BEGIN
        RETURN 0
        END
    IF @nip='1234567891' BEGIN
        RETURN 0
        END
    IF @nip='1111111111' BEGIN
        RETURN 0
        END
    IF @nip='1111111112' BEGIN
        RETURN 0
        END
    IF @nip='9999999999' BEGIN
        RETURN 0
        END
    IF @nip='1111111112' BEGIN
        RETURN 0
        END

    DECLARE @sum TINYINT;
    SET @sum = 6 * CONVERT(TINYINT, SUBSTRING(@nip,1,1)) +
               5 * CONVERT(TINYINT, SUBSTRING(@nip,2,1)) +
               7 * CONVERT(TINYINT, SUBSTRING(@nip,3,1)) +
               2 * CONVERT(TINYINT, SUBSTRING(@nip,4,1)) +
               3 * CONVERT(TINYINT, SUBSTRING(@nip,5,1)) +
               4 * CONVERT(TINYINT, SUBSTRING(@nip,6,1)) +
               5 * CONVERT(TINYINT, SUBSTRING(@nip,7,1)) +
               6 * CONVERT(TINYINT, SUBSTRING(@nip,8,1)) +
               7 * CONVERT(TINYINT, SUBSTRING(@nip,9,1));

    IF CONVERT(TINYINT,SUBSTRING(@nip,10,1)) = (@sum % 11) BEGIN
        RETURN 1
        END
    RETURN 0
END
