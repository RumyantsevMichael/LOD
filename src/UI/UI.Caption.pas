unit UI.Caption;

interface

uses
  DGLE2_types,

  UI.Component;

type

  TAlign = ( Left, Center, Right );

  TCaption = class ( TComponent )
    text : string;
    color : TColor4;
    font : string;
    size : Byte;

    align : TAlign;

    shadow : Boolean;

    constructor Create;

    procedure Render; override;
    procedure Update; override;
  end;

procedure DrawCaption( const rect : TRectf; const text : string; color : TColor4; font : string = 'Tahoma'; size : Byte = 10 );

implementation

uses
  SubSystems,
  Resources,
  Convert;

procedure DrawCaption( const rect : TRectf; const text : string; color : TColor4; font : string = 'Tahoma'; size : Byte = 10 );
var
  x : Integer;
  y : Integer;
  w : Cardinal;
  h : Cardinal;
begin
  FntPack.Find( font, size ).GetTextDimensions( StrToPAChar( text ), w, h );
  x := Round(rect.x + rect.width / 2 - w / 2);
  y := Round(rect.y + rect.height / 2 - h / 2);
  FntPack.Find( font, size ).Draw2D( x, y, StrToPAChar( text ), Color4 );
end;

{ TCaption }

constructor TCaption.Create;
begin
end;

procedure TCaption.Render;
var
  width : Cardinal;
  height : Cardinal;
  pos_x : Integer;
  pos_y : Integer;
begin
  inherited;

  if visible then
  begin
    FntPack.Find( font, size).GetTextDimensions( StrToPAChar( text ), width, height );

    pos_x := 0;

    case align of
      Left:   pos_x := x_real;

      Center: pos_x := Round( x_real + w / 2 - width / 2);

      Right:  pos_x := Round( x_real + w - width / 1 );
    end;

    pos_y := Round( y_real + h / 2 - height / 2);

    if shadow then
      FntPack.Find( font, size).Draw2D( pos_x+1, pos_y+1, StrToPAChar( text ), color4($0) );

    FntPack.Find( font, size).Draw2D( pos_x, pos_y, StrToPAChar( text ), color );
  end;
end;

procedure TCaption.Update;
begin
  inherited;

  x_real := parent.x_real + x;
  y_real := parent.y_real + y;
end;

end.
