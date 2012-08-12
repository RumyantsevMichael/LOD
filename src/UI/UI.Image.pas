unit UI.Image;

interface

uses
  Resources,

  UI.Component;

type

  TImage = class ( TComponent )
    image : PTexture;

    constructor Create;

    procedure Render; override;
    procedure Update; override;
  end;

implementation

uses
  DGLE2_types,

  SubSystems;

{ TImage }

constructor TImage.Create;
begin
end;

procedure TImage.Render;
begin
  inherited;

  if visible then
  begin
    if image <> nil then
      image.Draw2D( x_real, y_real, w, h );
  end;
end;

procedure TImage.Update;
begin
  inherited;

  x_real := parent.x_real + x;
  y_real := parent.y_real + y;
end;

end.
