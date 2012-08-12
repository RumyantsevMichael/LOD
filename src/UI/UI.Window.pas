unit UI.Window;

interface

uses
  UI.Component;

type

  PWindow = ^TWindow;
  TWindow = class ( TComponent )

    constructor Create;

    procedure Render; override;
    procedure Update; override;
  end;

implementation

uses
  DGLE2_types,

  SubSystems,
  Resources;

{ TWindow }

constructor TWindow.Create;
begin
  inherited Create;
end;

procedure TWindow.Render;
begin
  inherited;

  if visible then
  begin
    txt_pack_GUI.Find('back').Draw2D( x, y, w, h );
  end;
end;

procedure TWindow.Update;
begin
  inherited Update;

  x_real := x;
  y_real := y;
end;

end.
