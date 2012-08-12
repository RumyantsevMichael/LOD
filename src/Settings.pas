unit Settings;

interface

uses
  DGLE2_types;

type

  TWindow = record
    Width : Integer;
    Height : Integer;
    FullScreen : Boolean;
    VSync : Boolean;
    MSAA : Integer;

  private
    form : TEngWindow;
  end;

  TGraphics = record
    Filtration : Integer;
  end;

  TSound = record
    Sound : Boolean;
    Music : Boolean;
  end;

var
  Window : TWindow;
  Graphics : TGraphics;
  Sound : TSound;

procedure Load;
procedure Update;

implementation

uses
  IniFiles,

  SubSystems;

procedure Load;
var
  SettingFile : TIniFile;
begin

  SettingFile := TIniFile.Create( 'Data\Config.ini' );

    Window.Width := SettingFile.ReadInteger( 'Window', 'Width', 800 );
    Window.Height := SettingFile.ReadInteger( 'Window', 'Height', 600 );
    Window.FullScreen := SettingFile.ReadBool( 'Window', 'FullScreen', False );
    Window.VSync := SettingFile.ReadBool( 'Window', 'VSync', False );
    Window.MSAA := SettingFile.ReadInteger( 'Window', 'MSAA', 0 );

    Graphics.Filtration := SettingFile.ReadInteger( 'Graphics', 'Filtration', 1 );

    Sound.Sound := SettingFile.ReadBool( 'Sound', 'Sound', False );
    Sound.Music := SettingFile.ReadBool( 'Sound', 'Music', False );

  SettingFile.Free;

end;

procedure Update;
begin
  EngineCore.GetCurrentWin( Window.form );

  Window.Width := Window.form.uiWidth;
  Window.Height := Window.form.uiHeight;
end;

end.
