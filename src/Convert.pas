unit Convert;

interface

function FloatToPACar( const value : Extended ): PAnsiChar;
function IntToPAChar( const value : Integer ): PAnsiChar;
function StrToPAChar( const value : string ): PAnsiChar;
function BoolToPAChar( const value : Boolean ): PAnsiChar;

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

end.
