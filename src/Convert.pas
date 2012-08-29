unit Convert;

interface

function FloatToPACar( const value : Extended ): PAnsiChar;
function IntToPAChar( const value : Integer ): PAnsiChar;
function StrToPAChar( const value : string ): PAnsiChar;
function BoolToPAChar( const value : Boolean ): PAnsiChar;

function ExtractFileNameEx(FileName: string; ShowExtension: Boolean): string;

implementation

uses
  System.SysUtils;

function FloatToPACar( const value : Extended ): PAnsiChar;
begin
  Result := PAnsiChar( AnsiString( FloatToStr( value )));
end;

function IntToPAChar( const value : Integer ): PAnsiChar;
begin
  Result := PAnsiChar( AnsiString( IntToStr( value )));
end;

function StrToPAChar( const value : string ): PAnsiChar;
begin
  Result := PAnsiChar( AnsiString( value ));
end;

function BoolToPAChar( const value : Boolean ): PAnsiChar;
begin
  case value of
    True:  Result := 'True';
    False: Result := 'False';
  else
    Result := 'None';
  end;
end;


function ExtractFileNameEx(FileName: string; ShowExtension: Boolean): string;
var
  I: Integer;
  S, S1: string;
begin
  I := Length(FileName);

  if I <> 0 then
  begin
    while (FileName[i] <> '\') and (i > 0) do
      i := i - 1;

    S := Copy(FileName, i + 1, Length(FileName) - i);
    i := Length(S);

    if i = 0 then
    begin
      Result := '';
      Exit;
    end;

    while (S[i] <> '.') and (i > 0) do
      i := i - 1;

    S1 := Copy(S, 1, i - 1);

    if s1 = '' then
      s1 := s;

    if ShowExtension = TRUE then
      Result := s
    else
      Result := s1;
  end
  else
    Result := '';
end;

end.
