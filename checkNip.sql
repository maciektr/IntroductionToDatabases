CREATE FUNCTION IsValidNip
(
  @nip nvarchar(15)
)
RETURNS bit
AS
BEGIN
  SELECT @nip = REPLACE(@nip,'-','')
  IF ISNUMERIC(@nip) = 0
    RETURN 0
  DECLARE
    @weights AS TABLE
    (
      Position tinyint IDENTITY(1,1) NOT NULL,
      Weight tinyint NOT NULL
    )
  INSERT INTO @weights VALUES (6), (5), (7), (2), (3), (4), (5), (6), (7)
  IF SUBSTRING(@nip, 10, 1) = (SELECT SUM(CONVERT(TINYINT, SUBSTRING(@nip, Position, 1)) * Weight) % 11 FROM @weights)
    RETURN 1
  RETURN 0
END
